
public extension Operator {
	struct Empty: Evaluable {
		public var identifier: String { "#empty" }
		public func evaluate() throws -> MathValue {
			throw MathError.missingArgument
		}
	}
}

public extension Node where Body == Operator.Empty {
	static func empty() -> Self { Self(Body()) }
}

public extension Operator.Empty {
	static func node() -> Node<Self> { Node.empty() } 
}
