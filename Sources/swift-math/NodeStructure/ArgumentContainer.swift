
public protocol ArgumentContainer {
	var hasPrefix: Bool { get }
	var hasArguments: Bool { get }
	var hasRest: Bool { get }

	var hasPriority: Bool { get }
	var priority: UInt? { get }

	var argumentCount: Int { get }

	var prefixNode: AnyNode? { get }
	var argumentNodes: [AnyNode] { get }
	var restNodes: [AnyNode]? { get }

	var prefixArgument: MathArgument? { get }
	var arguments: [MathArgument] { get }
	var restArgument: MathArgumentList? { get }
}

public extension ArgumentContainer {
	var hasPrefix: Bool { prefixArgument != nil }
	var hasArguments: Bool { argumentCount > 0 }
	var hasRest: Bool { restArgument != nil }
	var hasPriority: Bool { priority != nil }

	var argumentCount: Int { arguments.count }

	var prefixNode: AnyNode? { prefixArgument?.node }
	var argumentNodes: [AnyNode] { arguments.map(\.node) }
	var restNodes: [AnyNode]? { restArgument?.nodeList }
}
