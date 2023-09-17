
public protocol ArgContainer {
	typealias ArgKey = WritableKeyPath<Self, Argument>
	typealias ArgListKey = WritableKeyPath<Self, [Argument]>

	var prefix: ArgKey? { get }
	var arguments: [ArgKey] { get }
	var rest: ArgListKey? { get }
}

public extension ArgContainer {
	var prefix: ArgKey? { nil }
    var arguments: [ArgKey] { [] }
	var rest: ArgListKey? { nil }

	var hasPrefix: Bool { prefix != nil }
    var hasArguments: Bool { !arguments.isEmpty }
	var hasRest: Bool { rest != nil }
}

public struct EmptyArguments: ArgContainer {}

