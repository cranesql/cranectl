//===----------------------------------------------------------------------===//
//
// This source file is part of the Crane open source project
//
// Copyright (c) 2026 the Crane project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

public import ArgumentParser

public struct CraneMigrate: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "migrate",
        abstract: "Apply pending database migrations."
    )

    public init() {}

    public func run() async throws {
        print("Let's migrate.")
    }
}
