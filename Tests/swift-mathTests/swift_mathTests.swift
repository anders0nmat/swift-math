import XCTest
@testable import swift_math

final class NodeTest: XCTestCase {
	enum BodyEvent: Equatable {
		case context
		case children
	}

	struct TestBody: Evaluable {
		var identifier: String { "" }
		var pre = Argument()
		var arg1 = Argument()
		var arg2 = Argument()
		var res = ArgumentList()

		var arguments = ArgumentPath(
			prefix: \.pre,
			arguments: \.arg1, \.arg2,
			rest: \.res)

		var eventSink: ((BodyEvent, AnyNode?) -> Void)?

		func evaluate() throws -> MathValue { .number(0) }

		func childrenChanged() { eventSink?(.children, pre.node.parent) }
		func contextChanged() { eventSink?(.context, pre.node.parent) }
	}

	func testChildProperty() throws {
		let parent = Node(TestBody())

		XCTAssertEqual(parent.children.count, 3)
		XCTAssertEqual(parent.body.res.nodeList.count, 0)

		XCTAssert(parent.children[0] is Node<Operator.Empty>)
		XCTAssert(parent.children[1] is Node<Operator.Empty>)
		XCTAssert(parent.children[2] is Node<Operator.Empty>)

		XCTAssertIdentical(parent.children[0], parent.body.pre.node)
		XCTAssertIdentical(parent.children[1], parent.body.arg1.node)
		XCTAssertIdentical(parent.children[2], parent.body.arg2.node)

		XCTAssertNotIdentical(parent.children[0], parent.children[1])
		XCTAssertNotIdentical(parent.children[0], parent.children[2])
		XCTAssertNotIdentical(parent.children[1], parent.children[2])

		let newChild = Node.empty()
		parent.children = [newChild]

		XCTAssertEqual(parent.children.count, 3)
		XCTAssertIdentical(newChild, parent.body.pre.node)
		XCTAssertIdentical(newChild, parent.children[0])
		XCTAssertIdentical(newChild.parent, parent)
		XCTAssertIdentical(newChild.root, parent)
		XCTAssertIdentical(newChild.root, parent.root)

		let c1 = Node.empty()
		let c2 = Node.empty()
		let c3 = Node.empty()
		let c4 = Node.empty()
		let c5 = Node.empty()

		parent.children = [c1, c2, c3, c4, c5]

		XCTAssertEqual(parent.children.count, 5)
		XCTAssertEqual(parent.body.res.nodeList.count, 2)
		
		XCTAssertIdentical(c1, parent.body.pre.node)
		XCTAssertIdentical(c2, parent.body.arg1.node)
		XCTAssertIdentical(c3, parent.body.arg2.node)
		XCTAssertIdentical(c4, parent.body.res.nodeList[0])
		XCTAssertIdentical(c5, parent.body.res.nodeList[1])

		XCTAssertIdentical(c1.parent, parent)
		XCTAssertIdentical(c2.parent, parent)
		XCTAssertIdentical(c3.parent, parent)
		XCTAssertIdentical(c4.parent, parent)
		XCTAssertIdentical(c5.parent, parent)

		XCTAssertIdentical(c1, parent.children[0])
		XCTAssertIdentical(c2, parent.children[1])
		XCTAssertIdentical(c3, parent.children[2])
		XCTAssertIdentical(c4, parent.children[3])
		XCTAssertIdentical(c5, parent.children[4])

		parent.children = []

		XCTAssertEqual(parent.children.count, 3)
		XCTAssertEqual(parent.body.res.nodeList.count, 0)
		XCTAssert(parent.children[0] is Node<Operator.Empty>)
		XCTAssert(parent.children[1] is Node<Operator.Empty>)
		XCTAssert(parent.children[2] is Node<Operator.Empty>)

		XCTAssertNotIdentical(parent.children[0], parent.children[1])
		XCTAssertNotIdentical(parent.children[0], parent.children[2])
		XCTAssertNotIdentical(parent.children[1], parent.children[2])
	}

	func testReplace() throws {
		let parent = Node(TestBody())
		let c1 = Node.empty()

		parent.replace(child: parent.body.pre.node, with: c1)

		XCTAssertIdentical(parent.body.pre.node, c1)
		XCTAssertIdentical(c1.parent, parent)

		let c2 = Node.empty()

		parent.replace(child: parent.body.arg1.node, with: c2)

		XCTAssertIdentical(parent.body.arg1.node, c2)
		XCTAssertIdentical(c2.parent, parent)

		let c3 = Node.empty()
		let newC3 = Node.empty()

		parent.children.append(c3)

		XCTAssertEqual(parent.body.res.nodeList.count, 1)
		XCTAssertIdentical(parent.body.res.nodeList[0], c3)

		parent.replace(child: c3, with: newC3)

		XCTAssertEqual(parent.body.res.nodeList.count, 1)
		XCTAssertIdentical(parent.body.res.nodeList[0], newC3)
		XCTAssertIdentical(newC3.parent, parent)


		let other = Node.empty()
		let newOther = Node.empty()

		let before = parent.children

		parent.replace(child: other, with: newOther)

		XCTAssertNotIdentical(other.parent, parent)
		XCTAssertNotIdentical(newOther.parent, parent)
		XCTAssert(zip(before, parent.children).allSatisfy(===))
	}

