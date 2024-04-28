
import Foundation

// Namespace for all operators
public enum Operator {}

public extension Operator {
	static var builtins: [AnyEvaluable] { [
		Number(0),
		List(),

		Variable(""),
		Identifier(""),
	] }

	static var basicArithmetic: [AnyEvaluable] { [
		Infix(priority: 10, identifier: "+") {
			$0.addFunction { (a: Type.Number, b: Type.Number) in a + b }
			$0.addFunction { (a: [Type._0], b: [Type._0]) in a + b }
		},
		Infix(priority: 11, identifier: "-") {
			$0.addFunction { (a: Type.Number, b: Type.Number) in a - b }
		},
		Infix(priority: 40, identifier: "*") {
			$0.addFunction(*)
		},
		Division(),
		Function(identifier: "(") { (a: Type._0) in a }
	] }

	static var constants: [AnyEvaluable] { [
		Constant(Type.Number.pi, displayName: "π", identifier: "pi"),
		Constant(exp(1), displayName: "e", identifier: "e"),
	] }

	static var trigonometry: [AnyEvaluable] { [
		Function(identifier: "sin", function: sin),
		Function(identifier: "cos", function: cos),
		Function(identifier: "tan", function: tan),	
	] }

	static var listManipulation: [AnyEvaluable] { [
		PrefixFunction(identifier: "at") {
			(arr: [Type._0], num: Type.Number) in
			let idx = try num.asInt()
			if arr.indices.contains(idx) {
				return arr[idx]
			}
			throw MathError.valueError
		},
		Function(identifier: "repeat") {
			(element: Type._0, times: Type.Number) -> [Type._0] in
			let i = try times.asInt()
			guard i >= 0 else {
				throw MathError.valueError
			}

			return [Type._0](repeating: element, count: i)
		},
		Function(identifier: "len") { (a: [Type._0]) in Type.Number(a.count)	},
	] }
}
