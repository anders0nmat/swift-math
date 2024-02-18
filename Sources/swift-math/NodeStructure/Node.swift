
public protocol _Node: AnyObject, ArgumentContainer {
	associatedtype Body: ContextEvaluable

	var parent: AnyNode? { get set }
	var root: AnyNode { get }

	var children: [AnyNode] { get set }

	var body: Body { get }

	var variables: VariableContainer { get }

	func evaluate() throws -> MathValue
	func evaluateType() -> MathType?

	func replace(child node: AnyNode, with new: AnyNode)
	func replaceSelf(with new: AnyNode)

	func postChange(in node: AnyNode)
}

public typealias AnyNode = any _Node

public final class Node<Body: ContextEvaluable>: _Node {
	public weak var parent: AnyNode?
	public var root: AnyNode { parent?.root ?? self }
	
	public var body: Body {
		didSet {
			linkChildren()
			parent?.postChange(in: self)
		}
	}

	public var localVariables: VariableContainer

	public var variables: VariableContainer {
		localVariables.inScope(parent?.variables)
	}

	public init(_ body: Body, parent: AnyNode? = nil) {
		self.parent = parent
		self.body = body
		self.localVariables = VariableContainer()
		linkChildren()
	}

	public func evaluate() throws -> MathValue {
		do {
			return try body.evaluate(in: self)
		}
		catch let e as MathErrorContainer { throw e }
		catch let e as MathError { throw MathErrorContainer(error: e, origin: self) }
		catch let e { throw MathErrorContainer(error: .unknown(e), origin: self) }
	}

	public func evaluateType() -> MathType? {
		body.evaluateType(in: self)
	}

	public func replace(child node: AnyNode, with new: AnyNode) {
		guard node.parent === self else { return }

		children = children.map { $0 === node ? new : $0 }
	}

	public func replaceSelf(with new: AnyNode) { parent?.replace(child: self, with: new) }

	private func linkChildren() { children.forEach { $0.parent = self } }

	public func postChange(in node: AnyNode) {
		// Reassign triggers all property observers
		// children = children

		// Smart/complicated approach -- Faster?
		if let prefixPath = body.arguments.prefixPath, body[keyPath: prefixPath].node === node {
			body[keyPath: prefixPath].node = node // Trigger observers
		}

		body.arguments.argumentsPath.forEach {
			if body[keyPath: $0].node === node {
				body[keyPath: $0].node = node // Trigger observers
			}
		}

		if let restPath = body.arguments.restPath, body[keyPath: restPath].nodeList.contains(where: {$0 === node}) {
			body[keyPath: restPath].nodeList += [] // Trigger observers
		}
	}
}

public extension Node /* ArgumentContainer */ {
	var priority: UInt? { (body as? any PriorityEvaluable)?.priority }

	var prefixArgument: MathArgument? { body.arguments.prefixPath.map { body[keyPath: $0] } }
	var arguments: [MathArgument]  { body.arguments.argumentsPath.map { body[keyPath: $0] } }
	var restArgument: MathArgumentList? { body.arguments.restPath.map { body[keyPath: $0] } }

	var children: [AnyNode] {
		get {
				(prefixNode.map {[$0]} ?? [])
			+	(argumentNodes)
			+	(restNodes ?? [])
		}

		set {
			// Put new values in matching place and fill with EmptyNode if neccessary
			var nodeIterator = newValue.makeIterator()
			var bodyClone = body

			if let prefixPath = body.arguments.prefixPath {
				bodyClone[keyPath: prefixPath].node = nodeIterator.next() ?? Node<EmptyNode>.empty()
			}

			body.arguments.argumentsPath.forEach {
				bodyClone[keyPath: $0].node = nodeIterator.next() ?? Node<EmptyNode>.empty()
			}

			if let restPath = body.arguments.restPath {
				bodyClone[keyPath: restPath].nodeList = Array(nodeIterator)
			}

			body = bodyClone

			// Is this needed?
			//linkChildren()
		}
	}
}

extension Node: CustomStringConvertible {
	public var description: String {
		"<Node \(Body.self)>"
	}
}

extension Node: CustomDebugStringConvertible {
	public var debugDescription: String {
		"Node(body: \(body))"
	}
}
