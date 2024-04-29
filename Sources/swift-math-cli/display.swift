
import swift_math

protocol CustomDisplayable: ContextEvaluable {
	var displayString: String { get }
	var debugDisplayProperties: String { get }
}

extension _Node {
	var displayString: String {
		if let body = body as? any CustomDisplayable {
			return body.displayString
		}

		return "\(body.identifier)(\(children.map(\.displayString).joined(separator: ", ")))"
	}

	var debugDisplayStrings: [String] {
		let properties: String
		if let body = body as? any CustomDisplayable {
			properties = body.debugDisplayProperties
		} else {
			properties = String(describing: body)
		}

		return
			[String(describing: Body.self) + "(\(properties))"]
		+	children.flatMap(\.debugDisplayStrings).map { "  " + $0 }
	}
}
