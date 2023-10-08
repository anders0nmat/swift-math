
public struct InfixNode: PriorityEvaluable {
	public typealias Reducer = (MathFloat, MathFloat) -> MathFloat
	

	public internal(set) var priority: UInt
	public internal(set) var displayName: String
	internal var reducer: Reducer

	@ArgumentList var parts: [AnyNode]

	public var restPath: ArgumentListKey<InfixNode>? { \.$parts }

	public init(priority: UInt, reducer: @escaping Reducer, displayName: String, children: [AnyNode]) {
		self.priority = priority
		self.reducer = reducer
		self.displayName = displayName
		self.parts = children
	}

	public func evaluate() -> MathResult {
		var numbers: [MathFloat] = []

		for child in parts {
			switch child.evaluate() {
				case .success(let value):
					switch value {
						case .number(let number): numbers.append(number)
						default: return .failure(.genericError(message: "Non-matching type")) 
					}
				case .failure(let error): return .failure(error)
			}
		}

		switch numbers.count {
			case 1: return .success(.number(numbers.first!))
			case let x where x > 1: return .success(.number(numbers.suffix(from: 1).reduce(numbers.first!, reducer)))
			default: return .failure(.evalError(message: "No arguments"))
		}
	}
}
