
public extension Operator {
	struct Expression: Evaluable {
		public var identifier: String { "#expression" }
		public internal(set) var expr = Argument()
		public let arguments = ArgumentPath(arguments: \.expr)

		public func evaluate() throws -> MathValue { try expr.evaluate() }
		public func evaluateType() -> MathType? { expr.returnType }
	}
}

public extension Node where Body == Operator.Expression {
	static func expression() -> Self { Self(Body()) }
}
