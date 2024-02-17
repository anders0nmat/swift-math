
import swift_math

struct NodePrinter {
	private let defaultHandler = DefaultDisplay()
	private let handlers: [ObjectIdentifier:NodeDisplayable] = [
		ObjectIdentifier(InfixNode.self) : InfixDisplay(),
		ObjectIdentifier(NumberNode.self) : NumberDisplay(),
		ObjectIdentifier(ExpressionNode.self) : ExpressionDisplay(),
		ObjectIdentifier(EmptyNode.self) : EmptyDisplay(),
		ObjectIdentifier(ConstantNode.self) : ConstantDisplay(),
		ObjectIdentifier(ListNode.self) : ListDisplay(),
		ObjectIdentifier(VariableNode.self) : VariableDisplay(),
		ObjectIdentifier(IdentifierNode.self) : IdentifierDisplay(),
	]

	func prettyDraw(node: AnyNode, current: AnyNode?) -> String {
		let node_id = ObjectIdentifier(type(of: node.body))
		let result: String = 
			(handlers[node_id] ?? defaultHandler)
			.prettyDraw(node: node, printer: { prettyDraw(node: $0, current: current) })

		return result.styled(node === current ? [.underline] : [])
	}

	func debugDraw(node: AnyNode, current: AnyNode?) -> [String] {
		let node_id = ObjectIdentifier(type(of: node.body))
		var result = 
			(handlers[node_id] ?? defaultHandler)
			.debugDraw(node: node, printer: { debugDraw(node: $0, current: current) })

		if node === current {
			let idx = result[0].firstIndex(where: {!$0.isWhitespace}) ?? result[0].startIndex
			let (a, b) = (result[0].prefix(upTo: idx), result[0].suffix(from: idx))
			result[0] = a + String(b).styled([.underline])		
		}

		return result
	}
}

protocol NodeDisplayable {
	func prettyDraw(node: AnyNode, printer: (AnyNode)->String) -> String
	func debugDraw(node: AnyNode, printer: (AnyNode)->[String]) -> [String]
}

extension NodeDisplayable {
	func prettyDraw(node: AnyNode, printer: (AnyNode)->String) -> String {
		DefaultDisplay().prettyDraw(node: node, printer: printer)
	}

	func debugDraw(node: AnyNode, printer: (AnyNode)->[String]) -> [String] { 
		DefaultDisplay().debugDraw(node: node, printer: printer)
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
}

struct DefaultDisplay: NodeDisplayable {
	func prettyDraw(node: AnyNode, printer: (AnyNode) -> String) -> String {
		"\(node.body.displayName)(\(node.children.map(printer).joined(separator: ", ")))"
	}

	func debugDraw(node: AnyNode, printer: (AnyNode) -> [String]) -> [String] {
		[bodyType(of: node) + "(...)"] + debugChildren(of: node, printer: printer)
	}
}

struct InfixDisplay: NodeDisplayable {
    func prettyDraw(node: AnyNode, printer: (AnyNode) -> String) -> String {
		node.children.map(printer).joined(separator: " \(node.body.displayName) ")
    }

	func debugDraw(node: AnyNode, printer: (AnyNode) -> [String]) -> [String] {
		let body = (node.body as! InfixNode)
		return constructorString(of: node, params: [
			("displayName", body.displayName),
			("priority", String(body.priority)),
		]) + debugChildren(of: node, printer: printer)
	}
}

struct NumberDisplay: NodeDisplayable {
	func prettyDraw(node: AnyNode, printer: (AnyNode) -> String) -> String {
		(node as! Node<NumberNode>).body.numberString
	}

	func debugDraw(node: AnyNode, printer: (AnyNode) -> [String]) -> [String] {
		let body = (node.body as! NumberNode)
		return constructorString(of: node, params: [
			("numberString", body.numberString),
			("sign", String(describing: body.sign)),
			("value", String(describing: body.value)),
			("decimal", String(describing: body.decimal)),
		])
	}
}

struct ExpressionDisplay: NodeDisplayable {
	func prettyDraw(node: AnyNode, printer: (AnyNode) -> String) -> String {
		": " + printer(node.children[0])
	}

	func debugDraw(node: AnyNode, printer: (AnyNode) -> [String]) -> [String] {
		return constructorString(of: node, params: [
			("variables", String(describing: (node as! Node<ExpressionNode>).variables))
		]) + debugChildren(of: node, printer: printer)
	}
}

struct EmptyDisplay: NodeDisplayable {
	func prettyDraw(node: AnyNode, printer: (AnyNode) -> String) -> String {
		"[---]"
	}

	func debugDraw(node: AnyNode, printer: (AnyNode) -> [String]) -> [String] {
		constructorString(of: node, params: [])
	}
}

struct ConstantDisplay: NodeDisplayable {
	func prettyDraw(node: AnyNode, printer: (AnyNode) -> String) -> String {
		node.body.displayName
	}

	func debugDraw(node: AnyNode, printer: (AnyNode) -> [String]) -> [String] {
		let body = (node.body as! ConstantNode)
		let value = switch body.value {
			case .list(let l): ".list(\(l))"
			case .number(let n): ".number(\(n))"
			case .identifier(let s): ".identifier(\(s))"
		}
		return constructorString(of: node, params: [
			("displayName", body.displayName),
			("value", value),
		])
	}
}

struct ListDisplay: NodeDisplayable {
	func prettyDraw(node: AnyNode, printer: (AnyNode) -> String) -> String {
		"[\(node.children.map(printer).joined(separator: ", "))]"
	}

	func debugDraw(node: AnyNode, printer: (AnyNode) -> [String]) -> [String] {
		constructorString(of: node, params: []) + debugChildren(of: node, printer: printer)
	}
}

struct VariableDisplay: NodeDisplayable {
	func prettyDraw(node: AnyNode, printer: (AnyNode) -> String) -> String {
		(node.body as! VariableNode).name
	}

	func debugDraw(node: AnyNode, printer: (AnyNode) -> [String]) -> [String] {
		constructorString(of: node, params: [
			("name", (node.body as! VariableNode).name)
		])
	}
}

struct IdentifierDisplay: NodeDisplayable {
	func prettyDraw(node: AnyNode, printer: (AnyNode) -> String) -> String {
		"\"\((node.body as! IdentifierNode).identifier)\""
	}

	func debugDraw(node: AnyNode, printer: (AnyNode) -> [String]) -> [String] {
		let body = (node.body as! IdentifierNode)
		return constructorString(of: node, params: [
			("identifier", body.identifier),
		])
	}	
}

