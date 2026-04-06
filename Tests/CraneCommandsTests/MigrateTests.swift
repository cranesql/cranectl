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

import CraneCommands
import Testing

@Suite struct Migrate {
    @Test func Executes() async throws {
        let command = CraneMigrate()

        try await command.run()
    }
}
