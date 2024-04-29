
public protocol MathGeneric: MathTypeConvertible {
	typealias Identifier = Int

	static var id: Identifier { get }
	var value: MathValue { get set }
}

public extension Type {
	struct _0: MathGeneric {
	    public static var id: MathGeneric.Identifier { 0 }
	    public var value: MathValue
		public init(value: MathValue) throws { self.value = value }
	}
	struct _1: MathGeneric {
	    public static var id: MathGeneric.Identifier { 1 }
	    public var value: MathValue
		public init(value: MathValue) throws { self.value = value }
	}
	struct _2: MathGeneric {
	    public static var id: MathGeneric.Identifier { 2 }
	    public var value: MathValue
		public init(value: MathValue) throws { self.value = value }
	}
	struct _3: MathGeneric {
	    public static var id: MathGeneric.Identifier { 3 }
	    public var value: MathValue
		public init(value: MathValue) throws { self.value = value }
	}
}

public extension MathGeneric {
	static var mathType: MathType { .generic(id) }
	var mathValue: MathValue { value }
}

