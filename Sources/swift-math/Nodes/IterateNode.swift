
public struct IterateNode: ContextEvaluable {
	public let reducer: (MathNumber, MathNumber) -> MathNumber
	public let initialValue: MathNumber
	public var identifier: String

	var varName = Argument() {
		didSet {
			if let oldName = try? oldValue.evaluate().asIdentifier() {
				expression.node.variables.delete(oldName)
			}
			if let newName = try? varName.evaluate().asIdentifier() {
				let varType: MathType? = switch start.evaluateType() {
					case .number: MathType.number
					case .list(let elementType): elementType
					default: nil
				}
				expression.node.variables.declare(newName, type: varType)
			}
		}
	}
	var start = Argument() {
		didSet {
			if case .list(let elementType) = start.evaluateType() {
				self.arguments.argumentsPath = [\.varName, \.start, \.expression]
				if let name = try? varName.evaluate().asIdentifier() {
					expression.node.variables.declare(name, type: elementType)
				}
			}
			else {
				self.arguments.argumentsPath = [\.varName, \.start, \.end, \.expression]
				if let name = try? varName.evaluate().asIdentifier() {
					expression.node.variables.declare(name, type: .number)
				}
			}
		}
	}
	var end = Argument()
	var expression = Argument() {
		didSet {
			if let name = try? varName.evaluate().asIdentifier() {
				let varType: MathType? = switch start.evaluateType() {
					case .number: MathType.number
					case .list(let elementType): elementType
					default: nil
				}
				expression.node.variables.declare(name, type: varType)
			}
		}
	}

	public var arguments = ArgumentPaths(
		arguments: \.varName, \.start, \.end, \.expression
	)

	public init(identifier: String, initialValue: MathNumber, reducer: @escaping (MathNumber, MathNumber) -> MathNumber) {
		self.identifier = identifier
		self.reducer = reducer
		self.initialValue = initialValue
	}

	public func postChange(in node: AnyNode) -> Bool {
		guard let name = try? varName.evaluate().asIdentifier() else { return false }
		
	}

    public func evaluate(in context: Node<IterateNode>) throws -> MathValue {
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

		var total = initialValue
		for item in items {
			expression.node.variables.set(name, to: item)

			total = try reducer(total, expression.evaluate().asNumber())
		}
		expression.node.variables.deleteValue(name)

		return .number(total)
    }	
}
