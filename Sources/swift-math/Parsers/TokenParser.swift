
public final class TokenParser {
	public typealias Token = (name: String, args: [String])
	public typealias ParseResult = Result<Nothing, ParseError>

	public private(set) var root: AnyNode
	public private(set) weak var current: AnyNode?

	public private(set) var operators: [String : any ContextEvaluable]

	public init(operators: [String : any ContextEvaluable]) {
		self.root = Node.expression()
		self.current = self.root.children.first
		self.operators = operators
	}

	public func addOperator(_ node: any ContextEvaluable, name: String) {
		self.operators[name] = node
	}

	internal func getHead(from node: AnyNode) -> AnyNode {
		if node.argumentCount > 0 {
			return node.children[node.hasPrefix ? 1 : 0]
		}
		else if node.hasRest {
			node.children.append(Node.empty())
			return node.children.last!
		}
		return node
	}

	internal enum NavigationOrigin {
		case here
		case parent
		case child(AnyNode)
	}

	/**
	Gets the next child of `node` after an optional `current`.
	If Result is nil, there is no next child, indicating that `node` should be kept as `currentNode`
	*/
	private func nextChild(of node: AnyNode, from origin: NavigationOrigin = .here) -> AnyNode? {
		// Buffering because not O(1) lookup
		let children = node.children
		
		switch origin {
		case .here:
			if let parent = node.parent {
				return nextChild(of: parent, from: .child(node))
			}
			else {
				return nextChild(of: node, from: .parent)
			}
		case .parent:
			if let firstChild = children.first {
				return nextChild(of: firstChild, from: .parent)
			}
			else if node.hasRest {
				node.children.append(Node.empty())
				return node.children.last!
			}
			else {
				return node
			}
		case .child(let child):
			if let idx = children.firstIndex(where: { $0 === child }), idx < children.index(before: children.endIndex) {
				return nextChild(of: children[children.index(after: idx)], from: .parent)
			}
			else {
				if let restList = node.restNodes, !node.hasPriority {
					if child === restList.last, child is Node<EmptyNode> {
						node.children.removeLast()
					}
					else {
						node.children.append(Node.empty())
						return node.children.last!
					}
				}

				return node
			}
		}

	}

	private func prevChild(of node: AnyNode, from origin: NavigationOrigin = .here) -> AnyNode? {
		// Buffering because not O(1) lookup
		let children = node.children
		
		switch origin {
		case .here:
			if node.hasRest && !node.hasPriority {
				node.children.append(Node.empty())
				return node.children.last!	
			}
			else if let lastChild = node.children.last {
				return prevChild(of: lastChild, from: .parent)
			}
			else if let parent = node.parent {
				return prevChild(of: parent, from: .child(node))
			}
			else {
				return node
			}
		case .parent:
			return node
		case .child(let child):
			if let idx = children.firstIndex(where: { $0 === child }), idx > children.startIndex {
				if node.restNodes?.last === child, child is Node<EmptyNode> {
					node.children.removeLast()
				}
				return prevChild(of: children[children.index(before: idx)], from: .parent)
			}
			else if let parent = node.parent {
				if let restList = node.restNodes, child === restList.last, child is Node<EmptyNode> {
					node.children.removeLast()
				}

				return prevChild(of: parent, from: .child(node))
			}
			else {
				return prevChild(of: node, from: .parent)
			}
		}
	}

	internal func advanceHead(current start: AnyNode) -> AnyNode {
		guard let parent = start.parent else {
			// TODO: Is this useful behavior?
			return start
		}

		if start.children.isEmpty {
			if start !== parent.children.last {
				return parent.children[parent.children.index(after: parent.children.firstIndex(where: {$0 === start})!)]
			}
			else if parent.hasRest && !(start is Node<EmptyNode>) {
				parent.children.append(Node.empty())
				return parent.children.last!
			}
			return parent
		}
		else {
			return start.children.first!
		}
	}

	internal func deadvanceHead(current start: AnyNode) -> AnyNode {
		if start.children.isEmpty {
			return start.parent ?? start
		}
		else {
			// Can go one level deeper
			if start.hasRest {
				start.children.append(Node.empty())
			}
			return start.children.last!
		}
	}

