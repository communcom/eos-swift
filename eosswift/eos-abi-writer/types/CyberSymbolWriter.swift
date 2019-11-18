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
        let buf: [UInt8] = Array(name.utf8)
        let bytes = [UInt8](Data(bytes: buf, count: 8))
        print(buf)
        print(bytes)
        try writer.encodeBytes(value: bytes)
    }
}
