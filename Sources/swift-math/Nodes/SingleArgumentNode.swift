
public struct SingleArgumentNode: Evaluable {
	@Argument
	var arg: AnyNode

	public var argumentsPath: [ArgumentKey<Self>] { [\.$arg] }

	public var displayName: String
	var evaluator: (Double) -> Double

	public init(displayName: String, evaluator: @escaping (Double) -> Double) {
		self.evaluator = evaluator
		self.displayName = displayName
	}

	public func evaluate() -> MathResult {
		let result = arg.evaluate()

		switch result {
			case .success(.number(let val)):
				return .success(.number(evaluator(val)))
			case .failure(let error): return .failure(error)
			default: return .failure(.evalError(message: "Wrong data type"))
		}
	}
}
