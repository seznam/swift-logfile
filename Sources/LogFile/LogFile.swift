/*
 * Copyright 2017-2018 Seznam.cz, a.s.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * Author: Daniel Bilik (daniel.bilik@firma.seznam.cz)
 */

import Foundation

public enum LogFileError: Error {
	case error(detail: String)
}

extension RawRepresentable where RawValue: Comparable {
    public static func <(lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

public enum LogLevel: Int, Comparable, CaseIterable {
	case none = -1
	case fatal
	case error
	case warning
	case notice
	case info
	case debug

	static func fromString(_ string: String) -> LogLevel? {
		return allCases.dropFirst().first(where: { String(describing: $0) == string })
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
		guard fd != nil, self.level >= level, !message.isEmpty else {
			return
		}

        let msg = message + {
            if let lastChar = message.last, !newLines.contains(lastChar) {
                return "\n"
            } else {
                return ""
            }
        }()

		fputs("[\(formatter.string(from: Date()))] [\(pid)] [\(tag ?? self.tag)] [\(level)] \(msg)", fd)

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
