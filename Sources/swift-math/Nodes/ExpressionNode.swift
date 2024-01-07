
public struct ExpressionNode: Evaluable {
	@Argument
	public var expr: AnyNode

	public var argumentsPath: [ArgumentKey<Self>] { [\.$expr] }

	public func evaluate() -> MathResult {
		return expr.evaluate()
	}
}

public extension Node where Body == ExpressionNode {
	static func expression() -> Self {
		Self(ExpressionNode())
	}
}
