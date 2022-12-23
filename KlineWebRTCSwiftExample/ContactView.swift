//
//  ContactView.swift
//  KlineWebRTCSwiftExample
//
//  Created by Kyaw Naing Tun on 22/12/2022.
//
import Foundation
import KLineWebRTC
import SwiftUI
import SFSafeSymbols

struct ContactView: View {
    @EnvironmentObject var roomCtx: RTCRoomContext
    @EnvironmentObject var appCtx: RTCAppContext
    
    let networkManager = NetworkManager()
    @State var contacts = [Contact]()
    
    func makeACall(contactId: String) {
        let formData = CallMakingForm(caller_id: "788166683", contact_id: contactId)
        networkManager.makeACall(formData, completion: { result in
            switch result {
            case .success(let responseData):
                print("Api call success \(responseData)")
                roomCtx.join(url: "wss://webrtc.klinechat.com", token: responseData.room_token).then { room in
                    appCtx.connectionHistory.update(room: room)
                }
            case .failure(let error):
                print("Api error occured \(error)")
            }
        })
    }
    
    func fetchContacts() {
        networkManager.getContacts(completion: { result in
            switch result {
            case .success(let responseData):
                print("Api call contacts success \(responseData)")
                DispatchQueue.main.async {
                    self.contacts = responseData
                }
            case .failure(let error):
                print("Api error occured \(error)")
            }
        })
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("WebRTC Testing")
                    .font(.title)
                    .bold()
                
                Divider()
                Button(action: fetchContacts, label: {
                    Text("Fetch Contacts")
                })
                List(contacts) { contact in
                    HStack{
                        Image(systemSymbol: .personCircleFill)
                        Text(contact.name)
                        Spacer()
                        if case .connecting = roomCtx.room.room.connectionState {
                            ProgressView()
                        } else {
                            Button(action: {
                                makeACall(contactId: contact.id)
                            }, label: {
                                Image(systemSymbol: .videoFill)
                                    .renderingMode(.original)
                                    .padding()
                            })
                        }
                    }
                }
                
            }
        }
        .onAppear {
            self.fetchContacts()
        }
        .alert(isPresented: $roomCtx.shouldShowError) {
            Alert(title: Text("Error"),
                  message: Text(roomCtx.latestError != nil
                                    ? String(describing: roomCtx.latestError!)
                                    : "Unknown error"))
        }
    }
}
