
public protocol _Node: AnyObject {
	associatedtype Body: ContextEvaluable

	var parent: AnyNode? { get set }
	var root: AnyNode { get }

	var body: Body { get set }
	var children: [AnyNode] { get set }

	var observers: [NodeEventCallback] { get set }

	var variables: VariableContainer { get }

	var returnType: MathType? { get }

	func evaluate() throws -> MathValue

	func replace(child node: AnyNode, with new: AnyNode)
	func replaceSelf(with new: AnyNode)

	func childrenChanged()
	func contextChanged()
}

public typealias AnyNode = any _Node

public final class Node<Body: ContextEvaluable>: _Node {
	public weak var parent: AnyNode?
	public var root: AnyNode { parent?.root ?? self }
	public var observers: [NodeEventCallback] = []
	
	internal var _body: Body
	public var body: Body {
		get { _body }
		set {
			_body = newValue
			linkChildren()
			updateReturnType()
			fire(event: .body)
		}
	}

	public var children: [AnyNode] {
		get {
				(prefixNode.map { [$0] } ?? [])
			+	(argumentNodes)
			+	(restNodes ?? [])
		}
		set {
			var iterator = newValue.makeIterator()

			if let prefixPath {
				_body[keyPath: prefixPath].node = iterator.next() ?? Operator.Empty.node()
			}

			argumentPath.forEach {
				_body[keyPath: $0].node = iterator.next() ?? Operator.Empty.node()
			}

			if let restPath {
				_body[keyPath: restPath].nodeList = Array(iterator)
			}

			linkChildren()
			fire(event: .children)
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

	internal func linkChildren() { children.forEach { $0.parent = self } }

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
		fire(event: .children)
	}

	public func contextChanged() {
		children.forEach { $0.contextChanged() }

		_body.contextChanged()

		updateReturnType()
		fire(event: .context)
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

extension _Node {
	func findNodes<T: ContextEvaluable>(with type: T.Type) -> [Node<T>] {
		(Body.self == type ? [self as! Node<T>] : [])
		+ children.flatMap {
			$0.findNodes(with: type)
		}
	} 
}

extension Array where Element == AnyNode {
	func firstIndex(of node: AnyNode) -> Index? { firstIndex(where: { $0 === node }) }
	func contains(_ node: AnyNode) -> Bool { contains(where: { $0 === node }) }
}
