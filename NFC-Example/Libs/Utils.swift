//
//  Utils1.swift
//  NFC-Example
//
//  Created by Victor Xu on 2019/3/7.
//  Copyright © 2019 Hans Knoechel. All rights reserved.
//

import Foundation
import CoreNFC

public class Utils {
    
    public static func parseNDEFMessage(messages: [NFCNDEFMessage]) -> Card? {
        for message in messages {
            if(message.records.count == 3){
                let re = message.records[2]
                return parseNDEFData(data: re.payload)
            }
        }
        return nil
    }
    
    public static func parseNDEFData(data:Data) -> Card? {
        var card = Card()
        let tlv = Tlv.decode(data: data)
        
        guard let blockchainPublicKey = tlv[Data(hex: TlvTag.BlockChain_PublicKey)],
            let signature = tlv[Data(hex: TlvTag.Signature)],
            let salt = tlv[Data(hex: TlvTag.Salt)],
            let certificate = tlv[Data(hex: TlvTag.Device_Certificate)] else {
                return nil
        }
        
        let parser = CertificateParser(hexCert: certificate.toBase64String())!
        card.blockchainPublicKey = blockchainPublicKey.hexEncodedString()
        card.signature = signature.hexEncodedString()
        card.salt = salt.hexEncodedString()
        card.cert = parser.toCert()
        return card
    }
    
    
}
