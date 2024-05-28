
public extension Operator {
	struct Expression: Evaluable {
		public var identifier: String { "#expression" }
		/*public struct Storage: Codable {
			public var expression = AnyNode()
		}
		public var instance = Storage()*/
		public var instance = SingleArgumentStorage(AnyNode())

		public let arguments = ArgumentPath(arguments: \.value)

		public func evaluate() throws -> MathValue { try instance.value.evaluate() }
		public func evaluateType() -> MathType? { instance.value.returnType }
	}
}

public extension Node where Body == Operator.Expression {
	static func expression() -> Self { Self(Body()) }
}
