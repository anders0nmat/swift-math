
/*
struct IntegralNode: Evaluable {
	@Argument var lowerBound: AnyNode
	@Argument var upperBound: AnyNode
	@Argument var expression: AnyNode

	public var argumentsPath: [ArgumentKey<Self>] { [\.$lowerBound, \.$upperBound, \.$expression] }

	func evaluate() -> MathResult {
		let lower = lowerBound.evaluate()
		let upper = upperBound.evaluate()

		guard case let .success(.number(lowerValue)) = lower else { return .failure(.genericError()) }
		guard case let .success(.number(upperValue)) = upper else { return .failure(.genericError()) }

		var acc = 0.0
		for _ in Int(lowerValue)...Int(upperValue) {
			switch expression.evaluate() {
				case .success(let val):
					switch val {
						case .number(let val): acc += val
						default: return .failure(.genericError())
					}
				case let a: return a
			}
		}

		return .success(.number(acc))
	}
}*/
