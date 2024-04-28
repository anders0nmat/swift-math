
public extension Operator {
	struct Constant: Evaluable {
		public let value: MathValue
		public let displayName: String
		public let identifier: String

		public init<T: MathTypeConvertible>(_ value: T, displayName: String, identifier: String) {
			self.value = value.mathValue
			self.displayName = displayName
			self.identifier = identifier
		}

		public func evaluate() throws -> MathValue { value }
		public func evaluateType() -> MathType? { value.type }
	}
}
