
public struct IterateNode: ContextEvaluable {
	public let reducer: (MathNumber, MathNumber) -> MathNumber
	public let initialValue: MathNumber

	var varName = Argument()
	var start = Argument() {
		didSet {
			if case .list(_) = start.evaluateType() {
				self.arguments.argumentsPath = [\.varName, \.start, \.expression]
			}
			else {
				self.arguments.argumentsPath = [\.varName, \.start, \.end, \.expression]
			}
		}
	}
	var end = Argument()
	var expression = Argument()

	public var arguments = ArgumentPaths(
		arguments: \.varName, \.start, \.end, \.expression
	)

	public init(initialValue: MathNumber, reducer: @escaping (MathNumber, MathNumber) -> MathNumber) {
		self.reducer = reducer
		self.initialValue = initialValue
	}

    public func evaluate(in context: Node<IterateNode>) throws -> MathValue {
		guard case .identifier(let name) = try varName.evaluate() else {
			throw MathError.unexpectedType(expected: .identifier)
		}

		var items: [MathValue] = []

		switch try start.evaluate() {
			case .number(let lower):
				guard let lower = Int(exactly: lower) else { throw MathError.valueError }
				guard let upper = try Int(exactly: end.evaluate().asNumber()) else { throw MathError.valueError }

				items = (lower...upper).map { .number(Double($0)) }
			case .list(let list):
				items = list.values
			default: throw MathError.unexpectedType(expected: .number)
		}

		var total = initialValue
		for item in items {
			context.variables[name] = item

			total = try reducer(total, expression.evaluate().asNumber())
		}

		return .number(total)
    }	
}
