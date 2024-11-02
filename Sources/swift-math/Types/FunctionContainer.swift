

public final class FunctionContainer {
	public typealias CallSignature = [MathType]
	public typealias FunctionDelegator = (_ args: [MathValue]) throws -> MathValue
	public struct Function {
		var returnType: MathType?
		var function: FunctionDelegator
	}

	public typealias Visitor = (FunctionContainer) -> Void

	private var overloads: [CallSignature : Function]

	public init() {
		self.overloads = [:]
	}

	public convenience init(visitor: Visitor) {
		self.init()
		visitor(self)
	}

	private func typeMatches(g: MathType, c: MathType, pinned: inout [MathGeneric.Identifier: MathType]) -> Bool {
		switch (g, c) {
			case let (a, b) where a == b: return true
			case (.list(_), .list(nil)): return true
			case let (.list(a), .list(b)): return typeMatches(g: a!, c: b!, pinned: &pinned)

			case let (.generic(idx), b):
				if let a = pinned[idx] {
					return a == b
				}
				pinned[idx] = b
				return true
			default: return false
		}
	}

	private func signatureFits(generic: CallSignature, concrete: CallSignature) -> [MathGeneric.Identifier: MathType]? {
		guard generic.count == concrete.count else { return nil }

		var typeBindings: [MathGeneric.Identifier: MathType] = [:]

		if zip(generic, concrete).allSatisfy({ typeMatches(g: $0.0, c: $0.1, pinned: &typeBindings) }) {
			return typeBindings
		}
		return nil
	}

	private func replaceGenerics(of type: MathType?, with table: [MathGeneric.Identifier:MathType]) -> MathType? {
		switch type {
			case .generic(let idx): return table[idx]
			case .list(let ty): return .list(replaceGenerics(of: ty, with: table))
			default: return type
		}
	}

	public func getFunction(for argumentTypes: CallSignature) -> Function? {
		if let fn = overloads[argumentTypes] {
			return fn
		}

		for e in overloads {
			if let pinnedTypes = signatureFits(generic: e.key, concrete: argumentTypes) {
				var fn = e.value
				fn.returnType = replaceGenerics(of: fn.returnType, with: pinnedTypes)
				return fn
			}
		}

		return nil
	}

	public func addFunction(signature: CallSignature, function: Function) {
		overloads[signature] = function
	}

	/*public func evaluate(_ args: [Argument]) throws -> MathValue {
		try evaluate(args.map(\.node))
	}*/

	public func evaluate(_ nodes: [AnyNode]) throws -> MathValue {
		return try evaluate(nodes.map { try $0.evaluate() })
	}

	/*internal func evaluate(_ nodes: [any NodeProtocol]) throws -> MathValue {
		return try evaluate(nodes.map { try $0.evaluate() })
	}*/

	public func evaluate(_ values: [MathValue]) throws -> MathValue {
		let signature = values.map(\.type)

		guard let fn = getFunction(for: signature) else {
			throw MathError.noMatchingFunction(signature: signature)
		}

		return try fn.function(values)
	}

	/*public func evaluateType(_ args: [Argument]) -> MathType? {
		evaluateType(args.map(\.node))
	}*/

	public func evaluateType(_ nodes: [AnyNode]) -> MathType? {
		evaluateType(nodes.map(\.returnType))
	}

	/*internal func evaluateType(_ nodes: [any NodeProtocol]) -> MathType? {
		evaluateType(nodes.map({ $0.returnType }))
	}*/

	public func evaluateType(_ values: [MathType?]) -> MathType? {
		let signature = values
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
	func addFunction<T0, R>(_ fn: @escaping (T0) throws -> R) 
	where T0: MathTypeConvertible, R: MathTypeConvertible {
		addFunction(
			signature: [T0.mathType],
			function: Function(
				returnType: R.mathType,
				function: {args in
					try MathValue(rawValue: fn(
						args[0].cast(to: T0.self)
					))
				}
			)
		)
	}

	func addFunction<T0, T1, R>(_ fn: @escaping (T0, T1) throws -> R) 
	where T0: MathTypeConvertible, T1: MathTypeConvertible, R: MathTypeConvertible {
		addFunction(
			signature: [T0.mathType, T1.mathType],
			function: Function(
				returnType: R.mathType,
				function: {args in
					try MathValue(rawValue: fn(
						args[0].cast(to: T0.self),
						args[1].cast(to: T1.self)
					))
				}
			)
		)
	}

	func addFunction<T0, T1, T2, R>(_ fn: @escaping (T0, T1, T2) throws -> R) 
	where T0: MathTypeConvertible, T1: MathTypeConvertible, T2: MathTypeConvertible, R: MathTypeConvertible {
		addFunction(
			signature: [T0.mathType, T1.mathType, T2.mathType],
			function: Function(
				returnType: R.mathType,
				function: {args in
					try MathValue(rawValue: fn(
						args[0].cast(to: T0.self),
						args[1].cast(to: T1.self),
						args[2].cast(to: T2.self)
					))
				}
			)
		)
	}

	func addFunction<T0, T1, T2, T3, R>(_ fn: @escaping (T0, T1, T2, T3) throws -> R) 
	where T0: MathTypeConvertible, T1: MathTypeConvertible, T2: MathTypeConvertible, T3: MathTypeConvertible, R: MathTypeConvertible {
		addFunction(
			signature: [T0.mathType, T1.mathType, T2.mathType, T3.mathType],
			function: Function(
				returnType: R.mathType,
				function: {args in
					try MathValue(rawValue: fn(
						args[0].cast(to: T0.self),
						args[1].cast(to: T1.self),
						args[2].cast(to: T2.self),
						args[3].cast(to: T3.self)
					))
				}
			)
		)
	}	
}

