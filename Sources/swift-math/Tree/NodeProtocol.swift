
public protocol NodeProtocol: AnyObject {
	associatedtype Body: ContextEvaluable

	var parent: (any NodeProtocol)? { get set }
	var root: any NodeProtocol { get }

	var body: Body { get set }
	var children: [any NodeProtocol] { get set }

	var observers: [NodeEventCallback] { get set }

	var variables: VariableContainer! { get }

	var returnType: MathType? { get }

	func evaluate() throws -> MathValue

	func replace(child node: any NodeProtocol, with new: any NodeProtocol)
	func replaceSelf(with new: any NodeProtocol)

	func childrenChanged()
	func contextChanged()
}

extension Array where Element == any NodeProtocol {
	func firstIndex(of node: any NodeProtocol) -> Index? { firstIndex(where: { $0 === node }) }
	func contains(_ node: any NodeProtocol) -> Bool { contains(where: { $0 === node }) }
}
