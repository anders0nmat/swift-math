

public struct FunctionContainer {
	public typealias CallSignature = [MathType]
	public typealias FunctionDelegator = (_ args: [MathValue]) throws -> MathValue
	public struct Function {
		var returnType: MathType
		var function: FunctionDelegator
	}

	public typealias Visitor = (inout FunctionContainer) -> Void

	private var overloads: [CallSignature : Function]
	//private var generics: [(CallSignature, Function)]


	public init() {
		self.overloads = [:]
		//self.generics = []
	}

	private func typeMatches(g: MathType, c: MathType) -> Bool {
		switch (g, c) {
			case let (a, b) where a == b: return true
			case (.list(nil), .list(_)): return true
			case (.list(_), .list(nil)): return true
			case let (.list(a), .list(b)): return typeMatches(g: a!, c: b!)
			default: return false
		}
	}

	private func signatureFits(generic: CallSignature, concrete: CallSignature) -> Bool {
		guard generic.count == concrete.count else { return false }

		return zip(generic, concrete).allSatisfy { typeMatches(g: $0.0, c: $0.1) }
	}

	public func getFunction(for argumentTypes: CallSignature) -> Function? {
		if let fn = overloads[argumentTypes] {
			return fn
		}

		return overloads.first { signatureFits(generic: $0.0, concrete: argumentTypes) }?.value
	}

	public mutating func addFunction(signature: CallSignature, function: Function) {
		overloads[signature] = function
	}

	public func evaluate(_ args: [MathArgument]) throws -> MathValue {
		try evaluate(args.map(\.node))
	}

	public func evaluate(_ nodes: [AnyNode]) throws -> MathValue {
		return try evaluate(nodes.map { try $0.evaluate() })
	}

	public func evaluate(_ values: [MathValue]) throws -> MathValue {
		let signature = values.map(\.type)

		guard let fn = getFunction(for: signature) else {
			throw MathError.noMatchingFunction(signature: signature)
		}

		return try fn.function(values)
	}

	public func evaluateType(_ args: [MathArgument]) -> MathType? {
		evaluateType(args.map(\.node))
	}

	public func evaluateType(_ nodes: [AnyNode]) -> MathType? {
		let signature = nodes.map({ $0.evaluateType() })
		if signature.contains(nil) {
			return nil
		}
		if let fn = getFunction(for: signature.map({ $0! })) {
			return fn.returnType
		}
		return nil	
	}
}

public extension FunctionContainer {
	mutating func addFunction<T0, R>(_ fn: @escaping (T0) -> R) 
	where T0: MathTypeConvertible, R: MathTypeConvertible {
		addFunction(
			signature: [T0.mathType],
			function: Function(
				returnType: R.mathType,
				function: {args in
					try MathValue(rawValue: fn(
						args[0].asType()
					))
				}
			)
		)
	}

	mutating func addFunction<T0, T1, R>(_ fn: @escaping (T0, T1) -> R) 
	where T0: MathTypeConvertible, T1: MathTypeConvertible, R: MathTypeConvertible {
		addFunction(
			signature: [T0.mathType, T1.mathType],
			function: Function(
				returnType: R.mathType,
				function: {args in
					try MathValue(rawValue: fn(
						args[0].asType(),
						args[1].asType()
					))
				}
			)
		)
	}

	mutating func addFunction<T0, T1, T2, R>(_ fn: @escaping (T0, T1, T2) -> R) 
	where T0: MathTypeConvertible, T1: MathTypeConvertible, T2: MathTypeConvertible, R: MathTypeConvertible {
		addFunction(
			signature: [T0.mathType, T1.mathType, T2.mathType],
			function: Function(
				returnType: R.mathType,
				function: {args in
					try MathValue(rawValue: fn(
						args[0].asType(),
						args[1].asType(),
						args[2].asType()
					))
				}
			)
		)
	}

	mutating func addFunction<T0, T1, T2, T3, R>(_ fn: @escaping (T0, T1, T2, T3) -> R) 
	where T0: MathTypeConvertible, T1: MathTypeConvertible, T2: MathTypeConvertible, T3: MathTypeConvertible, R: MathTypeConvertible {
		addFunction(
			signature: [T0.mathType, T1.mathType, T2.mathType, T3.mathType],
			function: Function(
				returnType: R.mathType,
				function: {args in
					try MathValue(rawValue: fn(
						args[0].asType(),
						args[1].asType(),
						args[2].asType(),
						args[3].asType()
					))
				}
			)
		)
	}


	
}

