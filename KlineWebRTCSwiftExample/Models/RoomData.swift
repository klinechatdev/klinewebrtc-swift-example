//
//  RoomData.swift
//  KlineWebRTCSwiftExample
//
//  Created by Kyaw Naing Tun on 22/12/2022.
//

import Foundation

struct RoomTokenData: Decodable {
    let token: String
    let room: String
    let participant: String
}

struct RoomTokenForm: Codable {
    let room: String
    let participant: String
}
