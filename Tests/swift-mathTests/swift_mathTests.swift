import XCTest
@testable import swift_math

final class TreeTest: XCTestCase {
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
		let root = PrefixFunctionNode(identifier: "", function: *).makeNode() as! Node<PrefixFunctionNode>
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
		let root = InfixNode(priority: 1, identifier: "") { $0.addFunction({(a: MathNumber, b: MathNumber) in a + b})}.makeNode() as! Node<InfixNode>
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

		root.variables.set("x", to: .list(MathList([1, 2, 3])))

		XCTAssertEqual(root.variables.get("x"), .list(MathList([1, 2, 3])))
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
		let add = Node(InfixNode(priority: 1, identifier: "") {
			$0.addFunction { (a: MathNumber, b: MathNumber) in a + b }
			$0.addFunction { (a: [Math._0], b: [Math._0]) in a + b }
			$0.addFunction { (a: [Math._0], b: Math._0) in b }
		})
		let var1 = Node(VariableNode("x"))
		let var2 = Node(VariableNode("y"))
		let var3 = Node(NumberNode(4))

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
		let root = Node(IterateNode(identifier: "", initialValue: 0, reducer: +))
		let id = Node(IdentifierNode("n"))
		let var1 = Node(VariableNode("t"))
		let child = Node(IterateNode(identifier: "", initialValue: 0, reducer: +))
		let id2 = Node(IdentifierNode("k"))
		let var2 = Node(VariableNode("n"))
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
}

final class TypeTest: XCTestCase {}

final class ParserTest: XCTestCase {}

