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

import ArgumentParser
import CraneCommands

@main
@available(macOS 10.15, macCatalyst 13, iOS 13, tvOS 13, watchOS 6, *)
struct CraneCTL: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "crane",
        abstract: "A CLI for Crane, the lightweight migration tool for SQL databases.",
        subcommands: [CraneMigrate.self]
    )
}
