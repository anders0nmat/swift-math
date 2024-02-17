
public enum MathType: Equatable {
	case number
	case identifier
	indirect case list(MathType)
}

public typealias MathFloat = Double
public typealias MathIdentifier = String
public typealias MathList = [MathFloat]

public enum MathValue: Equatable {
	case number(MathFloat)
	case identifier(MathIdentifier)
	case list(MathList)

	var type: MathType {
		return switch self {
			case .number(_): .number
			case .identifier(_): .identifier
			case .list(_): .list(.number)
		}
	}

	func asFloat() throws -> MathFloat {
		if case .number(let val) = self { return val }
		throw MathError.unexpectedType(expected: .number, found: self.type)
	}
}
