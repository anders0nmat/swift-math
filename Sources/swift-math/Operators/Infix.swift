
public extension Operator {
	struct Infix: PriorityEvaluable {	
		public internal(set) var priority: UInt
		public var identifier: String
		public var arguments = ArgumentPath(rest: \.value)

		public internal(set) var functions: FunctionContainer

		/*public struct Storage: Codable {
			public var parts: [AnyNode] = []
		}
		public var instance = Storage()*/
		public var instance = SingleValueStorage([AnyNode]())

		public init(priority: UInt, identifier: String, functions: FunctionContainer) {
			self.priority = priority
			self.functions = functions
			self.identifier = identifier
		}
		
		public mutating func merge(with other: Infix) -> Bool {
			guard other.priority == priority else { return false }
			guard other.identifier == identifier else { return false }

			self.instance.value += other.instance.value

			return true
		}

		public func evaluate() throws -> MathValue {
			let values = try instance.value.map { try $0.evaluate() }
			guard let first = values.first else {
				throw MathError.missingArgument
			}

			if values.count == 1 { return first }

			return try values
				.dropFirst()
				.reduce(first) { try functions.evaluate([$0, $1])}
		}

		public func evaluateType() -> MathType? {
			let values = instance.value.map { $0.returnType }
			guard !values.contains(nil) else { return nil }
			guard let first = values.first else { return nil }

			if values.count == 1 { return first }

			return values
				.dropFirst()
				.reduce(first!) { functions.evaluateType([$0, $1!]) }
		}
	}
}


