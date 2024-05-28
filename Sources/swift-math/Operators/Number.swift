
public extension Operator {
	struct Number: Evaluable {
		public var identifier: String { "#number" }

		public enum Part: String, Codable {
			case integer, fraction
		}
		public enum Sign: String, Codable {
			case plus, minus
		}

		public struct Storage: Codable {
			public var integer: String = ""
			public var fraction: String = ""

			public var sign: Sign = .plus
			public var decimal: Part = .integer

			public var numberString: String {
				var result = ""
				if sign == .minus {
					result += "-"
				}
				result += integer.isEmpty ? "0" : integer
				if decimal == .fraction {
					result += "."
					result += fraction.isEmpty ? "0" : fraction
				}

				return result
			}

			public init(rawString: String) {
				let parts = rawString.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
				let (integer, fraction) = (parts[0], parts.count == 2 ? parts[1] : "")

				switch integer.first {
					case "+":
						self.sign = .plus
						self.integer = String(integer.suffix(from: integer.index(after: integer.startIndex)))
					case "-":
						self.sign = .minus
						self.integer = String(integer.suffix(from: integer.index(after: integer.startIndex)))
					default: self.integer = String(integer)
				}

				self.decimal = parts.count == 2 ? .fraction : .integer
				self.fraction = String(fraction)	
			}

			public init(from decoder: any Decoder) throws {
				let container = try decoder.singleValueContainer()
				try self.init(rawString: container.decode(String.self))
			}

			public func encode(to encoder: any Encoder) throws {
				var container = encoder.singleValueContainer()
				try container.encode(numberString)				
			}
		}
		public var instance: Storage

		public init(_ value: Type.Number) {
			self.init(rawString: String(value))
		}

		public init(_ value: String) {
			self.init(rawString: value)
		}

		internal init(rawString: String) {
			self.instance = Storage(rawString: rawString)
		}

		mutating public func customize(using arguments: [String]) -> Bool {
			guard let rawString = arguments.first, arguments.count == 1 else { return false }

			self = Self.init(rawString: rawString)
			return true
		}

		mutating func negate() {
			switch instance.sign {
				case .plus: self.instance.sign = .minus
				case .minus: self.instance.sign = .plus
			}
		}

		mutating func append(number: String) {
			if instance.decimal == .fraction {
				instance.fraction.append(number)
			}
			else {
				instance.integer.append(number)
			}
		}

		mutating func fraction() {
			instance.decimal = .fraction
		}

		public func evaluate() throws -> MathValue {
			if let value = Double(instance.numberString) {
				return .number(value)
			}
			throw MathError.valueError
		}

		public func evaluateType() -> MathType? { .number }
	}
}

public extension Node where Body == Operator.Number {
	static func number(_ value: Type.Number) -> Self { Self(Body(value)) }
}
