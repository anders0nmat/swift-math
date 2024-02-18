
public struct SingleArgumentNode: Evaluable {
	var arg = Argument()

	public var arguments = ArgumentPaths(arguments: \.arg)

	public var displayName: String
	var functions: FunctionContainer

	public init(displayName: String, evaluator: @escaping (Double) -> Double) {
		self.functions = FunctionContainer()
		self.functions.addFunction(evaluator)
		self.displayName = displayName
	}

	public init(displayName: String, functions: FunctionContainer.Visitor) {
		self.functions = FunctionContainer()
		self.displayName = displayName
		functions(&self.functions)
	}

	public func evaluate() throws -> MathValue { try functions.evaluate([arg]) }
	public func evaluateType() -> MathType? { functions.evaluateType([arg]) }
}
