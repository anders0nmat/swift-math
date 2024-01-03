
public protocol _Node: AnyObject, ArgumentContainer {
	associatedtype Body: Evaluable

	var parent: AnyNode? { get set }
	var root: AnyNode { get }

	var children: [AnyNode] { get set }

	var body: Body { get }

	func evaluate() -> MathResult

	func replace(child node: AnyNode, with new: AnyNode)
	func replaceSelf(with new: AnyNode)
}

public typealias AnyNode = any _Node

public final class Node<Body: Evaluable>: _Node {
	public weak var parent: AnyNode?
	public var root: AnyNode { parent?.root ?? self }
	
	public var body: Body {
		didSet { linkChildren() }
	}

	public init(_ body: Body, parent: AnyNode? = nil) {
		self.parent = parent
		self.body = body
		linkChildren()
	}

	public func evaluate() -> MathResult {
		let result = body.evaluate()
		if case var .failure(error) = result {
			error.origin = error.origin ?? self
			return .failure(error)
		}
		return result
	}

	public func replace(child node: AnyNode, with new: AnyNode) {
		guard node.parent === self else { return }

		children = children.map { $0 === node ? new : $0 }
	}

	public func replaceSelf(with new: AnyNode) { parent?.replace(child: self, with: new) }

	private func linkChildren() { children.forEach { $0.parent = self } }
}

public extension Node /* ArgumentContainer */ {
	var priority: UInt? { (body as? any PriorityEvaluable)?.priority }

	var prefixArgument: Argument? { body.prefixPath.map { body[keyPath: $0] } }
	var arguments: [Argument]  { body.argumentsPath.map { body[keyPath: $0] } }
	var restArgument: ArgumentList? { body.restPath.map { body[keyPath: $0] } }

	var children: [AnyNode] {
		get {
				(prefixNode.map {[$0]} ?? [])
			+	(argumentNodes)
			+	(restNodes ?? [])
		}

		set {
			// Put new values in matching place and fill with EmptyNode if neccessary
			var nodeIterator = newValue.makeIterator()

			if let prefixPath = body.prefixPath {
				body[keyPath: prefixPath].node = nodeIterator.next() ?? Node<EmptyNode>.empty()
			}

			body.argumentsPath.forEach {
				body[keyPath: $0].node = nodeIterator.next() ?? Node<EmptyNode>.empty()
			}

			if let restPath = body.restPath {
				body[keyPath: restPath].nodeList = Array(nodeIterator)
			}

			linkChildren()
		}
	}
}

extension Node: CustomDebugStringConvertible {
	public var debugDescription: String {
		"Node(body: \(body))"
	}
}
