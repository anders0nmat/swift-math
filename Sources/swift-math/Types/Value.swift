
public enum MathValue: Equatable, CustomStringConvertible {
	case number(MathNumber)
	case identifier(MathIdentifier)
	case list(MathList)

	init<T: MathTypeConvertible>(rawValue: T) {
		self = rawValue.mathValue
	}

	var type: MathType {
		return switch self {
			case .number(_): .number
			case .identifier(_): .identifier
			case .list(let val): .list(val.elementType)
		}
	}

	func asNumber() throws -> MathNumber { try asType() }
	func asIdentifier() throws -> MathIdentifier { try asType() }

	public var description: String {
		switch self {
			case .number(let val): String(val)
			case .identifier(let val): "\"\(val)\""
			case .list(let val): String(describing: val.values)
		}
	}

	func asType<T: MathTypeConvertible>() throws -> T {
		try T(value: self)
	}
}
