
public struct NumberNode: Evaluable {
	internal var value: MathFloat

	public init(_ value: MathFloat) {
		self.value = value
	}

	public func evaluate(node: Node) -> MathResult {
		.success(.number(value))
	}
}
