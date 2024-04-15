
public extension _Node {
	var hasPrefix: Bool { body.arguments.prefixPath != nil }
	var hasArguments: Bool { !body.arguments.argumentsPath.isEmpty }
	var hasRest: Bool { body.arguments.restPath != nil }

	var argumentCount: Int { body.arguments.argumentsPath.count }

	var hasPriority: Bool { Body.self is any PriorityEvaluable }
	var priority: UInt? { (body as? any PriorityEvaluable)?.priority }

	var prefixArgument: Argument? { body.arguments.prefixPath.map { body[keyPath: $0] } }
	var arguments: [Argument] { body.arguments.argumentsPath.map { body[keyPath: $0] } }
	var restArgument: ArgumentList? { body.arguments.restPath.map { body[keyPath: $0] } }

	var prefixNode: AnyNode? { prefixArgument?.node }
	var argumentNodes: [AnyNode] { arguments.map(\.node) }
	var restNodes: [AnyNode]? { restArgument?.nodeList }

	var prefixPath: ArgumentKey<Body>? { body.arguments.prefixPath }
	var argumentPath: [ArgumentKey<Body>] { body.arguments.argumentsPath }
	var restPath: ArgumentListKey<Body>? { body.arguments.restPath }
}
