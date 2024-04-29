
import swift_math

extension Operator.Infix: CustomDisplayable {
	var displayString: String {
		parts.nodeList.map(\.displayString).joined(separator: identifier)
	}

	var debugDisplayProperties: String { [
		"identifier: \(identifier)",
		"priority: \(priority)"
		].joined(separator: ", ")
	}
}

extension Operator.Number: CustomDisplayable {
	var displayString: String { numberString }

	var debugDisplayProperties: String { [
		"numberString: \(numberString)",
		"sign: \(sign)",
		"value: \(value)",
		"decimal: \(decimal)"
		].joined(separator: ", ")
	}
}

extension Operator.Expression: CustomDisplayable {
	var displayString: String { ": " + expr.node.displayString }
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
		"[\(entries.nodeList.map(\.displayString).joined(separator: ", "))]"
	}

	var debugDisplayProperties: String { "" }
}

extension Operator.Variable: CustomDisplayable {
	var displayString: String { name }
	var debugDisplayProperties: String { "name: \"\(name)\"" }
}

extension Operator.Identifier: CustomDisplayable {
	var displayString: String { "\"\(name)\"" }
	var debugDisplayProperties: String { "identifier: \"\(name)\"" }
}

