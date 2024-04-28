
public extension Operator {
	struct Infix: PriorityEvaluable {	
		public internal(set) var priority: UInt
		public var identifier: String
		public var arguments = ArgumentPath(rest: \.parts)

		public internal(set) var functions: FunctionContainer
		public internal(set) var parts = ArgumentList()

		public init(priority: UInt, identifier: String, functions: FunctionContainer.Visitor) {
			self.priority = priority
			self.functions = FunctionContainer()
			self.identifier = identifier

			functions(&self.functions)
		}
		
		public mutating func merge(with other: Infix) -> Bool {
			guard other.priority == priority else { return false }
			guard other.identifier == identifier else { return false }

			self.parts.nodeList += other.parts.nodeList

			return true
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
}


