
public struct InfixNode: PriorityEvaluable {	
	public internal(set) var priority: UInt
	public var identifier: String
	public var arguments = ArgumentPaths(rest: \.parts)

	var functions: FunctionContainer
	var parts = ArgumentList()

	public init(priority: UInt, identifier: String, functions: FunctionContainer.Visitor) {
		self.priority = priority
		self.functions = FunctionContainer()
		self.identifier = identifier

		functions(&self.functions)
	}

	public func merge(with other: any PriorityEvaluable) -> (any PriorityEvaluable)? {
		guard let other = other as? InfixNode else { return nil }
		guard other.priority == priority else { return nil }
		guard other.identifier == identifier else { return nil }

		var new = self
		new.parts.nodeList = other.parts.nodeList + self.parts.nodeList
		return new
	}

	public func evaluate() throws -> MathValue {
		let values = try parts.nodeList.map { try $0.evaluate() }
		guard let first = values.first else {
			throw MathError.missingArgument
		}

		if values.count == 1 { return first }

		return try values
			.dropFirst()
			.reduce(first) { try functions.evaluate([$0, $1])}
	}

	public func evaluateType() -> MathType? {
		let values = parts.nodeList.map { $0.returnType }
		guard !values.contains(nil) else { return nil }
		guard let first = values.first else { return nil }

		if values.count == 1 { return first }

		return values
			.dropFirst()
			.reduce(first!) { functions.evaluateType([$0, $1!]) }
	}
}
