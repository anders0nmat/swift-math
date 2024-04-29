
public extension Operator {
	struct Iterate: ContextEvaluable {
		public let functions: FunctionContainer
		public let initialValue: MathValue
		public let identifier: String

		public internal(set) var varName = Argument()
		public internal(set) var start = Argument()
		public internal(set) var end = Argument()
		public internal(set) var expression = Argument()

		public var arguments = ArgumentPath(
			arguments: \.varName, \.start, \.end, \.expression
		)

		public init(identifier: String, initialValue: MathValue, functions: FunctionContainer) {
			self.identifier = identifier
			self.functions = functions
			self.initialValue = initialValue
		}

		public mutating func childrenChanged() {
			expression.node.variables.clear()

			guard let name = try? varName.evaluate().asIdentifier() else { return }

			switch start.returnType {
				case .list(let elementType):
					expression.node.variables.declare(name, type: elementType)
					arguments.argumentsPath = [\.varName, \.start, \.expression]
					
				default:
					expression.node.variables.declare(name, type: .number)
					arguments.argumentsPath = [\.varName, \.start, \.end, \.expression]
			}
		}

		public func evaluate(in context: Node<Self>) throws -> MathValue {
			let name = try varName.evaluate().asIdentifier()

			var items: [MathValue] = []

			switch try start.evaluate() {
				case .number(let lower):
					guard let lower = Int(exactly: lower) else { throw MathError.valueError }
					guard let upper = try Int(exactly: end.evaluate().asNumber()) else { throw MathError.valueError }

					items = (lower...upper).map { .number(Double($0)) }
				case .list(let list):
					items = list.values
				default: throw MathError.unexpectedType(expected: .number)
			}

			if items.isEmpty {
				return initialValue
			}

			expression.node.variables.set(name, to: items.first!)
			defer { expression.node.variables.deleteValue(name) }
			
			var total = try expression.evaluate()
			for item in items.suffix(from: 1) {
				expression.node.variables.set(name, to: item)

				total = try functions.evaluate([total, expression.evaluate()])
			}

			return total
		}	
	}
}
