![](https://img.shields.io/badge/Swift-4.1-orange.svg?style=flat)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)
![Apache 2](https://img.shields.io/badge/license-Apache2-blue.svg?style=flat)

# LogFile

Let your swift application log important things, categorized by severity and custom tags.

## Usage

Log all messages with one common tag:

```swift
import LogFile

let path = "/tmp/my-app.log"
let level = "notice"
do {
	let log = try LogFile(path: path, level: level, tag: "my-app")
	try log.open()
	log.info("this is informational message") // this won't be written to logfile due to loglevel
	log.error("this is error message") // this will be written
	log.close()
} catch LogFileError.error(let detail) {
	print(detail)
}
```

Log from multiple threads to one logfile with custom tags:

```swift
import Foundation
import LogFile

var log: LogFile? = nil

func worker1() -> Void {
	let name = "worker1"
	log?.warning("warning from \(name)", name)
}

func worker2() -> Void {
	let name = "worker2"
	log?.debug("debug from \(name)", name)
}

do {
	log = try LogFile(path: "/tmp/threads.log", level: "debug")
	try log?.open()
	if #available(OSX 10.12, *) {
		_ = Thread(block: worker1).start()
		_ = Thread(block: worker2).start()
	}
	log?.info("info from main thread")
	sleep(3)
	log?.close()
} catch LogFileError.error(let detail) {
	print(detail)
}
```

Log with custom timestamps:

```swift
let log = try LogFile(path: "access.log", level: "info", timeFormat: "dd/MMM/yyyy:HH:mm:ss Z")
```

## Credits

Written by [Daniel Bilik](https://github.com/ddbilik/), copyright [Seznam.cz](https://onas.seznam.cz/en/), licensed under the terms of the Apache License 2.0.
