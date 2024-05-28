
public extension Operator {
	struct Iterate: ContextEvaluable {
		public let functions: FunctionContainer
		public let initialValue: MathValue
		public let identifier: String

		public struct Storage: Codable {
			public var varName = AnyNode()
			public var start = AnyNode()
			public var end = AnyNode()
			public var expression = AnyNode()
		}
		public var instance = Storage()


		public var arguments = ArgumentPath(
			arguments: \.varName, \.start, \.end, \.expression
		)

		public init(identifier: String, initialValue: MathValue, functions: FunctionContainer) {
			self.identifier = identifier
			self.functions = functions
			self.initialValue = initialValue
		}

		public mutating func childrenChanged() {
			instance.expression.node.variables.clear()

			guard let name = try? instance.varName.evaluate().asIdentifier() else { return }

			switch instance.start.returnType {
				case .list(let elementType):
					instance.expression.node.variables.declare(name, type: elementType)
					arguments.argumentsPath = [\.varName, \.start, \.expression]
					
				default:
					instance.expression.node.variables.declare(name, type: .number)
					arguments.argumentsPath = [\.varName, \.start, \.end, \.expression]
			}
		}

		public func evaluate(in context: Node<Self>) throws -> MathValue {
			let name = try instance.varName.evaluate().asIdentifier()

			var items: [MathValue] = []

			switch try instance.start.evaluate() {
				case .number(let lower):
					guard let lower = Int(exactly: lower) else { throw MathError.valueError }
					guard let upper = try Int(exactly: instance.end.evaluate().asNumber()) else { throw MathError.valueError }

					items = (lower...upper).map { .number(Double($0)) }
				case .list(let list):
					items = list.values
				default: throw MathError.unexpectedType(expected: .number)
			}

			if items.isEmpty {
				return initialValue
			}

			instance.expression.node.variables.set(name, to: items.first!)
			defer { instance.expression.node.variables.deleteValue(name) }
			
			var total = try instance.expression.evaluate()
			for item in items.suffix(from: 1) {
				instance.expression.node.variables.set(name, to: item)

				total = try functions.evaluate([total, instance.expression.evaluate()])
			}

			return total
		}	
	}
}
