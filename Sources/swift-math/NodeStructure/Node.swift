
public protocol _Node: AnyObject {
	var parent: AnyNode? { get set }
	var root: AnyNode { get }

	func evaluate() -> MathResult

	func replace(child node: AnyNode, with new: AnyNode)
	func replaceSelf(with new: AnyNode)
}

public typealias AnyNode = any _Node

public final class Node<Body: Evaluable>: _Node {
	public weak var parent: AnyNode? = nil

	public var root: AnyNode { parent?.root ?? self }

	public internal(set) var body: Body

	public init(_ body: Body) {
		self.body = body

		self.body.children.forEach { $0.parent = self }
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

		body.children = body.children.map {
			if $0 === node {
				new.parent = self
				return new
			}
			else {
				return $0
			}
		}
	}

	public func replaceSelf(with new: AnyNode) { parent?.replace(child: self, with: new) }
}

extension Node: CustomDebugStringConvertible {
	public var debugDescription: String {
		"Node(body: \(body))"
	}
}

extension MutableCollection {
	mutating func formMap(_ transform: (Element) throws -> Element) rethrows {
		for (idx, element) in zip(self.indices, self) {
			self[idx] = try transform(element)
		}
	}
}
