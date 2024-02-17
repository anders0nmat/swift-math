import Foundation


public struct IterateNode: ContextEvaluable {
	public let reducer: (MathFloat, MathFloat) -> MathFloat
	public let initialValue: MathFloat

	@Argument var varName: AnyNode
	@Argument var start: AnyNode {
		didSet {
			if case .list(_) = start.evaluateType() {
				self.arguments.argumentsPath = [\.$varName, \.$start, \.$expression]
			}
			else {
				self.arguments.argumentsPath = [\.$varName, \.$start, \.$end, \.$expression]
			}
		}
	}
	@Argument var end: AnyNode
	@Argument var expression: AnyNode

	//public var argumentsPath: [ArgumentKey<IterateNode>] { [\.$varName, \.$start, \.$end, \.$expression] }
	
	public var arguments = Args(
		arguments: \.$varName, \.$start, \.$end, \.$expression
	)

	public init(initialValue: MathFloat, reducer: @escaping (MathFloat, MathFloat) -> MathFloat) {
		self.reducer = reducer
		self.initialValue = initialValue
	}

    public func evaluate(in context: Node<IterateNode>) throws -> MathValue {
		guard case .identifier(let name) = try varName.evaluate() else {
			throw MathError.unexpectedType(expected: .identifier)
		}

		var items: [MathValue] = []

		switch try start.evaluate() {
			case .number(let lower):
				guard let lower = Int(exactly: lower) else { throw MathError.valueError }
				guard let upper = try Int(exactly: end.evaluate().asFloat()) else { throw MathError.valueError }

				items = (lower...upper).map { .number(Double($0)) }
			case .list(let value):
				items = value.map { .number($0) }
			default: throw MathError.unexpectedType(expected: .number)
		}

		var total = initialValue
		for item in items {
			context.variables[name] = item

			total = try reducer(total, expression.evaluate().asFloat())
		}

		return .number(total)		
    }	
}
