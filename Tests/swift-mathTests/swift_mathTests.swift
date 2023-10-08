import XCTest
@testable import swift_math

final class MathNodeTest: XCTestCase {
    func testNodeBuilding() throws {
		let node = Node(InfixNode(priority: 10, reducer: +, children: [
			Node(NumberNode(2)),
			Node(InfixNode(priority: 40, reducer: *, children: [
				Node(NumberNode(3)),
				Node(NumberNode(5))
			]))
		]))

		XCTAssertEqual(node.children.count, 2, "Init with children")
		XCTAssert(node.children[0] is Node<NumberNode>, "Correct children assignment")
		XCTAssertIdentical(node.children[0].parent, node, "Parent assignment")
		XCTAssertIdentical(node.children[1].children[0].root, node, "Root Property")
    }

	func testEvaluation() throws {
		let node = Node(InfixNode(priority: 10, reducer: +, children: [
			Node(NumberNode(2)),
			Node(InfixNode(priority: 40, reducer: *, children: [
				Node(NumberNode(3)),
				Node(NumberNode(5))
			]))
		]))

		XCTAssertEqual(node.evaluate(), .success(.number(17)), "Evaluation")
	}

	func testErrorPropagation() throws {
		let erroringNode = Node(EmptyNode())
		let node = Node(InfixNode(priority: 10, reducer: +, children: [
			Node(NumberNode(2)),
			Node(InfixNode(priority: 40, reducer: *, children: [
				erroringNode,
				Node(NumberNode(5))
			]))
		]))

		XCTAssertEqual(node.evaluate(), .failure(.evalError(message: "Missing Argument").withOrigin(erroringNode)))
	}
}

final class ParserTest: XCTestCase {
    func testSimpleInfix() throws {
		let parser = TokenParser(operators: [
			"+": InfixNode(priority: 10, reducer: +, children: [])
		])

		XCTAssertEqual(parser.parse(token: "#number", args: ["4"]), .success)
		XCTAssertEqual(parser.parse(token: "+"), .success)
		XCTAssertEqual(parser.parse(token: "#number", args: ["5"]), .success)

		XCTAssertEqual(parser.root.evaluate(), .success(.number(9)))
		print("========== ROOT ==========")
		print(parser.root)
		print("========== CURRENT ==========")
		print(parser.current as Any)
    }
}


