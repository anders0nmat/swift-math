
public protocol Evaluable {
	associatedtype Arguments: ArgContainer = EmptyArguments

	func evaluate(args: Arguments) -> MathResult
}

public protocol ArgContainer {
	typealias ArgKey = WritableKeyPath<Self, Argument>
	typealias ArgListKey = WritableKeyPath<Self, [Argument]>

	var prefix: ArgKey? { get }
	var arguments: [ArgKey] { get }
	var rest: ArgListKey? { get }

	init()
}

public extension ArgContainer {
	var prefix: ArgKey? { nil }
	var rest: ArgListKey? { nil }

	var hasPrefix: Bool { prefix != nil }
	var hasRest: Bool { rest != nil }
}

public struct EmptyArguments: ArgContainer {
	public var arguments: [ArgKey] { [] }

	public init() {}
}
