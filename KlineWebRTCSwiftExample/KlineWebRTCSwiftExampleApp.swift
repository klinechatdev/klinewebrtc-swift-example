//
//  KlineWebRTCSwiftExampleApp.swift
//  KlineWebRTCSwiftExample
//
//  Created by Kyaw Naing Tun on 22/12/2022.
//

import SwiftUI
import KLineWebRTC
import KeychainAccess
import Foundation

struct RoomContextView: View {

    @EnvironmentObject var appCtx: RTCAppContext
    @StateObject var roomCtx = RTCRoomContext()

    var shouldShowRoomView: Bool {
        roomCtx.room.room.connectionState.isConnected || roomCtx.room.room.connectionState.isReconnecting
    }

    func computeTitle() -> String {
        if shouldShowRoomView {
            let elements = [roomCtx.room.room.name,
                            roomCtx.room.room.localParticipant?.name,
                            roomCtx.room.room.localParticipant?.identity]
            return elements.compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " ")
        }

        return "KLine Chat"
    }

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            if shouldShowRoomView {
                RoomView()
            } else {
                ContactView()
            }

        }
        .environment(\.colorScheme, .dark)
        .foregroundColor(Color.white)
        .environmentObject(roomCtx)
        .environmentObject(roomCtx.room)
        .navigationTitle(computeTitle())
        .onDisappear {
            print("\(String(describing: type(of: self))) onDisappear")
            roomCtx.disconnect()
        }
    }
}

@main
struct KlineWebRTCSwiftExampleApp: App {
    @StateObject var appCtx = RTCAppContext()
    
    var body: some Scene {
        WindowGroup {
            RoomContextView()
                .environmentObject(appCtx)
        }
    }
}