	func testBodyEvents() throws {
		var events: [(BodyEvent, ObjectIdentifier)] = []
		let eventCallback = { (kind: BodyEvent, node: AnyNode?) in
			events.append((kind, ObjectIdentifier(node!)))
		}

		let parent = Node(TestBody(eventSink: eventCallback))
		let c1 = Node(TestBody(eventSink: eventCallback))
		let c2 = Node(TestBody(eventSink: eventCallback))

		parent.children[1].replaceSelf(with: c1)

		events = []

		c1.children[0].replaceSelf(with: c2)

		let wantedEventLog: [(BodyEvent, ObjectIdentifier)] = [
			(.context, ObjectIdentifier(c2)),
			(.children, ObjectIdentifier(c1)),
		]

		XCTAssert(zip(events, wantedEventLog).allSatisfy(==))
	}

	func testEvents() throws { /* TODO */ }
}

final class TreeTest: XCTestCase {
	func makeParser() -> TreeParser {
		TreeParser(operators: Operator.allOperators)
	}

	func testInsertNodes() throws {
		let root = Node.expression()
		let child1 = Node.expression()
		let child2 = Node.expression()

		root.body.expr.node.replaceSelf(with: child1)
		child1.body.expr.node.replaceSelf(with: child2)

		XCTAssertIdentical(root, child1.parent)
		XCTAssertIdentical(child1, child2.parent)
		XCTAssertIdentical(root, child1.root)
		XCTAssertIdentical(root, child2.root)

		XCTAssertIdentical(root.body.expr.node, child1)
		XCTAssertIdentical(child1.body.expr.node, child2)

		root.body.expr.node.replaceSelf(with: child2)

		XCTAssertIdentical(root, child2.parent)
		XCTAssertIdentical(root, child2.root)
		XCTAssertIdentical(root.body.expr.node, child2)
	}

	func testPrefixNodes() throws {
		let root = Operator.PrefixFunction(identifier: "", function: *).makeNode() as! Node<Operator.PrefixFunction>
		let child1 = Node.expression()
		let child2 = Node.expression()

		root.children = [child1, child2]

		XCTAssertIdentical(root.body.prefixArg.node, child1)
		XCTAssertIdentical(root.body.args[0].node, child2)
		XCTAssertIdentical(root, child1.parent)
		XCTAssertIdentical(root, child2.parent)
		XCTAssertIdentical(root, child1.root)
		XCTAssertIdentical(root, child2.root)
	}

	func testRestNodes() throws {
		let root = Operator.Infix(priority: 1, identifier: "", functions: FunctionContainer { 
			$0.addFunction({(a: Type.Number, b: Type.Number) in a + b})
		}).makeNode() as! Node<Operator.Infix>
		let child1 = Node.expression()
		let child2 = Node.expression()
		let child3 = Node.expression()
		let child4 = Node.expression()
		let child5 = Node.expression()
		let child6 = Node.expression()

		root.children = [child1, child2, child3, child4, child5]

		XCTAssertEqual(root.body.parts.nodeList.count, 5)
		XCTAssertIdentical(root.body.parts.nodeList[3], child4)
		XCTAssertIdentical(root, child2.parent)
		XCTAssertIdentical(root, child5.root)

		root.children.append(child6)

		XCTAssertIdentical(root.body.parts.nodeList.last, child6)
	}

	func testSetNode() throws {
		let root = Node.expression()
		let child = Node.expression()

		root.body.expr.node = child

		XCTAssertIdentical(root.body.expr.node, child)
		XCTAssertIdentical(root, child.parent)
		XCTAssertIdentical(root, child.root)
	}

	func testVariablePropagation() throws {
		let root = Node.expression()
		let child = Node.expression()

		root.body.expr.node = child
		root.variables.set("x", to: .number(1))

		XCTAssertEqual(root.variables.get("x"), .number(1))
		XCTAssertEqual(child.variables.get("x"), .number(1))

		child.variables.set("y", to: .identifier("abc"))

		XCTAssertEqual(root.variables.get("y"), nil)
		XCTAssertEqual(child.variables.get("y"), .identifier("abc"))

		child.variables.set("x", to: .number(5))

		XCTAssertEqual(root.variables.get("x"), .number(1))
		XCTAssertEqual(child.variables.get("x"), .number(5))
	}

