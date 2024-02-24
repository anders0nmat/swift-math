
public class VariableContainer {
	public var variables: [String: MathValue]
	public private(set) weak var parentScope: VariableContainer?

	public init() {
		self.variables = [:]
		self.parentScope = nil
	}

	public subscript(key: String) -> MathValue? {
		get {
			variables[key] ?? parentScope?[key]
		}
		set {
			variables[key] = newValue
		}
	}

	func inScope(_ parent: VariableContainer?) -> Self {
		self.parentScope = parent
		return self
	}

	public func listVariables() -> [String] {
		let keys = variables.keys
		let parentList = parentScope?.listVariables().filter({ !keys.contains($0) }) ?? []

		return parentList + keys
	}
}
