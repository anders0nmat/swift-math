
/**
	Type-erasing Container for Nodes, providing codable conformance

	This type serves as glue between nodes in the syntax tree, allowing for Codable conformance.

	`Node<Body: ContextEvaluable>` cannot conform to Codable because of the `init(from decoder:)` requirement
	which would need `Body` to be known before decoding. This type defers that by taking a en-/decoder context
	for looking up concrete Operators from the `identifier`-Key.
	This Type is used everywhere a node is expected from the user (e.g. arguments to a function).
*/
public struct AnyNode {
	public internal(set) var node: any NodeProtocol

	public init() {
		self.node = Node.empty()
	}

	public init(_ node: any NodeProtocol) {
		self.node = node
	}

	public init?(_ node: (any NodeProtocol)?) {
		guard let node else { return nil }
		self.node = node
	}

	public var variables: VariableContainer { node.variables }

	public var returnType: MathType? { node.returnType }
	public func evaluate() throws -> MathValue { try node.evaluate() }
}

fileprivate extension ContextEvaluable {
	mutating func decodeInstance(from decoder: any Decoder) throws {
		self.instance = try Storage(from: decoder)
	}
}

fileprivate extension NodeProtocol {
	func decodeInstance(from decoder: any Decoder) throws {
		try self.body.decodeInstance(from: decoder)
	}
}

public extension CodingUserInfoKey {
	static let mathOperators = Self(rawValue: "swift_math.AnyNode.operators")!
	static let mathParser = Self(rawValue: "swift_math.AnyNode.parser")!
}

extension AnyNode: Codable {
	internal enum DecodingError: Error {
		case operatorContextMissing
		case unknownOperator(identifier: String)
	}

	internal enum AnyNodeKeys: String, CodingKey {
		case identifier
		case body
		case current
	}

	public init(from decoder: any Decoder) throws {
		guard let operators = decoder.userInfo[.mathOperators] as? [String : any ContextEvaluable] else {
			throw DecodingError.operatorContextMissing
		}
		let container = try decoder.container(keyedBy: AnyNodeKeys.self)
		let identifier = try container.decode(String.self, forKey: .identifier)
		guard let op = operators[identifier] else {
			throw DecodingError.unknownOperator(identifier: identifier)
		}

		// Careful with the order of the following operations. 
		// decodeInstance() triggers the set-handler on Node.body which assigns .parent,
		// updates .returnType and propagates the childrenChanged().
		// We want this in order to correctly signal and set up parent/children nodes.
		self.init(op.makeNode())
		if !(op.instance is EmptyStorage) {
			try self.node.decodeInstance(from: container.superDecoder(forKey: .body))
		}

		guard let parser = decoder.userInfo[.mathParser] as? TreeParser else { return }

		let isActive = try container.decodeIfPresent(Bool.self, forKey: .current)
		if isActive == true {
			parser.current = node
		}
	}

	public func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: AnyNodeKeys.self)
		try container.encode(node.body.identifier, forKey: .identifier)
		if !(node.body.instance is EmptyStorage) {
			let superEncoder = container.superEncoder(forKey: .body)
			try node.body.instance.encode(to: superEncoder)
		}

		guard let parser = encoder.userInfo[.mathParser] as? TreeParser else { return }

		if parser.current === node {
			try container.encode(true, forKey: .current)
		}
	}
}

extension Array where Element == AnyNode {
	func firstIndex(of node: AnyNode) -> Index? { firstIndex(where: { $0.node === node.node }) }
	func firstIndex(of node: any NodeProtocol) -> Index? { firstIndex(where: { $0.node === node }) }
	func contains(_ node: AnyNode) -> Bool { contains(where: { $0.node === node.node }) }
	func contains(_ node: any NodeProtocol) -> Bool { contains(where: { $0.node === node }) }
}
