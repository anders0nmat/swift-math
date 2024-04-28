

public extension Type {
	protocol Generic: MathTypeConvertible {
		typealias Identifier = Int

		static var id: Identifier { get }
		var value: MathValue { get set }
	}

	struct _0: Generic {
	    public static var id: Generic.Identifier { 0 }
	    public var value: MathValue
		public init(value: MathValue) throws { self.value = value }
	}
	struct _1: Generic {
	    public static var id: Generic.Identifier { 1 }
	    public var value: MathValue
		public init(value: MathValue) throws { self.value = value }
	}
	struct _2: Generic {
	    public static var id: Generic.Identifier { 2 }
	    public var value: MathValue
		public init(value: MathValue) throws { self.value = value }
	}
	struct _3: Generic {
	    public static var id: Generic.Identifier { 3 }
	    public var value: MathValue
		public init(value: MathValue) throws { self.value = value }
	}
}

public extension Type.Generic {
	static var mathType: MathType { .generic(id) }
	var mathValue: MathValue { value }
}

