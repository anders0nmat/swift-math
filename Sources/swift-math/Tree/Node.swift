
/**
	Container for Operators. Stored in a tree structure

	Allows for composition of operators, aswell as
	providing behavior for interaction with and between operators.
	Manages updates to the tree and optionally notifies observers.
	Accessing any Operator in a syntax tree should happen through its `Node`-object
	to allow for correct signalling- and linking behavior.
*/
public final class Node<Body: ContextEvaluable>: NodeProtocol {
	public weak var parent: (any NodeProtocol)?
	public var root: any NodeProtocol { parent?.root ?? self }
	public var observers: [NodeEventCallback] = []
	
	internal var _body: Body
	public var body: Body {
		get { _body }
		set {
			_body = newValue
			linkChildren()
			updateReturnType()
			fire(event: .body)
		}
	}

	public var children: [any NodeProtocol] {
		get {
				(prefixNode.map { [$0] } ?? [])
			+	(argumentNodes)
			+	(restNodes ?? [])
		}
		set {
			var iterator = newValue.makeIterator()

			if let prefixPath {
				_body.instance[keyPath: prefixPath].node = iterator.next() ?? Operator.Empty.node()
			}

			argumentPath.forEach {
				_body.instance[keyPath: $0].node = iterator.next() ?? Operator.Empty.node()
			}

			if let restPath {
				_body.instance[keyPath: restPath] = Array(iterator).map { AnyNode($0) }
			}

			linkChildren()
			fire(event: .children)
		}
	}

	public var variables: VariableContainer!

	public private(set) var returnType: MathType?

	public init(_ body: Body, parent: (any NodeProtocol)? = nil) {
		self.parent = parent
		self._body = body
		
		self.variables = VariableContainer(owner: self)
		self.returnType = _body.evaluateType(in: self)
		linkChildren()
	}

	public func evaluate() throws -> MathValue {
		do {
			return try _body.evaluate(in: self)
		}
		catch let e as MathErrorContainer { throw e }
		catch let e as MathError { throw MathErrorContainer(error: e, origin: self) }
		catch let e { throw MathErrorContainer(error: .unknown(e), origin: self) }
	}

	public func replace(child node: any NodeProtocol, with new: any NodeProtocol) {
		guard node.parent === self else { return }

		new.parent = self
		new.contextChanged()
		// Old approach, quick'n'dirty but calls all listeners of body regardless of need
		//children = children.map { $0 === node ? new : $0 }

		if let prefixPath = _body.arguments.prefixPath, _body.instance[keyPath: prefixPath].node === node {
			_body.instance[keyPath: prefixPath].node = new
		}

		_body.arguments.argumentsPath.forEach {
			if _body.instance[keyPath: $0].node === node {
				_body.instance[keyPath: $0].node = new
			}
		}

		if let restPath = _body.arguments.restPath, _body.instance[keyPath: restPath].contains(where: {$0.node === node}) {
			_body.instance[keyPath: restPath] = _body.instance[keyPath: restPath].map { $0.node === node ? AnyNode(new) : $0 } 
		}

		childrenChanged()
	}

	public func replaceSelf(with new: any NodeProtocol) { parent?.replace(child: self, with: new) }

	internal func linkChildren() { children.forEach { $0.parent = self } }

	private func updateReturnType() {
		let newReturnType = _body.evaluateType(in: self)
		if returnType != newReturnType {
			returnType = newReturnType
			parent?.childrenChanged()
		}	
	}

	private var isChanging = false

	public func childrenChanged() {
		if isChanging { return }
		isChanging = true
		
		_body.childrenChanged()
		
		isChanging = false
		updateReturnType()
		fire(event: .children)
	}

	public func contextChanged() {
		children.forEach { $0.contextChanged() }

		_body.contextChanged()

		updateReturnType()
		fire(event: .context)
	}
}

extension Node: CustomStringConvertible {
	public var description: String {
		"<Node \(Body.self) \"\(_body.identifier)\">"
	}
}

extension Node: CustomDebugStringConvertible {
	public var debugDescription: String {
		"Node(body: \(_body))"
	}
}

extension NodeProtocol {
	func findNodes<T: ContextEvaluable>(with type: T.Type) -> [Node<T>] {
		(Body.self == type ? [self as! Node<T>] : [])
		+ children.flatMap {
			$0.findNodes(with: type)
		}
	} 
}


