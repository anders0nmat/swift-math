
public struct ExpressionNode: Evaluable {
	public var identifier: String { "#expression" }
	var expr = Argument()
	public var arguments = ArgumentPaths(arguments: \.expr)

	public func evaluate() throws -> MathValue { try expr.evaluate() }
	public func evaluateType() -> MathType? { expr.evaluateType() }
}

public extension Node where Body == ExpressionNode {
	static func expression() -> Self {
		Self(ExpressionNode())
	}
}
