
import swift_math

extension Operator.Infix: CustomDisplayable {
	var displayString: String {
		instance.value.map(\.node.displayString).joined(separator: identifier)
	}

	var debugDisplayProperties: String { [
		"identifier: \(identifier)",
		"priority: \(priority)"
		].joined(separator: ", ")
	}
}

extension Operator.Number: CustomDisplayable {
	var displayString: String { instance.numberString }

	var debugDisplayProperties: String { [
		"numberString: \(instance.numberString)",
		"sign: \(instance.sign)",
		"integer: \(instance.integer)",
		"fraction: \(instance.fraction)",
		"decimal: \(instance.decimal)"
		].joined(separator: ", ")
	}
}

extension Operator.Expression: CustomDisplayable {
	var displayString: String { ": " + instance.value.node.displayString }
	var debugDisplayProperties: String { "" }
}

extension Operator.Empty: CustomDisplayable {
	var displayString: String { "[---]" }
	var debugDisplayProperties: String { "" }
}

extension Operator.Constant: CustomDisplayable {
	var displayString: String { displayName }
	var debugDisplayProperties: String {
		let value = switch value {
			case .list(let l): ".list(\(l))"
			case .number(let n): ".number(\(n))"
			case .identifier(let s): ".identifier(\(s))"
		}

		return [
			"identifier: \(identifier)",
			"displayName: \(displayName)",
			"value: \(value)"
		].joined(separator: ", ")
	}
}

extension Operator.List: CustomDisplayable {
	var displayString: String {
		"[\(instance.value.map(\.node.displayString).joined(separator: ", "))]"
	}

	var debugDisplayProperties: String { "" }
}

extension Operator.Variable: CustomDisplayable {
	var displayString: String { instance.value }
	var debugDisplayProperties: String { "name: \"\(instance.value)\"" }
}

extension Operator.Identifier: CustomDisplayable {
	var displayString: String { "\"\(instance.value)\"" }
	var debugDisplayProperties: String { "identifier: \"\(instance.value)\"" }
}

extension Operator.Parenthesis: CustomDisplayable {
	var displayString: String { "(\(instance.value.node.displayString))" }
	var debugDisplayProperties: String { "" }
}

extension Operator.Exponent: CustomDisplayable {
	var displayString: String { "(\(instance.base.node.displayString))^(\(instance.exponent.node.displayString))" }
	var debugDisplayProperties: String { "" }
}