	func testVariables() throws {
		let root = Node.expression()

		root.variables.declare("x", type: .number)

		XCTAssertEqual(root.variables.get("x"), nil)
		XCTAssertEqual(root.variables.getType("x"), .number)
		XCTAssertEqual(root.variables.listDeclared(), ["x"])

		root.variables.set("x", to: .number(3))

		XCTAssertEqual(root.variables.get("x"), .number(3))
		XCTAssertEqual(root.variables.getType("x"), .number)
		
		root.variables.deleteValue("x")

		XCTAssertEqual(root.variables.get("x"), nil)
		XCTAssertEqual(root.variables.getType("x"), .number)

		root.variables.set("x", to: .list(Type.List([1, 2, 3])))

		XCTAssertEqual(root.variables.get("x"), .list(Type.List([1, 2, 3])))
		XCTAssertEqual(root.variables.getType("x"), .list(.number))

		root.variables.set("y", to: .identifier("abc"))

		var export = root.variables.export()
		export["x"] = .number(9)

		root.variables.import(export)

		XCTAssertEqual(export, ["x": .number(9), "y": .identifier("abc")])
		XCTAssertEqual(root.variables.get("x"), .number(9))

		root.variables.delete("x")

		XCTAssertEqual(root.variables.listDeclared(), ["y"])

		root.variables.clearValues()

		XCTAssertEqual(root.variables.getType("y"), .identifier)

		root.variables.set("y", to: .identifier("abb"))
		root.variables.clear()

		XCTAssertEqual(root.variables.get("y"), nil)
		XCTAssertEqual(root.variables.listDeclared(), [])
	}

	func testReturnType() throws {
		let root = Node.expression()
		let add = Node(Operator.Infix(priority: 1, identifier: "", functions: FunctionContainer {
			$0.addFunction { (a: Type.Number, b: Type.Number) in a + b }
			$0.addFunction { (a: [Type._0], b: [Type._0]) in a + b }
			$0.addFunction { (a: [Type._0], b: Type._0) in b }
		}))
		let var1 = Node.variable("x")
		let var2 = Node.variable("y")
		let var3 = Node.number(4)

		XCTAssertEqual(root.returnType, nil)
		XCTAssertEqual(add.returnType, nil)
		XCTAssertEqual(var1.returnType, nil)
		XCTAssertEqual(var2.returnType, nil)
		XCTAssertEqual(var3.returnType, .number)

		root.variables.set("x", to: .number(3))
		root.body.expr.node = add
		add.body.parts.nodeList = [Node.empty()]
		add.body.parts.nodeList.last?.replaceSelf(with: var1)

		XCTAssertEqual(root.returnType, .number)

		add.body.parts.nodeList.append(var2)
		root.variables.set("y", to: .number(6))

		XCTAssertEqual(root.returnType, .number)

		root.variables.declare("x", type: .list(.number))
		root.variables.declare("y", type: .list(.number))

		XCTAssertEqual(root.returnType, .list(.number))

		add.body.parts.nodeList += [var3]

		XCTAssertEqual(root.returnType, .number)
	}

	func testBodyChange() throws {
		let root = Node(Operator.Iterate(identifier: "", initialValue: .number(0), functions: FunctionContainer { $0.addFunction { (a: Type.Number, b: Type.Number) in a + b } }))
		let id = Node.identifier("n")
		let var1 = Node.variable("t")
		let child = Node(Operator.Iterate(identifier: "", initialValue: .number(0), functions: FunctionContainer { $0.addFunction { (a: Type.Number, b: Type.Number) in a + b } }))
		let id2 = Node.identifier("k")
		let var2 = Node.variable("n")
		let child2 = Node.empty()

		root.children = [id, var1, Node.empty(), child]
		child.children = [id2, var2, Node.empty(), child2]

		XCTAssertEqual(root.argumentCount, 4)
		XCTAssertEqual(child.argumentCount, 4)

		root.variables.declare("t", type: .list(.number))
		XCTAssertEqual(root.argumentCount, 3)
		XCTAssertEqual(child.argumentCount, 4)

		root.variables.declare("t", type: .list(.list(.number)))
		XCTAssertEqual(root.argumentCount, 3)
		XCTAssertEqual(child.argumentCount, 3)
	}

	func testFindNodes() throws {
		let parser = makeParser()
		do {
			try parser.parse(expression: "2+x-sin(2*y)+cos(2*x)+sum(\"x\",0,1,x+1)")
		}
		catch {
			print(error)
		}

		let allVars = parser.root.findNodes(with: Operator.Variable.self)
		for node in allVars {
			debugPrint(node, node.returnType, node.variables.isDeclared(node.body.name))

			try? node.evaluate().cast(to: Type.Number.self)
		}
	}

	func testRemoveSinglePriority() throws {
		let parser = makeParser()
		try parser.parse(expression: "1+2")

		XCTAssertEqual((parser.current?.body as? Operator.Number)?.numberString, "2")

		parser.erase()
		try parser.parse(token: "<-")

		XCTAssertEqual((parser.current?.body as? Operator.Number)?.numberString, "1")
		XCTAssert((parser.root.body as! Operator.Expression).expr.node.body is Operator.Number)		
	}

}

final class TypeTest: XCTestCase {}

final class ParserTest: XCTestCase {}

