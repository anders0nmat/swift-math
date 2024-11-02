
public final class VariableContainer {
	private struct Variable {
		var type: MathType?
		var value: MathValue?

		init(_ value: MathValue) {
			self.value = value
			self.type = value.type
		}

		init(type: MathType?) {
			self.value = nil
			self.type = type
		}
	}

	private var variables: [String: Variable] = [:]
	private unowned var owner: any NodeProtocol

	internal init(owner: any NodeProtocol) {
		self.owner = owner
	}

	private func setVariable(_ name: String, variable: Variable) {
		switch (variables.keys.contains(name), variables[name]?.type == variable.type, variable.value != nil) {
			case (false, _, _), (true, false, _):
				variables[name] = variable
				owner.contextChanged()
			case (true, true, false):
				return
			case (true, true, true):
				variables[name] = variable
		}
	}

	/**
		Declares a new variable with an optional type.
		
		Does not yet assign a value. If a value is already present, it is deleted if the type is different to `type`
	*/
	public func declare(_ name: String, type: MathType?) {
		setVariable(name, variable: .init(type: type))
	}

	/*
	Indicates if variable is known in scope
	*/
	public func isDeclared(_ name: String) -> Bool {
		variables.keys.contains(name)
	}

	/*
	Sets a variable to a value in the current scope. Automatically calls declare()
	*/
	public func set(_ name: String, to value: MathValue) {
		setVariable(name, variable: .init(value))
	}

	/*
	Retrieves the value of a variable if it exists.
	Walks the scope chain if necessary
	*/
	public func get(_ name: String) -> MathValue? {
		if let v = variables[name] {
			return v.value
		}
		return owner.parent?.variables.get(name)
	}

	/*
	Deletes a declared/defined variable in the current scope
	*/
	public func delete(_ name: String) {
		if let _ = variables.removeValue(forKey: name) {
			owner.contextChanged()
		}
	}

	/*
	Removes the value but keeps the declaration
	*/
	public func deleteValue(_ name: String) {
		variables[name]?.value = nil
	}

	/*
	Clears values and declarations
	*/
	public func clear() {
		variables = [:]
		owner.contextChanged()
	}

	/*
	Retrieves any type information about a variable if available
	*/
	public func getType(_ name: String) -> MathType? {
		if let v = variables[name] {
			return v.type
		}
		return owner.parent?.variables.getType(name)
	}

	/*
	Lists all declared variables available in the current scope.
	Hides shadowed variables. Results start with current scope.
	*/
	public func listDeclared() -> [String] {
		var namesSet = Set(variables.keys)
		var names = Array(variables.keys)

		let parentVariables = owner.parent?.variables.listDeclared().filter({ !namesSet.contains($0) }) ?? []
		namesSet.formUnion(parentVariables)
		names.append(contentsOf: parentVariables)

		return names
	}

	public func export() -> [String: MathValue] { variables.compactMapValues(\.value) }

	public func `import`(_ values: [String: MathValue]) {
		for (k, v) in values {
			set(k, to: v)
		}
	}
}
