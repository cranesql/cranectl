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
import Logging

/// Logging-related flags shared across cranectl subcommands. Embed via `@OptionGroup` and call
/// ``bootstrapLoggingSystem()`` at the start of each subcommand's `run()`.
struct LoggingArguments: ParsableArguments {
    @Flag(name: .shortAndLong, help: "Emit debug-level log output.")
    var verbose: Bool = false

    /// Bootstraps swift-log's `LoggingSystem` once for the current process. The handler factory
    /// captures the verbose flag, so every `Logger(label:)` constructed afterwards — including
    /// the ones inside `crane` and `crane-postgres-nio` — picks up the right level automatically.
    func bootstrapLoggingSystem() {
        let verbose = self.verbose
        LoggingSystem.bootstrap { label in
            var handler = StreamLogHandler.standardError(label: label)
            handler.logLevel = verbose ? .debug : .info
            return handler
        }
    }
}
