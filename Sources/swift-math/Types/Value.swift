
public enum MathValue: Equatable, CustomStringConvertible {
	case number(Type.Number)
	case identifier(Type.Identifier)
	case list(Type.List)

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

	func asNumber() throws -> Type.Number { try cast(to: Type.Number.self) }
	func asIdentifier() throws -> Type.Identifier { try cast(to: Type.Identifier.self) }

	public var description: String {
		switch self {
			case .number(let val): String(val)
			case .identifier(let val): "\"\(val)\""
			case .list(let val): String(describing: val.values)
		}
	}

	func cast<T: MathTypeConvertible>(to type: T.Type) throws -> T {
		try T(value: self)
	}
}
