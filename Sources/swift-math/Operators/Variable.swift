
public extension Operator {
	struct Variable: ContextEvaluable {
		public var identifier: String { "#variable" }
		public private(set) var name: String

		public init(_ name: String) {
			self.name = name
		}

		public mutating func customize(using arguments: [String]) -> Bool {
			guard let name = arguments.first else { return false }

			self.name = name
			return true
		}

		public func evaluate(in context: Node<Self>) throws -> MathValue {
			if let value = context.variables.get(name) {
				return value
			}
			throw MathError.missingVariable(name: name)
		}

		public func evaluateType(in context: Node<Self>) -> MathType? {
			context.variables.getType(name)
		}

		public func postTypeChange(of variable: String) -> Bool {
			variable == name
		}
	}
}
