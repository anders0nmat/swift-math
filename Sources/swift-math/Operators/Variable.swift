
public extension Operator {
	struct Variable: ContextEvaluable {
		public var identifier: String { "#variable" }
		/*public struct Storage: Codable {
			public var name: String
		}
		public var instance: Storage*/
		public var instance: SingleValueStorage<String>

		public init(_ name: String) {
			self.instance = SingleValueStorage(name)
		}

		public mutating func customize(using arguments: [String]) -> Bool {
			guard let name = arguments.first else { return false }

			self.instance.value = name
			return true
		}

		public func evaluate(in context: Node<Self>) throws -> MathValue {
			if let value = context.variables.get(instance.value) {
				return value
			}
			throw MathError.missingVariable(name: instance.value)
		}

		public func evaluateType(in context: Node<Self>) -> MathType? {
			context.variables.getType(instance.value)
		}

		public func postTypeChange(of variable: String) -> Bool {
			variable == instance.value
		}
	}
}

public extension Node where Body == Operator.Variable {
	static func variable(_ name: String) -> Self { Self(Body(name)) }
}
