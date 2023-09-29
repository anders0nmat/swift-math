
public protocol _Node: AnyObject {
	var parent: AnyNode? { get set }
	var children: [AnyNode] { get }

	var root: AnyNode { get }

	func evaluate() -> MathResult
}

public typealias AnyNode = any _Node

public final class Node<Body: Evaluable>: _Node {
	public weak var parent: AnyNode? = nil

	public var root: AnyNode { parent?.root ?? self }
	public var children: [AnyNode] {
		var result: [AnyNode] = []
		
		if let prefixPath = body.prefixPath {
			result += [body[keyPath: prefixPath].wrappedValue]
		}

		result += body.argumentsPath.map { body[keyPath: $0].wrappedValue }

		if let restPath = body.restPath {
			result += body[keyPath: restPath].wrappedValue
		}

		return result
	}

	public internal(set) var body: Body

	public init(_ body: Body) {
		self.body = body

		self.children.forEach { $0.parent = self }
	}

	public func evaluate() -> MathResult {
		let result = body.evaluate()
		if case var .failure(error) = result {
			error.origin = error.origin ?? self
			return .failure(error)
		}
		return result
	}
}

extension Node: CustomDebugStringConvertible {
	public var debugDescription: String {
		"Node(body: \(body))"
	}
}
