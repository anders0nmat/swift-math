
public struct SinglePrefixNode: Evaluable {
	var prefixArg = Argument()
	var arg = Argument()

	public var arguments = ArgumentPaths(prefix: \.prefixArg, arguments: \.arg)

	public var displayName: String
	var evaluator: (Double, Double) -> Double

	public init(displayName: String, evaluator: @escaping (Double, Double) -> Double) {
		self.evaluator = evaluator
		self.displayName = displayName
	}

	public func evaluate() throws -> MathValue {
		try .number(evaluator(prefixArg.evaluate().asNumber(), arg.evaluate().asNumber()))
	}

	public func evaluateType() -> MathType? { .number }
}
