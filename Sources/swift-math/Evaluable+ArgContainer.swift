
public protocol Evaluable {
	associatedtype Arguments: ArgContainer = EmptyArguments

	func evaluate(args: Arguments) -> MathResult
}


struct IntegralNode {
	@Argument var lowerBound: AnyNode
	@Argument var upperBound: AnyNode
	@Argument var expression: AnyNode

	public var arguments: [ArgumentKey] { [\.lowerBound, \.upperBound, \.expression] }

	func evaluate() -> MathResult {
		let lower = lowerBound.evaluate()
		let upper = upperBound.evaluate()


		var acc = 0.0
		for v in lower..upper {
			acc += expression.evaluate()
		}

		return .success(.number(acc))
	}
}

