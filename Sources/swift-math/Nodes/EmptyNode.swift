
public struct EmptyNode: Evaluable {
    public func evaluate() -> MathResult {
		.failure(.evalError(message: "Missing Argument"))
    }
}

public extension Node where Body == EmptyNode {
	static func empty() -> Self {
		Self(EmptyNode())
	}
}
