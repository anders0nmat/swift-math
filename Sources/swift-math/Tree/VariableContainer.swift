
public final class VariableContainer {
	private var variables: [String: MathValue]
	private var variableTypes: [String: MathType?]
	private unowned var owner: AnyNode

	public init(owner: AnyNode) {
		self.variables = [:]
		self.variableTypes = [:]
		self.owner = owner
	}

	private func setType(_ name: String, type: MathType?) {
		let oldType = variableTypes.updateValue(type, forKey: name)
		if oldType != type {
			owner.contextChanged()
		}
	}

	/*
	Declares a new variable with an optional type. Does not yet assign a value.
	If a value is already present, it is deleted if the type is different to `type`
	*/
	public func declare(_ name: String, type: MathType?) {
		setType(name, type: type)
		if variables[name]?.type != type {
			variables.removeValue(forKey: name)
		}
	}

	/*
	Indicates if variable is known in scope
	*/
	public func isDeclared(_ name: String) -> Bool {
		variableTypes.keys.contains(name)
	}

	/*
	Sets a variable to a value in the current scope. Automatically calls declare()
	*/
	public func set(_ name: String, to value: MathValue) {
		setType(name, type: value.type)
		variables[name] = value
	}

	/*
	Retrieves the value of a variable if it exists.
	Walks the scope chain if necessary
	*/
	public func get(_ name: String) -> MathValue? {
		variables[name] ?? owner.parent?.variables.get(name)
	}

	/*
	Deletes a declared/defined variable in the current scope
	*/
	public func delete(_ name: String) {
		if let _ = variableTypes.removeValue(forKey: name) {
			owner.contextChanged()
		}
		deleteValue(name)
	}

	/*
	Removes the value but keeps the declaration
	*/
	public func deleteValue(_ name: String) {
		variables.removeValue(forKey: name)
	}

	/*
	Clears values and declarations
	*/
	public func clear() {
		variables = [:]
		variableTypes = [:]
		owner.contextChanged()
	}

	/*
	Clears all values but keeps declarations
	*/
	public func clearValues() {
		variables = [:]
	}

	/*
	Retrieves any type information about a variable if available
	*/
	public func getType(_ name: String) -> MathType? {
		variableTypes[name] ?? owner.parent?.variables.getType(name)
	}

	/*
	Lists all declared variables available in the current scope.
	Hides shadowed variables. Results start with current scope.
	*/
	public func listDeclared() -> [String] {
		var namesSet = Set(variableTypes.keys)
		var names = Array(variableTypes.keys)

		let parentVariables = owner.parent?.variables.listDeclared().filter({ !namesSet.contains($0) }) ?? []
		namesSet.formUnion(parentVariables)
		names.append(contentsOf: parentVariables)

		return names
	}

	public func export() -> [String: MathValue] { variables	}

	public func `import`(_ values: [String: MathValue]) {
		for (k, v) in values {
			set(k, to: v)
		}
	}
}
