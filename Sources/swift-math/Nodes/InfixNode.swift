
public struct InfixNode: PriorityEvaluable {
	public typealias Reducer = (MathFloat, MathFloat) -> MathFloat
	
	public internal(set) var priority: UInt
	public internal(set) var displayName: String
	internal var reducer: Reducer

	@ArgumentList var parts: [AnyNode]

	//public var restPath: ArgumentListKey<Self>? { \.$parts }

	//public var argumentPaths = ArgumentPaths<Self>(rest: \.$parts)

	public var arguments = Args(rest: \.$parts)

	public init(priority: UInt, reducer: @escaping Reducer, displayName: String, children: [AnyNode]) {
		self.priority = priority
		self.reducer = reducer
		self.displayName = displayName
		self.parts = children
	}

	public func merge(with other: any PriorityEvaluable) -> (any PriorityEvaluable)? {
		guard let other = other as? InfixNode else { return nil }
		guard other.priority == priority else { return nil }
		guard other.displayName == displayName else { return nil }

		var new = self
		new.parts = other.parts + self.parts
		return new
	}

	public func evaluate() throws -> MathValue {
		var numbers: [MathFloat] = []

		for child in parts {
			try numbers.append(child.evaluate().asFloat())
		}

		switch numbers.count {
			case 1: return .number(numbers.first!)
			case let x where x > 1: return .number(numbers.suffix(from: 1).reduce(numbers.first!, reducer))
			default: throw MathError.missingArgument
		}
	}

	public func evaluateType() -> MathType? { .number }
}
