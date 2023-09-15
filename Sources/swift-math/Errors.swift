
public enum MathError: Error, Equatable {
	case evalError(message: String, at: AnyNode? = nil)
	case argumentType(at: AnyNode? = nil)

	mutating func setNode(_ node: AnyNode) {
		switch self {
			case let .evalError(msg, nil): self = .evalError(message: msg, at: node)
			case .argumentType(nil): self = .argumentType(at: node)
			default: break
		}
	}

	public static func ==(lhs: MathError, rhs: MathError) -> Bool {
		switch (lhs, rhs) {
			case let (.evalError(msg1, node1), .evalError(msg2, at: node2)):
				return msg1 == msg2 && node1 === node2
			case let (.argumentType(node1), .argumentType(node2)):
				return node1 === node2
			default: return false
		}
	}
}
