//===--------------- ParsableMessageTests.swift - Swift Parsable Output ---===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2019 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//
import XCTest
import Foundation

@_spi(Testing) import SwiftDriver

final class ParsableMessageTests: XCTestCase {
  func testBeganMessage() throws {
    let message = BeganMessage(
      pid: 1,
      inputs: ["/path/to/foo.swift"],
      outputs: [
      .init(path: "/path/to/foo.o", type: "object")
      ],
      commandExecutable: "/path/to/swiftc",
      commandArguments: ["-frontend", "compile"]
    )

    let beganMessage = ParsableMessage(name: "compile", kind: .began(message))

    let encoded = try beganMessage.toJSON()
    let string = String(data: encoded, encoding: .utf8)!

    XCTAssertEqual(string, """
      {
        "command_arguments" : [
          "-frontend",
          "compile"
        ],
        "command_executable" : "\\/path\\/to\\/swiftc",
        "inputs" : [
          "\\/path\\/to\\/foo.swift"
        ],
        "kind" : "began",
        "name" : "compile",
        "outputs" : [
          {
            "path" : "\\/path\\/to\\/foo.o",
            "type" : "object"
          }
        ],
        "pid" : 1
      }
      """)
  }

  func testFinishedMessage() throws {
    let message = FinishedMessage(exitStatus: 1, pid: 1, output: "hello")
    let finishedMessage = ParsableMessage(name: "compile", kind: .finished(message))
    let encoded = try finishedMessage.toJSON()
    let string = String(data: encoded, encoding: .utf8)!

    XCTAssertEqual(string, """
    {
      "exit-status" : 1,
      "kind" : "finished",
      "name" : "compile",
      "output" : "hello",
      "pid" : 1
    }
    """)
  }

    func testSignalledMessage() throws {
      let message = SignalledMessage(pid: 2, output: "sig", errorMessage: "err", signal: 3)
      let signalledMessage = ParsableMessage(name: "compile", kind: .signalled(message))
      let encoded = try signalledMessage.toJSON()
      let string = String(data: encoded, encoding: .utf8)!

      XCTAssertEqual(string, """
      {
        "error-message" : "err",
        "kind" : "signalled",
        "name" : "compile",
        "output" : "sig",
        "pid" : 2,
        "signal" : 3
      }
      """)
    }
}
