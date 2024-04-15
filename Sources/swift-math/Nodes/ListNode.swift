
public struct ListNode: Evaluable {
	public var identifier: String { "#list" }
	public var arguments = ArgumentPath(rest: \.entries)

	public internal(set) var entries = ArgumentList()

	public init() {}

    public func evaluate() throws -> MathValue {
        var list = MathList()

		for e in entries.nodeList {
			try list.append(e.evaluate())
		}

		return .list(list)
    }

	public func evaluateType() -> MathType? {
		if entries.nodeList.isEmpty {
			return .list(nil)
		}
		let entryType = entries.nodeList.map { $0.returnType }
		if let firstType = entryType.first, let firstType, entryType.allSatisfy({ $0 == firstType }) {
			return .list(firstType)
		}
		return nil
	}
}