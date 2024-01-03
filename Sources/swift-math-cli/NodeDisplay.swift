
import swift_math

struct NodePrinter {
	private let defaultHandler = DefaultDisplay()
	private let handlers: [ObjectIdentifier:NodeDisplayable] = [
		ObjectIdentifier(InfixNode.self) : InfixDisplay(),
		ObjectIdentifier(NumberNode.self) : NumberDisplay(),
		ObjectIdentifier(ExpressionNode.self) : ExpressionDisplay(),
		ObjectIdentifier(EmptyNode.self) : EmptyDisplay(),
		ObjectIdentifier(ConstantNode.self) : ConstantDisplay(),
	]

	func prettyDraw(node: AnyNode, current: AnyNode?) -> String {
		let node_id = ObjectIdentifier(type(of: node.body))
		let result: String = 
			(handlers[node_id] ?? defaultHandler)
			.prettyDraw(node: node, printer: { prettyDraw(node: $0, current: current) })

		return result.styled(node === current ? [.underline] : [])
	}

	internal func _debugDraw(node: AnyNode, current: AnyNode) -> [String] {
		let node_id = ObjectIdentifier(type(of: node.body))
		let result = 
			(handlers[node_id] ?? defaultHandler)
			.debugDraw(node: node, printer: { _debugDraw(node: $0, current: current) })
		return result
	}

	func debugDraw(node: AnyNode, current: AnyNode) -> String {
		return ""
	}
}

protocol NodeDisplayable {
	func prettyDraw(node: AnyNode, printer: (AnyNode)->String) -> String
	func debugDraw(node: AnyNode, printer: (AnyNode)->[String]) -> [String]
}

extension NodeDisplayable {
	func debugDraw(node: AnyNode, printer: (AnyNode)->[String]) -> [String] { [] }
}

struct DefaultDisplay: NodeDisplayable {
	func prettyDraw(node: AnyNode, printer: (AnyNode) -> String) -> String {
		"\(node.body.displayName)(\(node.children.map(printer).joined(separator: ", ")))"
	}
}

struct InfixDisplay: NodeDisplayable {
    func prettyDraw(node: AnyNode, printer: (AnyNode) -> String) -> String {
		node.children.map(printer).joined(separator: " \(node.body.displayName) ")
    }
}

struct NumberDisplay: NodeDisplayable {
	func prettyDraw(node: AnyNode, printer: (AnyNode) -> String) -> String {
		(node as! Node<NumberNode>).body.numberString
	}
}

struct ExpressionDisplay: NodeDisplayable {
	func prettyDraw(node: AnyNode, printer: (AnyNode) -> String) -> String {
		": " + printer(node.children[0])
	}
}

struct EmptyDisplay: NodeDisplayable {
	func prettyDraw(node: AnyNode, printer: (AnyNode) -> String) -> String {
		"[---]"
	}
}

struct ConstantDisplay: NodeDisplayable {
	func prettyDraw(node: AnyNode, printer: (AnyNode) -> String) -> String {
		node.body.displayName
	}
}