	internal func processNumber(_ token: Token) -> ParseResult {
		let decimalNumbers = Character("0")...Character("9")

		guard let arg = token.args.first, token.args.count == 1 else {
			return .failure(.unknownToken)
		}

		switch current {
			case is Node<EmptyNode>:
				let insertString: String
				switch arg {
					case "+-": insertString = "-"
					case ".": insertString = "0."
					case let num where Double(num) != nil: 
						insertString = num
					default: return .failure(.unknownToken)
				}
				let newOp = NumberNode(insertString)
				let newNode = newOp.makeNode()
				current!.replaceSelf(with: newNode)
				self.current = newNode
				return .success
			case let number as Node<NumberNode>:
				switch arg {
					case "+-": number.body.negate()
					case ".": number.body.fraction()
					case let num where num.allSatisfy { decimalNumbers.contains($0) }:
						number.body.append(number: num)
					default: return .failure(.unknownToken)
				}
				return .success
			default: return .failure(.unknownToken)
		}
	}

	internal func processPriorityOperator(_ op: any PriorityEvaluable) -> ParseResult {
		var current = self.current
		let opPrio = op.priority

		// Travel up until parent is lower-prio or non-prio operation
		while let currPrio = current?.parent?.priority, currPrio >= opPrio {
			/* Force unwrap reasoning:
			- currPrio succeeded
			- Therefore current must not be nil
			*/
			current = current!.parent
		}

		guard let current else { return .failure(.emptyHead) }

		let newNode: AnyNode
		if let other = current.body as? any PriorityEvaluable, 
		let mergedOp = op.merge(with: other) {
			newNode = mergedOp.makeNode()
			current.replaceSelf(with: newNode)
			newNode.children.append(Node.empty())
		}
		else {
			newNode = op.makeNode()
			// The following two lines need to be in this order
			// because assignment in line 2 sets current.parent = newNode
			// which makes replaceSelf() impossible
			current.replaceSelf(with: newNode)
			newNode.children += [current, Node.empty()]
		}
		self.current = newNode.children.last
		return .success
	}

	internal func processOperator(_ token: Token) -> ParseResult {
		guard var op = operators[token.name] else { return .failure(.unknownToken) }
		guard let current else { return .failure(.noHead) }
		guard current !== root else { return .failure(.noHead) }

		op.resetArguments()
		if case .failure(let error) = op.customize(using: token.args) {
			return .failure(error)
		}

		if op is NumberNode {
			return processNumber(token)
		}

		if let op = op as? any PriorityEvaluable {
			return processPriorityOperator(op)
		}

		// Fully copied op at this point
		// Now insert...
		let newNode = op.makeNode()

		if newNode.hasPrefix {
			if current is Node<EmptyNode> {
				// TODO: Allow prefix arguments to be empty?
				return .failure(.emptyHead)
			}
			else {
				current.replaceSelf(with: newNode)
				newNode.children[0] = current
				self.current = getHead(from: newNode)
				return .success
			}
		}
		else {
			if current is Node<EmptyNode> {
				current.replaceSelf(with: newNode)

				self.current = getHead(from: newNode)
				return .success
			}
			else {
				return .failure(.noEmptyHead(head: current))
			}
		}
	}

	internal func processNavigation(_ token: Token) -> ParseResult {
		guard let current else {
			return .failure(.emptyHead)
		}

		switch token {
			case ("->", []): 
				self.current = nextChild(of: current)
				//self.current = advanceHead(current: current)
				return .success
			case ("<-", []):
				self.current = prevChild(of: current)
				return .success
			default: return .failure(.unknownToken)
		}		
	}

	public func parse(token: Token) -> ParseResult {
		// Order matters! First to return success aborts processing
		let handlers = [
			processNavigation,
			processOperator,
		]

		for handler in handlers {
			let result = handler(token)
			switch result {
				case .success: return .success
				case .failure(let error) where error.message != .unknownToken:
					return result
				default: break
			}
		}

		return .failure(.unknownToken)
	}

	public func parse(token: String, args: [String] = []) -> ParseResult {
		parse(token: (name: token, args: args))
	}

	public func parse(_ command: String) -> ParseResult {
		let parts = command.split(separator: ":")
		let name = String(parts[0])
		let args = parts.suffix(from: 1).map { String($0) }
		return parse(token: name, args: args)
	}

	public func clear() {
		self.root = Node.expression()
		self.current = self.root.children.first
	}
}

