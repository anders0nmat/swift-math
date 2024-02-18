
public struct NumberNode: Evaluable {
	public internal(set) var value: (integer: String, fraction: String) = ("", "")
	public internal(set) var sign: FloatingPointSign = .plus
	public internal(set) var decimal: Bool = false

	public var numberString: String {
		var result = ""
		if sign == .minus {
			result += "-"
		}
		result += value.integer.isEmpty ? "0" : value.integer
		if decimal {
			result += "."
			result += value.fraction.isEmpty ? "0" : value.fraction
		}

		return result
	}

	public init(_ value: MathNumber) {
		self.init(rawString: String(value))
	}

	public init(_ value: String) {
		self.init(rawString: value)
	}

	internal init(rawString: String) {
		let parts = rawString.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
		let (integer, fraction) = (parts[0], parts.count == 2 ? parts[1] : "")

		switch integer.first {
			case "+":
				self.sign = .plus
				self.value.integer = String(integer.suffix(from: integer.index(after: integer.startIndex)))
			case "-":
				self.sign = .minus
				self.value.integer = String(integer.suffix(from: integer.index(after: integer.startIndex)))
			default: self.value.integer = String(integer)
		}

		self.decimal = parts.count == 2
		self.value.fraction = String(fraction)
	}

	mutating public func customize(using arguments: [String]) -> Result<Nothing, ParseError> {
		guard let rawString = arguments.first, arguments.count == 1 else {
			return .failure(.init(message: .contextError(message: "Too many/few arguments")))
		}

		self = Self.init(rawString: rawString)
		return .success
	}

	mutating func negate() {
		switch sign {
			case .plus: self.sign = .minus
			case .minus: self.sign = .plus
		}
	}

	mutating func append(number: String) {
		if decimal {
			value.fraction.append(number)
		}
		else {
			value.integer.append(number)
		}
	}

	mutating func fraction() {
		decimal = true
	}

	public func evaluate() throws -> MathValue {
		if let value = Double(numberString) {
			return .number(value)
		}
		throw MathError.valueError
	}

	public func evaluateType() -> MathType? { .number }
}
