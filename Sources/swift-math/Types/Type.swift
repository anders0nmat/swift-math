
public enum MathType: Equatable, Hashable, CustomStringConvertible {
	case number
	case identifier
	indirect case list(MathType?)

	case generic(MathGeneric.Identifier)

	init<T: MathTypeConvertible>(rawValue: T) {	
		self = T.mathType
	}

	public var description: String {
		switch self {
			case .number:       "number"
			case .identifier:   "identifier"
			case .list(let el): "list(\(el != nil ? String(describing: el!) : "nil"))"
			case .generic(_):   "generic"
		}
	}
}

public typealias MathNumber = Double
public typealias MathIdentifier = String

public typealias RawMathList<T: MathTypeConvertible> = Array<T>

public extension MathNumber {
	func asInt() throws -> Int {
		if let i = Int(exactly: self) {
			return i
		}
		throw MathError.valueError
	}
}


public struct MathList: Equatable {
	public private(set) var values: [MathValue]
	public private(set) var elementType: MathType?

	init() {
		self.values = []
		self.elementType = nil
	}

	init(_ values: [MathValue]) throws {
		self.values = values
		if let firstType = self.values.first?.type {
			if !self.values.map(\.type).allSatisfy({$0 == firstType}) {
				throw MathError.valueError
			}
			self.elementType = firstType
		}
	}

	public init<T: MathTypeConvertible>(_ rawList: RawMathList<T>) {
		try! self.init(rawList.map { MathValue(rawValue: $0) })
		/*self.values = rawList.map { MathValue(rawValue: $0) }
		self.elementType = T.mathType*/
	}

	mutating func append(_ newElement: MathValue) throws {
		if let elementType, elementType != newElement.type {
			throw MathError.unexpectedType(expected: elementType, found: newElement.type)
		}
		elementType = newElement.type
		values.append(newElement)
	}
}

extension MathList: BidirectionalCollection {
	public typealias Index = [MathValue].Index
	public typealias Element = [MathValue].Element

	public subscript(position: Array<MathValue>.Index) -> Array<MathValue>.Element {
		get { values[position] }
	}

    public func index(before i: Array<MathValue>.Index) -> Array<MathValue>.Index { values.index(before: i) }
    public func index(after i: Array<MathValue>.Index) -> Array<MathValue>.Index { values.index(after: i) }
    public var startIndex: Array<MathValue>.Index { values.startIndex }
    public var endIndex: Array<MathValue>.Index { values.endIndex }
}



public protocol MathTypeConvertible {
	static var mathType: MathType { get }
	var mathValue: MathValue { get }

	init(value: MathValue) throws
}

extension MathNumber: MathTypeConvertible {
	public static var mathType: MathType { .number }
	public var mathValue: MathValue { .number(self) }

	public init(value: MathValue) throws {
		guard case let .number(v) = value else {
			throw MathError.unexpectedType(expected: .number, found: value.type)
		}

		self = v
	}
}

extension MathIdentifier: MathTypeConvertible {
	public static var mathType: MathType { .identifier }
	public var mathValue: MathValue { .identifier(self) }

	public init(value: MathValue) throws {
		guard case let .identifier(v) = value else {
			throw MathError.unexpectedType(expected: .identifier, found: value.type)
		}

		self = v
	}
}

extension MathList: MathTypeConvertible {
	public static var mathType: MathType { .list(nil) }
	public var mathValue: MathValue { .list(self) }

	public init(value: MathValue) throws {
		guard case let .list(v) = value else {
			throw MathError.unexpectedType(expected: .list(nil), found: value.type)
		}

		self = v
	}
}

extension RawMathList: MathTypeConvertible {
	public static var mathType: MathType { .list(Element.mathType) }
	public var mathValue: MathValue { .list(MathList(self)) }

	public init(value: MathValue) throws {
		guard case let .list(v) = value else {
			throw MathError.unexpectedType(expected: Self.mathType, found: value.type)
		}

		self = try v.values.map { try Element(value: $0) }
	}
}
