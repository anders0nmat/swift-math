
public struct SingleArgumentNode: Evaluable {
	var arg = Argument()

	//public var argumentsPath: [ArgumentKey<Self>] { [\.$arg] }

	public var arguments = ArgumentPaths(arguments: \.arg)

	public var displayName: String
	var evaluator: (Double) -> Double

	public init(displayName: String, evaluator: @escaping (Double) -> Double) {
		self.evaluator = evaluator
		self.displayName = displayName
	}

	public func evaluate() throws -> MathValue {
		try .number(evaluator(arg.evaluate().asFloat()))
	}

	public func evaluateType() -> MathType? { .number }
}
