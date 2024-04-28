
public extension Operator {
	struct Identifier: Evaluable {
		public var identifier: String { "#identifier" }
		public let name: String

		public init(_ identifier: String) {
			self.name = identifier
		}

		public mutating func customize(using arguments: [String]) -> Bool {
			guard let rawString = arguments.first else { return false }
			guard arguments.count == 1 else { return false }

			self = Self.init(rawString)
			return true
		}

		public func evaluate() throws -> MathValue { .identifier(name) }
		public func evaluateType() -> MathType? { .identifier }
	}
}