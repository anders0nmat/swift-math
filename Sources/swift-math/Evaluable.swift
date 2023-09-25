
public protocol Evaluable {
	var prefixPath: ArgumentKey<Self>? { get }
	var argumentsPath: [ArgumentKey<Self>] { get }
	var restPath: Never? { get }

	func evaluate() -> MathResult
}

public extension Evaluable {
	var prefixPath: ArgumentKey<Self>? { nil }
	var argumentsPath: [ArgumentKey<Self>] { [] }
	var restPath: Never? { fatalError() }

	var hasPrefix: Bool { self.prefixPath != nil }
	var hasRest: Bool { self.restPath != nil }
}

