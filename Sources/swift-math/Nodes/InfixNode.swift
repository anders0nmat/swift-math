
public struct InfixNode: PriorityEvaluable {
	public typealias Reducer = (MathFloat, MathFloat) -> MathFloat
	
	public internal(set) var priority: UInt
	public internal(set) var displayName: String
	internal var reducer: Reducer

	var parts = ArgumentList()

	public var arguments = ArgumentPaths(rest: \.parts)

	public init(priority: UInt, reducer: @escaping Reducer, displayName: String, children: [AnyNode]) {
		self.priority = priority
		self.reducer = reducer
		self.displayName = displayName
		self.parts.nodeList = children
	}

	public func merge(with other: any PriorityEvaluable) -> (any PriorityEvaluable)? {
		guard let other = other as? InfixNode else { return nil }
		guard other.priority == priority else { return nil }
		guard other.displayName == displayName else { return nil }

		var new = self
		new.parts.nodeList = other.parts.nodeList + self.parts.nodeList
		return new
	}

	public func evaluate() throws -> MathValue {
		var numbers: [MathFloat] = []

		for child in parts.nodeList {
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
