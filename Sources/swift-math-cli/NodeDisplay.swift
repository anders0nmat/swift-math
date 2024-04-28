
import swift_math

struct NodePrinter {
	private let defaultHandler = DefaultDisplay()
	private let handlers = [ObjectIdentifier: any NodeDisplayable](uniqueKeysWithValues: [
		InfixDisplay(),
		NumberDisplay(),
		ExpressionDisplay(),
		EmptyDisplay(),
		ConstantDisplay(),
		ListDisplay(),
		VariableDisplay(),
		IdentifierDisplay(),

		].map { (a: any NodeDisplayable) -> (ObjectIdentifier, any NodeDisplayable) in (a.type, a) }
	)


	func prettyDraw(node: AnyNode, current: AnyNode?) -> String {
		let node_id = ObjectIdentifier(type(of: node.body))
		let result: String
		if let handler = handlers[node_id] {
			result = handler.prettyDrawGeneric(node: node, printer: { prettyDraw(node: $0, current: current) })
		}
		else {
			result = defaultHandler.prettyDraw(node: node, printer: { prettyDraw(node: $0, current: current) })
		}

		return result.styled(node === current ? [.underline] : [])
	}

	func debugDraw(node: AnyNode, current: AnyNode?) -> [String] {
		let node_id = ObjectIdentifier(type(of: node.body))
		var result: [String]
		if let handler = handlers[node_id] {
			result = handler.debugDrawGeneric(node: node, printer: { debugDraw(node: $0, current: current) })
		}
		else {
			result = defaultHandler.debugDraw(node: node, printer: { debugDraw(node: $0, current: current) })
		}

		if node === current {
			let idx = result[0].firstIndex(where: {!$0.isWhitespace}) ?? result[0].startIndex
			let (a, b) = (result[0].prefix(upTo: idx), result[0].suffix(from: idx))
			result[0] = a + String(b).styled([.underline])		
		}

		return result
	}
}

protocol NodeDisplayable {
	associatedtype Body: ContextEvaluable

	func prettyDraw(node: Node<Body>, printer: (AnyNode)->String) -> String
	func debugDraw(node: Node<Body>, printer: (AnyNode)->[String]) -> [String]
}

extension NodeDisplayable {
	var type: ObjectIdentifier { ObjectIdentifier(Body.self) }

	func prettyDrawGeneric(node: AnyNode, printer: (AnyNode)->String) -> String {
		prettyDraw(node: node as! Node<Body>, printer: printer)
	}

	func debugDrawGeneric(node: AnyNode, printer: (AnyNode)->[String]) -> [String] {
		debugDraw(node: node as! Node<Body>, printer: printer)
	}

	func prettyDraw(node: Node<Body>, printer: (AnyNode)->String) -> String {
		DefaultDisplay().prettyDraw(node: node, printer: printer)
	}

	func debugDraw(node: Node<Body>, printer: (AnyNode)->[String]) -> [String] { 
		DefaultDisplay().debugDraw(node: node, printer: printer)
	}
}

func bodyType(of node: AnyNode) -> String {
		String(describing: type(of: node.body))
	}

func constructorString(of node: AnyNode, params: [(String, String)]) -> [String] {
	["\(bodyType(of: node))(" +
	params.map {"\($0.0): \($0.1)"}.joined(separator: ", ") +
	")"]
}

func debugChildren(of node: AnyNode, printer: (AnyNode)->[String]) -> [String] {
	node.children.flatMap(printer).map {"  " + $0}
}

struct DefaultDisplay {
	func prettyDraw(node: AnyNode, printer: (AnyNode) -> String) -> String {
		"\(node.body.identifier)(\(node.children.map(printer).joined(separator: ", ")))"
	}

	func debugDraw(node: AnyNode, printer: (AnyNode) -> [String]) -> [String] {
		[bodyType(of: node) + "(...)"] + debugChildren(of: node, printer: printer)
	}
}

struct InfixDisplay: NodeDisplayable {
	typealias Body = Operator.Infix
    func prettyDraw(node: Node<Body>, printer: (AnyNode) -> String) -> String {
		node.children.map(printer).joined(separator: " \(node.body.identifier) ")
    }

	func debugDraw(node: Node<Body>, printer: (AnyNode) -> [String]) -> [String] {
		return constructorString(of: node, params: [
			("identifier", node.body.identifier),
			("priority", String(node.body.priority)),
		]) + debugChildren(of: node, printer: printer)
	}
}

struct NumberDisplay: NodeDisplayable {
	typealias Body = Operator.Number
	func prettyDraw(node: Node<Body>, printer: (AnyNode) -> String) -> String {
		node.body.numberString
	}

	func debugDraw(node: Node<Body>, printer: (AnyNode) -> [String]) -> [String] {
		return constructorString(of: node, params: [
			("numberString", node.body.numberString),
			("sign", String(describing: node.body.sign)),
			("value", String(describing: node.body.value)),
			("decimal", String(describing: node.body.decimal)),
		])
	}
}

struct ExpressionDisplay: NodeDisplayable {
	typealias Body = Operator.Expression
	func prettyDraw(node: Node<Body>, printer: (AnyNode) -> String) -> String {
		": " + printer(node.children[0])
	}

	func debugDraw(node: Node<Body>, printer: (AnyNode) -> [String]) -> [String] {
		return constructorString(of: node, params: [
			("variables", String(describing: node.variables))
		]) + debugChildren(of: node, printer: printer)
	}
}

struct EmptyDisplay: NodeDisplayable {
	typealias Body = Operator.Empty
	func prettyDraw(node: Node<Body>, printer: (AnyNode) -> String) -> String {
		"[---]"
	}

	func debugDraw(node: Node<Body>, printer: (AnyNode) -> [String]) -> [String] {
		constructorString(of: node, params: [])
	}
}

struct ConstantDisplay: NodeDisplayable {
	typealias Body = Operator.Constant
	func prettyDraw(node: Node<Body>, printer: (AnyNode) -> String) -> String {
		node.body.displayName
	}

	func debugDraw(node: Node<Body>, printer: (AnyNode) -> [String]) -> [String] {
		let value = switch node.body.value {
			case .list(let l): ".list(\(l))"
			case .number(let n): ".number(\(n))"
			case .identifier(let s): ".identifier(\(s))"
		}
		return constructorString(of: node, params: [
			("displayName", node.body.displayName),
			("value", value),
		])
	}
}

struct ListDisplay: NodeDisplayable {
	typealias Body = Operator.List
	func prettyDraw(node: Node<Body>, printer: (AnyNode) -> String) -> String {
		"[\(node.children.map(printer).joined(separator: ", "))]"
	}

	func debugDraw(node: Node<Body>, printer: (AnyNode) -> [String]) -> [String] {
		constructorString(of: node, params: []) + debugChildren(of: node, printer: printer)
	}
}

struct VariableDisplay: NodeDisplayable {
	typealias Body = Operator.Variable
	func prettyDraw(node: Node<Body>, printer: (AnyNode) -> String) -> String {
		node.body.name
	}

	func debugDraw(node: Node<Body>, printer: (AnyNode) -> [String]) -> [String] {
		constructorString(of: node, params: [
			("name", node.body.name)
		])
	}
}

struct IdentifierDisplay: NodeDisplayable {
	typealias Body = Operator.Identifier
	func prettyDraw(node: Node<Body>, printer: (AnyNode) -> String) -> String {
		"\"\(node.body.name)\""
	}

	func debugDraw(node: Node<Body>, printer: (AnyNode) -> [String]) -> [String] {
		return constructorString(of: node, params: [
			("identifier", node.body.name),
		])
	}	
}

