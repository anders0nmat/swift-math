
import swift_math

protocol CustomDisplayable: ContextEvaluable {
	var displayString: String { get }
	var debugDisplayProperties: String { get }
}

var currentNode: AnyNode?

extension _Node {
	var displayString: String {
		if let body = body as? any CustomDisplayable {
			return body.displayString.styled(self === currentNode ? [.underline] : [])
		}

		return "\(body.identifier)(\(children.map(\.displayString).joined(separator: ", ")))".styled(self === currentNode ? [.underline] : [])
	}

	var debugDisplayStrings: [String] {
		let properties: String
		if let body = body as? any CustomDisplayable {
			properties = body.debugDisplayProperties
		} else {
			properties = String(describing: body)
		}


		return
			[(String(describing: Body.self) + "(\(properties))").styled(self === currentNode ? [.underline] : [])]
		+	children.flatMap(\.debugDisplayStrings).map { "  " + $0 }
	}
}
