
public protocol _Node: AnyObject {
	var parent: AnyNode? { get }
	var childrenList: [AnyNode] { get }

	var root: AnyNode { get }
}

public typealias AnyNode = any _Node

public final class Node<Body: Evaluable>: _Node {
	public internal(set) weak var parent: AnyNode? = nil

	public var root: AnyNode { parent?.root ?? self }
	public var childrenList: [AnyNode] {
		// TODO
		[]
	}

	public internal(set) var body: Body
	public internal(set) var children: Body.Arguments

	public init(_ body: Body) {
		self.body = body
		self.children = Body.Arguments()
	}

	public func evaluate() -> MathResult {
		let result = body.evaluate(args: children)
		if case var .failure(error) = result {
			error.setNode(self)
			return .failure(error)
		}
		return result
	}
}

extension Node: CustomDebugStringConvertible {
	public var debugDescription: String {
		"Node(body: \(body), children: \(childrenList))"
	}
}
