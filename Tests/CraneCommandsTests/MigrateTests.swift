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
import Configuration
import Logging
import Testing

@testable import CraneCommands

@Suite struct Migrate {
    @Suite struct `Config Reader` {
        private let logger = Logger(label: "test")

        @Test func `Reads CLI flags directly into the reader's flat namespace`() async throws {
            // The libraries read keys flat (`paths`, `postgres.host`), so `--paths` and
            // `--postgres-host` map to the queries they actually issue.
            let command = try CraneMigrate.parse(["--paths", "db", "shared", "--postgres-host", "10.0.0.1"])
            let reader = try await command.makeConfigReader(logger: logger)

            #expect(reader.stringArray(forKey: "paths", default: []) == ["db", "shared"])
            #expect(reader.string(forKey: "postgres.host", default: "") == "10.0.0.1")
        }

        @Test func `Returns the supplied default when nothing is configured`() async throws {
            let command = try CraneMigrate.parse([])
            let reader = try await command.makeConfigReader(logger: logger)

            #expect(reader.stringArray(forKey: "paths", default: ["fallback"]) == ["fallback"])
        }

        @Test func `Rejects --config with an unsupported file extension`() async throws {
            let command = try CraneMigrate.parse(["--config", "settings.toml"])

            await #expect(throws: ValidationError.self) {
                _ = try await command.makeConfigReader(logger: logger)
            }
        }
    }
}
