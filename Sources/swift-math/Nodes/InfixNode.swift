
public struct InfixNode: PriorityEvaluable {	
	public internal(set) var priority: UInt
	public internal(set) var displayName: String
	internal var functions: FunctionContainer

	var parts = ArgumentList()

	public var arguments = ArgumentPaths(rest: \.parts)

	public init(priority: UInt, displayName: String, functions: FunctionContainer.Visitor) {
		self.priority = priority
		self.functions = FunctionContainer()
		self.displayName = displayName

		functions(&self.functions)
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
		let values = try parts.nodeList.map { try $0.evaluate() }
		guard let first = values.first else {
			throw MathError.missingArgument
		}

		if values.count == 1 {
			return first
		}

		return try values
			.dropFirst()
			.reduce(first) { try functions.evaluate([$0, $1])}
	}

	public func evaluateType() -> MathType? { .number }
}
