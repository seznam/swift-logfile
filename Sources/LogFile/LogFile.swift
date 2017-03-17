import Foundation

public enum LogFileError: Error {
	case error(detail: String)
}

public enum LogLevel: Int {
	case none = -1
	case fatal
	case error
	case warning
	case notice
	case info
	case debug

	static func fromString(_ string: String) -> LogLevel? {
		var i = 0
		while let item = LogLevel(rawValue: i) {
			if String(describing: item) == string { return item }
			i += 1
		}
		return nil
	}

	public static func <(lhs: LogLevel, rhs: LogLevel) -> Bool {
		return lhs.hashValue < rhs.hashValue
	}
}

public class LogFile {

	public var pid = getpid()

	private let formatter = DateFormatter()
	private let newLines: [Character] = ["\n", "\r", "\u{85}"]

	public let path: String?
	public let level: LogLevel
	private let tag: String
	private var fd: UnsafeMutablePointer<FILE>?

	public init(path: String?, level: String? = "info", tag: String? = nil, timeFormat: String = "yyyy-MM-dd HH:mm:ss") throws {
		self.path = path
		self.formatter.dateFormat = timeFormat
		if level == nil {
			self.level = LogLevel.info
		} else {
			if let l = LogLevel.fromString(level!) {
				self.level = l
			} else {
				throw LogFileError.error(detail: "failed to parse loglevel '\(level!)'")
			}
		}
		self.tag = tag ?? ProcessInfo.processInfo.processName
	}

	public func open() throws -> Void {
		guard let p = path else {
			return
		}
		guard let f = fopen(p, "a") else {
			let errmsg = String(validatingUTF8: strerror(errno)) ?? "unknown error"
			throw LogFileError.error(detail: "faile to open logfile '\(p)', \(errmsg)")
		}
		fd = f
		notice("logfile opened")
	}

	public func close() -> Void {
		if fd != nil {
			notice("logfile closed")
			fclose(fd)
			fd = nil
		}
	}

	private func put(_ message: String,_ level: LogLevel,_ tag: String?) -> Void {
		if fd == nil {
			return
		}

		if self.level < level {
			return
		}

		if message.isEmpty {
			return
		}

		var msg = message

		let chars = msg.characters
		let lastChar = chars[chars.index(before: chars.endIndex)]
		if !newLines.contains(lastChar) {
			msg += "\n"
		}

		let t: String = tag ?? self.tag

		fputs("[\(formatter.string(from: Date()))] [\(pid)] [\(t)] [\(level)] \(msg)", fd)

		fflush(fd)
	}

	public func debug(_ message: String, _ tag: String? = nil) -> Void {
		put(message, .debug, tag)
	}

	public func info(_ message: String, _ tag: String? = nil) -> Void {
		put(message, .info, tag)
	}

	public func notice(_ message: String, _ tag: String? = nil) -> Void {
		put(message, .notice, tag)
	}

	public func warning(_ message: String, _ tag: String? = nil) -> Void {
		put(message, .warning, tag)
	}

	public func error(_ message: String, _ tag: String? = nil) -> Void {
		put(message, .error, tag)
	}

	public func fatal(_ message: String, _ tag: String? = nil) -> Void {
		put(message, .fatal, tag)
	}

}
