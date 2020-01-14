//
//  CyberSymbolWriter.swift
//  eosswift
//
//  Created by Artem Shilin on 18.11.2019.
//  Copyright © 2019 memtrip. All rights reserved.
//

import Foundation

protocol CyberSymbolWriter : AbiTypeWriter {
}

public class CyberSymbolWriterValue : CyberSymbolWriter, Encodable {

    private let NAME_MAX_LENGTH = 8

    private let name: String

    public init(name: String) {
        self.name = name
    }

    func encode(writer: AbiEncodingContainer) throws {
        var newName = name
        var insertValue: UInt8?

        if name.contains(",") && name.count > 2 {
            newName = String(newName.dropFirst(2))
            insertValue = UInt8(String(name.prefix(1)))
        }

        var buf: [UInt8] = Array(newName.utf8)

        if let val = insertValue {
            buf.insert(val, at: 0)
        }

        if buf.count < NAME_MAX_LENGTH {
            for _ in buf.count...NAME_MAX_LENGTH - 1 {
                buf.append(0)
            }
        }

        try writer.encodeBytes(value: buf)
    }
}
