import XCTest

@testable import LogFile

class LogFileTests: XCTestCase {

	static var allTests = [
		("testLogLevels", testLogLevels),
		("testLogLevelEqual", testLogLevelEqual),
		("testFatalvsDebug", testLogLevelEqual),
		("testLogOpen", testLogOpen),
		("testLogClose", testLogClose),
		("testLogTag", testLogTag),
		("testLogDebug", testLogDebug),
		("testLogInfo", testLogInfo),
		("testLogNotice", testLogNotice),
		("testLogWarning", testLogWarning),
		("testLogError", testLogError),
		("testLogFatal", testLogFatal)
	]

	let logfile = "test.log"

	override func tearDown() {
		unlink(logfile)
		super.tearDown()
	}

	func testLogLevels() {
		let fatal = try? LogFile(path: logfile, level: "fatal")
		let error = try? LogFile(path: logfile, level: "error")
		let warning = try? LogFile(path: logfile, level: "warning")
		let notice = try? LogFile(path: logfile, level: "notice")
		let info = try? LogFile(path: logfile, level: "info")
		let debug = try? LogFile(path: logfile, level: "debug")
		XCTAssert(fatal != nil)
		XCTAssert(error != nil)
		XCTAssert(warning != nil)
		XCTAssert(notice != nil)
		XCTAssert(info != nil)
		XCTAssert(debug != nil)
	}

	func testLogLevelEqual() {
		let log1 = try! LogFile(path: "/tmp/log1")
		let log2 = try! LogFile(path: "/tmp/log2", level: "info")
		XCTAssert(log1.level == log2.level)
	}

	func testFatalvsDebug() {
		let log1 = try! LogFile(path: "/tmp/log1", level: "fatal")
		let log2 = try! LogFile(path: "/tmp/log2", level: "debug")
		XCTAssert(log1.level < log2.level)
	}

	func testLogOpen() {
		let log: String
		do {
			let test = try LogFile(path: logfile, level: "info")
			try test.open()
			log = try String(contentsOfFile: logfile, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
			test.close()
		} catch {
			print(error)
			log = ""
		}
		XCTAssert(log.hasSuffix(" [notice] logfile opened"))
	}

	func testLogClose() {
		let log: String
		do {
			let test = try LogFile(path: logfile, level: "info")
			try test.open()
			test.close()
			log = try String(contentsOfFile: logfile, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
		} catch {
			print(error)
			log = ""
		}
		XCTAssert(log.hasSuffix(" [notice] logfile closed"))
	}

	func testLogTag() {
		let log: String
		do {
			let test = try LogFile(path: "test.log", level: "info", tag: "tester")
			try test.open()
			test.close()
			log = try String(contentsOfFile: logfile, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
		} catch {
			print(error)
			log = ""
		}
		XCTAssert(log.hasSuffix(" [tester] [notice] logfile closed"))
	}

	func testLogDebug() {
		let log: String
		do {
			let test = try LogFile(path: "test.log", level: "debug")
			try test.open()
			test.debug("test")
			log = try String(contentsOfFile: logfile, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
			test.close()
		} catch {
			print(error)
			log = ""
		}
		XCTAssert(log.hasSuffix(" [debug] test"))
	}

	func testLogInfo() {
		let log: String
		do {
			let test = try LogFile(path: "test.log", level: "info")
			try test.open()
			test.info("test")
			log = try String(contentsOfFile: logfile, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
			test.close()
		} catch {
			print(error)
			log = ""
		}
		XCTAssert(log.hasSuffix(" [info] test"))
	}

	func testLogNotice() {
		let log: String
		do {
			let test = try LogFile(path: "test.log", level: "notice")
			try test.open()
			test.notice("test")
			log = try String(contentsOfFile: logfile, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
			test.close()
		} catch {
			print(error)
			log = ""
		}
		XCTAssert(log.hasSuffix(" [notice] test"))
	}

	func testLogWarning() {
		let log: String
		do {
			let test = try LogFile(path: "test.log", level: "warning")
			try test.open()
			test.warning("test")
			log = try String(contentsOfFile: logfile, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
			test.close()
		} catch {
			print(error)
			log = ""
		}
		XCTAssert(log.hasSuffix(" [warning] test"))
	}

	func testLogError() {
		let log: String
		do {
			let test = try LogFile(path: "test.log", level: "error")
			try test.open()
			test.error("test")
			log = try String(contentsOfFile: logfile, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
			test.close()
		} catch {
			print(error)
			log = ""
		}
		XCTAssert(log.hasSuffix(" [error] test"))
	}

	func testLogFatal() {
		let log: String
		do {
			let test = try LogFile(path: "test.log", level: "fatal")
			try test.open()
			test.fatal("test")
			log = try String(contentsOfFile: logfile, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
			test.close()
		} catch {
			print(error)
			log = ""
		}
		XCTAssert(log.hasSuffix(" [fatal] test"))
	}

}
