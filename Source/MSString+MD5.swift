//
//  MSString+MD5.swift
//  MSScrollViewSwift
//
//  Created by marshal on 2020/12/9.
//  Copyright © 2020 Marshal. All rights reserved.
//
import CommonCrypto
import Foundation
extension String {
    var ms_md5:String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce("") { $0 + String(format:"%02X", $1) }
    }
}
