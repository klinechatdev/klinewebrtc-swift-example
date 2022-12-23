//
//  Contact.swift
//  KlineWebRTCSwiftExample
//
//  Created by Kyaw Naing Tun on 22/12/2022.
//

import Foundation

struct ContactList: Decodable {
    let data: [Contact]
}

struct Contact: Codable, Identifiable {
    let id: String
    let name: String
    let token: String
}
