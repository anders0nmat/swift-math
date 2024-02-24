
public protocol MathGeneric: MathTypeConvertible {
	typealias Identifier = Int

	static var id: Identifier { get }
	var value: MathValue { get set }
}

public enum Math {
	public struct _0: MathGeneric {
	    public static var id: Identifier { 0 }
	    public var value: MathValue
		public init(value: MathValue) throws { self.value = value }
	}
	public struct _1: MathGeneric {
	    public static var id: Identifier { 1 }
	    public var value: MathValue
		public init(value: MathValue) throws { self.value = value }
	}
	public struct _2: MathGeneric {
	    public static var id: Identifier { 2 }
	    public var value: MathValue
		public init(value: MathValue) throws { self.value = value }
	}
	public struct _3: MathGeneric {
	    public static var id: Identifier { 3 }
	    public var value: MathValue
		public init(value: MathValue) throws { self.value = value }
	}
}

public extension MathGeneric {
	static var mathType: MathType { .generic(id) }
	var mathValue: MathValue { value }
}

