
public protocol _Node: AnyObject {
	var parent: AnyNode? { get set }
	var root: AnyNode { get }

	var children: [AnyNode] { get set }

	func evaluate() -> MathResult

	func replace(child node: AnyNode, with new: AnyNode)
	func replaceSelf(with new: AnyNode)

	var body: any Evaluable { get }
}

public typealias AnyNode = any _Node

public final class Node<Body: Evaluable>: _Node {
	public weak var parent: AnyNode? = nil

	public var root: AnyNode { parent?.root ?? self }

	public var children: [AnyNode] {
		get { typedBody.children }
		set { 
			typedBody.children = newValue
			children.forEach { $0.parent = self }
		}
	}

	public var body: any Evaluable { self.typedBody }
	public internal(set) var typedBody: Body

	public init(_ body: Body) {
		self.typedBody = body

		self.typedBody.children.forEach { $0.parent = self }
	}

	public func evaluate() -> MathResult {
		let result = typedBody.evaluate()
		if case var .failure(error) = result {
			error.origin = error.origin ?? self
			return .failure(error)
		}
		return result
	}

	public func replace(child node: AnyNode, with new: AnyNode) {
		guard node.parent === self else { return }

		typedBody.children = typedBody.children.map {
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
		"Node(typedBody: \(typedBody))"
	}
}

extension MutableCollection {
	mutating func formMap(_ transform: (Element) throws -> Element) rethrows {
		for (idx, element) in zip(self.indices, self) {
			self[idx] = try transform(element)
		}
	}
}
