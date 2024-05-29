
public extension NodeProtocol {
	var hasPrefix: Bool { body.arguments.prefixPath != nil }
	var hasArguments: Bool { !body.arguments.argumentsPath.isEmpty }
	var hasRest: Bool { body.arguments.restPath != nil }

	var argumentCount: Int { body.arguments.argumentsPath.count }

	var hasPriority: Bool { body is any PriorityEvaluable }
	var priority: UInt? { (body as? any PriorityEvaluable)?.priority }

	/*var prefixArgument: Argument? { body.arguments.prefixPath.map { body[keyPath: $0] } }
	var arguments: [Argument] { body.arguments.argumentsPath.map { body[keyPath: $0] } }
	var restArgument: ArgumentList? { body.arguments.restPath.map { body[keyPath: $0] } }*/

	var prefixNode: (any NodeProtocol)? { prefixPath.map { body.instance[keyPath: $0] }?.node }
	var argumentNodes: [any NodeProtocol] { argumentPath.map { body.instance[keyPath: $0].node } }
	var restNodes: [any NodeProtocol]? { restPath.map { body.instance[keyPath: $0] }?.map(\.node) }

	var prefixArgument: (any NodeProtocol, ArgumentData?)? {
		prefixPath.map {
			(body.instance[keyPath: $0].node, body.argumentInfo.data(for: $0))
		}
	}
	var arguments: [(any NodeProtocol, ArgumentData?)] {
		argumentPath.map {
			(body.instance[keyPath: $0].node, body.argumentInfo.data(for: $0))
		}
	}
	var restArgument: ([any NodeProtocol], ArgumentListData?)? {
		restPath.map {
			(body.instance[keyPath: $0].map(\.node), body.argumentInfo.data(for: $0))
		}
	}

	var prefixPath: ArgumentKey<Body>? { body.arguments.prefixPath }
	var argumentPath: [ArgumentKey<Body>] { body.arguments.argumentsPath }
	var restPath: ArgumentListKey<Body>? { body.arguments.restPath }
}
