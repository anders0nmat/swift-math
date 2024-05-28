
import Foundation

// Namespace for all operators
public enum Operator {}

public extension Operator {
	static var allOperators: [any ContextEvaluable] {
		builtins +
		basicArithmetic +
		advancedArithmetic +
		constants +
		trigonometry +
		listManipulation
	}


	static var builtins: [any ContextEvaluable] { [
		Empty(),
		Expression(),

		Number(0),
		List(),

		Variable(""),
		Identifier(""),
	] }

	static var basicArithmetic: [any ContextEvaluable] { [
		Infix(priority: 10, identifier: "+", functions: addFunctions),
		Infix(priority: 11, identifier: "-", functions: subtractFunctions),
		Infix(priority: 40, identifier: "*", functions: multiplyFunctions),
		Divide(),
		Parenthesis()
	] }

	static var advancedArithmetic: [any ContextEvaluable] { [
		Exponent()
	] }

	static var constants: [any ContextEvaluable] { [
		Constant(Type.Number.pi, displayName: "π", identifier: "pi"),
		Constant(exp(1), displayName: "e", identifier: "e"),
	] }

	static var trigonometry: [any ContextEvaluable] { [
		Function(identifier: "sin", function: sin),
		Function(identifier: "cos", function: cos),
		Function(identifier: "tan", function: tan),
	] }

	static var listManipulation: [any ContextEvaluable] { [
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
		Function(identifier: "len") { (a: [Type._0]) in Type.Number(a.count) },
	] }
}
