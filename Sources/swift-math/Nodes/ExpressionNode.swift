
public struct ExpressionNode: Evaluable {
	@Argument
	public var expr: AnyNode

	//public var argumentsPath: [ArgumentKey<Self>] { [\.$expr] }

	public var arguments = Args(arguments: \.$expr)

	public func evaluate() throws -> MathValue { try expr.evaluate() }

	public func evaluateType() -> MathType? { expr.evaluateType() }
}

public extension Node where Body == ExpressionNode {
	static func expression() -> Self {
		Self(ExpressionNode())
	}
}
