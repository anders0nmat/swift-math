
public protocol _Node: AnyObject {
	associatedtype Body: ContextEvaluable

	var parent: AnyNode? { get set }
	var root: AnyNode { get }

	var children: [AnyNode] { get set }

	var body: Body { get }

	var variables: VariableContainer { get }

	var returnType: MathType? { get }

	func evaluate() throws -> MathValue

	@available(*, deprecated, renamed: "returnType")
	func evaluateType() -> MathType?

	func replace(child node: AnyNode, with new: AnyNode)
	func replaceSelf(with new: AnyNode)

	@available(*, deprecated)
	func postChange(in node: AnyNode)

	func childrenChanged()
	func contextChanged()

	var hasPrefix: Bool { get }
	var hasArguments: Bool { get }
	var hasRest: Bool { get }
	var hasPriority: Bool { get }
	var argumentCount: Int { get }
	var priority: UInt? { get }
	var prefixArgument: MathArgument? { get }
	var arguments: [MathArgument]  { get }
	var restArgument: MathArgumentList? { get }

}

public typealias AnyNode = any _Node

public final class Node<Body: ContextEvaluable>: _Node {
	public weak var parent: AnyNode?
	public var root: AnyNode { parent?.root ?? self }
	
	private var _body: Body
	public var body: Body {
		get { _body }
		set {
			_body = newValue
			linkChildren()
			updateReturnType()
		}
	}

	private var _variables: VariableContainer!
	public var variables: VariableContainer { 
		get { _variables }
		set { _variables = newValue }
	}

	public private(set) var returnType: MathType?

	public init(_ body: Body, parent: AnyNode? = nil) {
		self.parent = parent
		self._body = body
		self._variables = VariableContainer(owner: self)
		self.returnType = _body.evaluateType(in: self)
		linkChildren()
	}

	public func evaluate() throws -> MathValue {
		do {
			return try _body.evaluate(in: self)
		}
		catch let e as MathErrorContainer { throw e }
		catch let e as MathError { throw MathErrorContainer(error: e, origin: self) }
		catch let e { throw MathErrorContainer(error: .unknown(e), origin: self) }
	}

	@available(*, deprecated, renamed: "returnType")
	public func evaluateType() -> MathType? {
		returnType
		//_body.evaluateType(in: self)
	}

	public func replace(child node: AnyNode, with new: AnyNode) {
		guard node.parent === self else { return }

		new.parent = self
		new.contextChanged()
		// Old approach, quick'n'dirty but calls all listeners of body regardless of need
		//children = children.map { $0 === node ? new : $0 }

		if let prefixPath = _body.arguments.prefixPath, _body[keyPath: prefixPath].node === node {
			_body[keyPath: prefixPath].node = new
		}

		_body.arguments.argumentsPath.forEach {
			if _body[keyPath: $0].node === node {
				_body[keyPath: $0].node = new
			}
		}

		if let restPath = _body.arguments.restPath, _body[keyPath: restPath].nodeList.contains(where: {$0 === node}) {
			_body[keyPath: restPath].nodeList = _body[keyPath: restPath].nodeList.map { $0 === node ? new : $0 } 
		}

		childrenChanged()
	}

	public func replaceSelf(with new: AnyNode) { parent?.replace(child: self, with: new) }

	private func linkChildren() { children.forEach { $0.parent = self } }

	@available(*, deprecated)
	public func postChange(in node: AnyNode) {
		// Reassign triggers all property observers
		// children = children

		// Smart/complicated approach -- Faster?
		/*if let prefixPath = _body.arguments.prefixPath, _body[keyPath: prefixPath].node === node {
			_body[keyPath: prefixPath].node = node // Trigger observers
		}

		_body.arguments.argumentsPath.forEach {
			if _body[keyPath: $0].node === node {
				_body[keyPath: $0].node = node // Trigger observers
			}
		}

		if let restPath = _body.arguments.restPath, _body[keyPath: restPath].nodeList.contains(where: {$0 === node}) {
			_body[keyPath: restPath].nodeList += [] // Trigger observers
		}*/
		/*
		if _body.postChange(in: node, old: nil) {
			parent?.postChange(in: self)
		}*/
	}

	@available(*, deprecated)
	public func postTypeChange(of variable: String) {
		/*
		children.forEach({ $0.postTypeChange(of: variable) })

		if _body.postTypeChange(of: variable) {
			parent?.postChange(in: self)
		}*/
	}

	private func updateReturnType() {
		let newReturnType = _body.evaluateType(in: self)
		if returnType != newReturnType {
			returnType = newReturnType
			parent?.childrenChanged()
		}	
	}

	private var isChanging = false

	public func childrenChanged() {
		if isChanging { return }
		isChanging = true
		
		_body.childrenChanged()
		
		isChanging = false
		updateReturnType()
	}

	public func contextChanged() {
		children.forEach { $0.contextChanged() }

		_body.contextChanged()

		updateReturnType()
	}
}

public extension Node /* ArgumentContainer */ {

	var prefixArgument: MathArgument? { _body.arguments.prefixPath.map { _body[keyPath: $0] } }
	var arguments: [MathArgument]  { _body.arguments.argumentsPath.map { _body[keyPath: $0] } }
	var restArgument: MathArgumentList? { _body.arguments.restPath.map { _body[keyPath: $0] } }

	var hasPrefix: Bool { _body.arguments.hasPrefix }
	var hasArguments: Bool { _body.arguments.hasArguments }
	var hasRest: Bool { _body.arguments.hasRest }
	var hasPriority: Bool { _body is any PriorityEvaluable }

	var argumentCount: Int { _body.arguments.argumentCount }
	var priority: UInt? { (_body as? any PriorityEvaluable)?.priority }

	var children: [AnyNode] {
		get {
				(prefixArgument.map { [$0.node] } ?? [])
			+	(arguments.map(\.node))
			+	(restArgument.map(\.nodeList) ?? [])
		}

		set {
			// Put new values in matching place and fill with EmptyNode if neccessary
			var nodeIterator = newValue.makeIterator()

			if let prefixPath = _body.arguments.prefixPath {
				_body[keyPath: prefixPath].node = nodeIterator.next() ?? Node<EmptyNode>.empty()
			}

			_body.arguments.argumentsPath.forEach {
				_body[keyPath: $0].node = nodeIterator.next() ?? Node<EmptyNode>.empty()
			}

			if let restPath = _body.arguments.restPath {
				_body[keyPath: restPath].nodeList = Array(nodeIterator)
			}

			linkChildren()
		}
	}
}

extension Node: CustomStringConvertible {
	public var description: String {
		"<Node \(Body.self) \"\(_body.identifier)\">"
	}
}

extension Node: CustomDebugStringConvertible {
	public var debugDescription: String {
		"Node(body: \(_body))"
	}
}
