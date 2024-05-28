
import Foundation

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

	public internal(set) var root: any NodeProtocol
	public internal(set) weak var current: (any NodeProtocol)?

	public internal(set) var operators: [String : any ContextEvaluable]

	public var tokenAdvance = Token("->")
	public var tokenDeadvance = Token("<-")
	public var tokenErase = Token("erase")

	public init(operators: [String : any ContextEvaluable]) {
		self.root = Node.expression()
		self.current = self.root.children.first
		self.operators = operators
	}

	public convenience init(operators: [any ContextEvaluable] = []) {
		self.init(operators: Dictionary(operators.map {($0.identifier, $0)}, uniquingKeysWith: { a, _ in a }))
	}

	public func add(name: String, operator op: any ContextEvaluable) {
		self.operators[name] = op
	}

	public func add(_ op: any ContextEvaluable) {
		add(name: op.identifier, operator: op)
	}

	public func add(operators: [String : any ContextEvaluable]) {
		self.operators.merge(operators, uniquingKeysWith: { $1 })
	}

	public func clear() {
		self.root = Node.expression()
		self.current = self.root.children.first
	}

	public func erase() {
		guard let current else { return }
		self.current = clearNode(current)
	}

	public func assignRoot(_ node: any NodeProtocol) {
		self.root = node
		self.current = self.root
	}

	public func load(from data: Data) throws {
		let oldCurrent = self.current
		self.current = nil

		let decoder = JSONDecoder()
		decoder.userInfo[.mathOperators] = operators
		decoder.userInfo[.mathParser] = self
		do {
			let anyNode = try decoder.decode(AnyNode.self, from: data)
			self.root = anyNode.node
			if self.current == nil {
				self.current = self.root
			}
		}
		catch {
			self.current = oldCurrent
			throw error
		}
	}

	public func save(prettyPrint: Bool = false) throws -> Data {
		let encoder = JSONEncoder()
		if prettyPrint {
			encoder.outputFormatting = .prettyPrinted
		}
		encoder.userInfo[.mathParser] = self
		return try encoder.encode(AnyNode(self.root))
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

	/*
		Returns the next insertion point on new operators
	*/
	internal func getHead(from node: any NodeProtocol) -> any NodeProtocol {
		for child in node.children {
			if let ancestor = getHead(from: child) as? Node<Operator.Empty> {
				return ancestor
			}
		}
		if node.hasRest {
			let newNode = Node.empty()
			node.children.append(newNode)
			return newNode
		}
		return node
	}

	internal func clearNode(_ node: any NodeProtocol) -> any NodeProtocol {
		guard let parent = node.parent else { return node }
		guard let idx = parent.children.firstIndex(of: node) else { return node }

		if node is Node<Operator.Empty> {
			let nextNode = deleteEmptyNode(node)
			if nextNode === parent && parent.children.indices.contains(parent.children.index(before: idx)) {
				return parent.children[parent.children.index(before: idx)]
			}
			return nextNode
		}

		let newNode = Node.empty()

		var newChildren = parent.children.map { $0 === node ? newNode : $0 }

		if let restNodes = parent.restNodes, let idx = restNodes.lastIndex(where: { !($0 is Node<Operator.Empty>) }), restNodes.contains(node) {
			let endDistance = restNodes.distance(from: idx, to: restNodes.endIndex)
			let trailingRange = 
				(newChildren.index(newChildren.endIndex, offsetBy: -endDistance + 1))
				..<
				newChildren.endIndex

			if !trailingRange.isEmpty {
				newChildren.removeSubrange(trailingRange)
				newChildren.append(newNode)
			}
		}

		parent.children = newChildren

		return newNode
	}

	/*
		Deletes the given node from the rest-list of its parent.
		Returns the successor
	*/
	internal func deleteEmptyNode(_ node: any NodeProtocol) -> any NodeProtocol {
		guard let parent = node.parent else { return node }
		guard parent.restNodes?.contains(node) == true else { return node }
		guard let nodeIndex = parent.children.firstIndex(of: node) else { return node }
		guard node is Node<Operator.Empty> else { return node }

		var newChildren = parent.children
		newChildren.remove(at: nodeIndex)

		if parent.hasPriority && newChildren.count == 1 {
			parent.replaceSelf(with: newChildren[0])
			return newChildren[0]
		}

		parent.children = newChildren
		
		if parent.children.indices.contains(nodeIndex) {
			return parent.children[nodeIndex]
		}
		return parent
	}

	internal func appendRestNode(to node: any NodeProtocol) -> any NodeProtocol {
		guard node.hasRest else { return node }
		let newNode = Node.empty()
		node.children.append(newNode)
		return newNode
	}

	internal enum NavigationOrigin {
		case here
		case parent
		case child(any NodeProtocol)
	}

	/**
	Gets the next child of `node` after an optional `current`.
	If Result is nil, there is no next child, indicating that `node` should be kept as `currentNode`
	*/
	internal func nextChild(of node: any NodeProtocol, from origin: NavigationOrigin = .here) -> (any NodeProtocol)? {
		// Buffering because not O(1) lookup
		let children = node.children
		
		switch origin {
		case .here:
			if let parent = node.parent {
				return nextChild(of: parent, from: .child(node))
			}
			fallthrough
		case .parent:
			if let firstChild = children.first {
				return nextChild(of: firstChild, from: .parent)
			}
			if node.hasRest {
				return appendRestNode(to: node)
			}
			return node
		case .child(let child):
			guard let idx = children.firstIndex(of: child) else { return node }
			
			if idx < children.index(before: children.endIndex) {
				return nextChild(of: children[children.index(after: idx)], from: .parent)
			}

			if !node.hasRest { return node }

			if child is Node<Operator.Empty> {
				return deleteEmptyNode(child)
			}

			return appendRestNode(to: node)
		}
	}

	internal func prevChild(of node: any NodeProtocol, from origin: NavigationOrigin = .here) -> (any NodeProtocol)? {
		// Buffering because not O(1) lookup
		let children = node.children
		
		switch origin {
		case .here:
			if node.hasRest && !node.hasPriority {
				return appendRestNode(to: node)
			}
			if let lastChild = node.children.last {
				return prevChild(of: lastChild, from: .parent)
			}
			if let parent = node.parent {
				return prevChild(of: parent, from: .child(node))
			}
			return node
		case .parent: return node
		case .child(let child):
			guard let idx = children.firstIndex(of: child) else { return node }

			if node.restNodes?.last === child && child is Node<Operator.Empty> {
				let nextNode = deleteEmptyNode(child)
				if nextNode !== node { return nextNode }
			}
			
			if idx > children.startIndex {
				return prevChild(of: children[children.index(before: idx)], from: .parent)
			}

			if let parent = node.parent {
				return prevChild(of: parent, from: .child(node))
			}
			
			return prevChild(of: node, from: .parent)
		}
	}

	internal func processNumber(_ token: Token) throws {
		let decimalNumbers = Character("0")...Character("9")

		guard let arg = token.args.first, token.args.count == 1 else {
			throw ParseError.unknownToken(token)
		}

		switch current {
			case is Node<Operator.Empty>:
				let insertString: String
				switch arg {
					case "+-": insertString = "-"
					case ".": insertString = "0."
					case let num where Double(num) != nil: 
						insertString = num
					default: throw ParseError.unknownToken(token)
				}
				let newOp = Operator.Number(insertString)
				let newNode = newOp.makeNode()
				current!.replaceSelf(with: newNode)
				self.current = newNode
			case let number as Node<Operator.Number>:
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
		while let currPrio = current?.parent?.priority, currPrio >= opPrio {
			/* Force unwrap reasoning:
			- currPrio succeeded
			- Therefore current must not be nil
			*/
			current = current!.parent
		}

		guard let current else { throw ParseError.unexpectedHead }

		let newNode: any NodeProtocol

		if current.mergeBody(with: op) {
			newNode = current
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

		if op is Operator.Number {
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

		if newNode.hasPrefix {
			if current is Node<Operator.Empty> {
				// TODO: Allow prefix arguments to be empty?
				// throw ParseError.unexpectedHead

				current.replaceSelf(with: newNode)
				self.current = getHead(from: newNode)
			}
			else {
				current.replaceSelf(with: newNode)
				newNode.children[0] = current
				self.current = getHead(from: newNode)
			}
		}
		else {
			if current is Node<Operator.Empty> {
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
			case tokenErase: erase()
			default: return false
		}
		return true
	}
}


