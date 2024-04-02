
public final class TreeParser {
	public struct Token: Equatable {
		public var name: String
		public var args: [String]

		public init(_ name: String, _ args: [String] = []) {
			self.init(name: name, args: args)
		}

		public init(name: String, args: [String] = []) {
			self.name = name
			self.args = args
		}
	}

	public internal(set) var root: AnyNode
	public internal(set) weak var current: AnyNode?

	public internal(set) var operators: [String : AnyEvaluable]

	public var tokenAdvance = Token("->")
	public var tokenDeadvance = Token("<-")

	public init(operators: [String : AnyEvaluable]) {
		self.root = Node.expression()
		self.current = self.root.children.first
		self.operators = operators
	}

	public convenience init(operators: [AnyEvaluable] = []) {
		self.init(operators: Dictionary(operators.map {($0.identifier, $0)}, uniquingKeysWith: { a, _ in a }))
	}

	public func add(name: String, operator op: AnyEvaluable) {
		self.operators[name] = op
	}

	public func add(_ op: AnyEvaluable) {
		add(name: op.identifier, operator: op)
	}

	public func add(operators: [String : AnyEvaluable]) {
		self.operators.merge(operators, uniquingKeysWith: { $1 })
	}

	public func clear() {
		self.root = Node.expression()
		self.current = self.root.children.first
	}

	public func erase() {
		let newCurrent = Node.empty()
		self.current?.replaceSelf(with: newCurrent)
		self.current = newCurrent
	}

	internal func processToken(_ token: Token) throws {
		do {
			if try !processNavigation(token) {
				try processOperator(token)
			}
		}
		catch let err as ParseError {
			throw ParseErrorContainer(
				error: err,
				root: self.root,
				current: self.current)
		}
		catch let err {
			throw ParseErrorContainer(
				error: .unknown(err),
				root: self.root,
				current: self.current)
		}
	}


	/* Token Parsing */

	internal func getHead(from node: AnyNode) -> AnyNode {
		if node.arguments.argumentCount > 0 {
			return node.children[node.arguments.hasPrefix ? 1 : 0]
		}
		else if node.arguments.hasRest {
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
	internal func nextChild(of node: AnyNode, from origin: NavigationOrigin = .here) -> AnyNode? {
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
			else if node.arguments.hasRest {
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
				if let restList = node.arguments.restArgument?.nodeList, !node.arguments.hasPriority {
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

	internal func prevChild(of node: AnyNode, from origin: NavigationOrigin = .here) -> AnyNode? {
		// Buffering because not O(1) lookup
		let children = node.children
		
		switch origin {
		case .here:
			if node.arguments.hasRest && !node.arguments.hasPriority {
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
				if node.arguments.restArgument?.nodeList.last === child, child is Node<EmptyNode> {
					node.children.removeLast()
				}
				return prevChild(of: children[children.index(before: idx)], from: .parent)
			}
			else if let parent = node.parent {
				if let restList = node.arguments.restArgument?.nodeList, child === restList.last, child is Node<EmptyNode> {
					node.children.removeLast()
				}

				return prevChild(of: parent, from: .child(node))
			}
			else {
				return prevChild(of: node, from: .parent)
			}
		}
	}

	internal func processNumber(_ token: Token) throws {
		let decimalNumbers = Character("0")...Character("9")

		guard let arg = token.args.first, token.args.count == 1 else {
			throw ParseError.unknownToken(token)
		}

		switch current {
			case is Node<EmptyNode>:
				let insertString: String
				switch arg {
					case "+-": insertString = "-"
					case ".": insertString = "0."
					case let num where Double(num) != nil: 
						insertString = num
					default: throw ParseError.unknownToken(token)
				}
				let newOp = NumberNode(insertString)
				let newNode = newOp.makeNode()
				current!.replaceSelf(with: newNode)
				self.current = newNode
			case let number as Node<NumberNode>:
				switch arg {
					case "+-": number.body.negate()
					case ".": number.body.fraction()
					case let num where num.allSatisfy { decimalNumbers.contains($0) }:
						number.body.append(number: num)
					default: throw ParseError.unknownToken(token)
				}
			default: throw ParseError.unknownToken(token)
		}
	}

	internal func processPriorityOperator(_ op: any PriorityEvaluable) throws {
		var current = self.current
		let opPrio = op.priority

		// Travel up until parent is lower-prio or non-prio operation
		while let currPrio = current?.parent?.arguments.priority, currPrio >= opPrio {
			/* Force unwrap reasoning:
			- currPrio succeeded
			- Therefore current must not be nil
			*/
			current = current!.parent
		}

		guard let current else { throw ParseError.unexpectedHead }

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
	}

	internal func processOperator(_ token: Token) throws {
		guard var op = operators[token.name] else { throw ParseError.unknownToken(token) }
		guard let current else { throw ParseError.noHead }
		guard current !== root else { throw ParseError.unexpectedHead }

		op.resetArguments()
		if !op.customize(using: token.args) {
			throw ParseError.customizationFailed(for: token.args, on: op)
		}

		if op is NumberNode {
			try processNumber(token)
			return
		}

		if let op = op as? any PriorityEvaluable {
			try processPriorityOperator(op)
			return
		}

		// Fully copied op at this point
		// Now insert...
		let newNode = op.makeNode()

		if newNode.arguments.hasPrefix {
			if current is Node<EmptyNode> {
				// TODO: Allow prefix arguments to be empty?
				throw ParseError.unexpectedHead
			}
			else {
				current.replaceSelf(with: newNode)
				newNode.children[0] = current
				self.current = getHead(from: newNode)
			}
		}
		else {
			if current is Node<EmptyNode> {
				current.replaceSelf(with: newNode)

				self.current = getHead(from: newNode)
			}
			else {
				throw ParseError.unexpectedHead
			}
		}
	}

	internal func processNavigation(_ token: Token) throws -> Bool {
		guard let current else { throw ParseError.noHead }

		switch token {
			case tokenAdvance: self.current = nextChild(of: current)
			case tokenDeadvance: self.current = prevChild(of: current)
			default: return false
		}
		return true
	}
}


