
public struct EmptyNode: Evaluable {
	public func evaluate(node: Node) -> MathResult {
		.failure(.evalError(message: "Missing Node"))
	}
}
