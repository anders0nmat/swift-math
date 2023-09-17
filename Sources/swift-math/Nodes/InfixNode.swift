
public struct InfixNode: Evaluable {
	public typealias Reducer = (MathFloat, MathFloat) -> MathFloat
	public struct Arguments: ArgContainer {
		public var parts: [Argument] = []

		public var rest: ArgListKey? { \.parts }
		public var arguments: [ArgKey] { [] }
	}

	public internal(set) var priority: UInt
	internal var reducer: Reducer

	public init(priority: UInt, reducer: @escaping Reducer) {
		self.priority = priority
		self.reducer = reducer
	}

	public func evaluate(args: Arguments) -> MathResult {
		var numbers: [MathFloat] = []

		for child in args.parts {
			switch child.wrappedValue.evaluate() {
				case .success(let value):
					switch value {
						case .number(let number): numbers.append(number)
						default: return .failure(.argumentType()) 
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
