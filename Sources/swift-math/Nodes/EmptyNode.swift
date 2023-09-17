
public struct EmptyNode: Evaluable {
	public func evaluate(args: EmptyArguments) -> MathResult {
		.failure(.evalError(message: "Missing Node"))
	}
}
