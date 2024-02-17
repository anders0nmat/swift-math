
public struct EmptyNode: Evaluable {
    public func evaluate() throws -> MathValue {
		throw MathError.missingArgument
    }
}

public extension Node where Body == EmptyNode {
	static func empty() -> Self {
		Self(EmptyNode())
	}
}
