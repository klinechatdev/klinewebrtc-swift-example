//
//  RoomView.swift
//  KlineWebRTCSwiftExample
//
//  Created by Kyaw Naing Tun on 22/12/2022.
//

import SwiftUI
import KLineWebRTC
import LiveKit

let adaptiveMin = 170.0
let toolbarPlacement: ToolbarItemPlacement = .bottomBar

struct RoomView: View {

    @EnvironmentObject var appCtx: RTCAppContext
    @EnvironmentObject var roomCtx: RTCRoomContext
    @EnvironmentObject var room: RTCObservableRoom

    @State private var screenPickerPresented = false

    @State private var showConnectionTime = true

    func sortedParticipants() -> [ObservableParticipant] {
        room.allParticipants.values.sorted { p1, p2 in
            if p1.participant is LocalParticipant { return true }
            if p2.participant is LocalParticipant { return false }
            return (p1.participant.joinedAt ?? Date()) < (p2.participant.joinedAt ?? Date())
        }
    }

    func content(geometry: GeometryProxy) -> some View {

        VStack {

            if showConnectionTime {
                Text("Connected (\([room.room.serverRegion, "\(String(describing: room.room.connectStopwatch.total().rounded(to: 2)))s"].compactMap { $0 }.joined(separator: ", ")))")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding()
            }

            if case .connecting = room.room.connectionState {
                Text("Re-connecting...")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding()
            }

//            HorVStack(axis: geometry.isTall ? .vertical : .horizontal, spacing: 5) {
//
//                Group {
//                    if let focusParticipant = room.focusParticipant {
//                        ZStack(alignment: .bottomTrailing) {
//                            ParticipantView(participant: focusParticipant,
//                                            videoViewMode: appCtx.videoViewMode) { _ in
//                                room.focusParticipant = nil
//                            }
//                            .overlay(RoundedRectangle(cornerRadius: 5)
//                                        .stroke(Color.lkRed.opacity(0.7), lineWidth: 5.0))
//                            Text("SELECTED")
//                                .font(.system(size: 10))
//                                .fontWeight(.bold)
//                                .foregroundColor(Color.white)
//                                .padding(.horizontal, 5)
//                                .padding(.vertical, 2)
//                                .background(Color.lkRed.opacity(0.7))
//                                .cornerRadius(8)
//                                .padding(.vertical, 35)
//                                .padding(.horizontal, 10)
//                        }
//
//                    } else {
//                        // Array([room.allParticipants.values, room.allParticipants.values].joined())
//                        ParticipantLayout(sortedParticipants(), spacing: 5) { participant in
//                            ParticipantView(participant: participant,
//                                            videoViewMode: appCtx.videoViewMode) { participant in
//                                room.focusParticipant = participant
//
//                            }
//                        }
//                    }
//                }
//                .frame(
//                    minWidth: 0,
//                    maxWidth: .infinity,
//                    minHeight: 0,
//                    maxHeight: .infinity
//                )
//            }
        }
        .padding(5)
    }

    var body: some View {

        GeometryReader { geometry in
            content(geometry: geometry)
                .toolbar {
                    ToolbarItemGroup(placement: toolbarPlacement) {
                        Button(action: {
                            room.switchCameraPosition()
                        },
                        label: {
                            Image(systemSymbol: .arrowTriangle2CirclepathCameraFill)
                                .renderingMode(room.cameraTrackState.isPublished ? .original : .template)
                                .padding()
                        })
                        .background(Color(.systemBlue))
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        // disable while publishing/un-publishing
                        .disabled(!room.cameraTrackState.isPublished)
                        
                        // spacer
                        Spacer()
                        
                        // Toggle camera enabled
                        if !room.cameraTrackState.isPublished || !CameraCapturer.canSwitchPosition() {
                            Button(action: {
                                room.toggleCameraEnabled()
                            },
                            label: {
                                Image(systemSymbol: .videoFill)
                                    .renderingMode(room.cameraTrackState.isPublished ? .original : .template)
                                    .padding()
                            })
                            .background(Color(.systemBlue))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            // disable while publishing/un-publishing
                            .disabled(room.cameraTrackState.isBusy)
                        } else {
                            Button(action: {
                                room.toggleCameraEnabled()
                            },
                            label: {
                                Image(systemSymbol: .videoSlashFill)
                                    .renderingMode(room.cameraTrackState.isPublished ? .original : .template)
                                    .padding()
                            })
                            .background(Color(.systemGray))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            // disable while publishing/un-publishing
                            .disabled(room.cameraTrackState.isBusy)
                        }
                        
                        Spacer()
                        
                        // Toggle microphone enabled
                        if room.microphoneTrackState.isPublished {
                            Button(action: {
                                room.toggleMicrophoneEnabled()
                            },
                            label: {
                                Image(systemSymbol: .micSlashFill)
                                    .renderingMode(room.microphoneTrackState.isPublished ? .original : .template)
                                    .padding()
                            })
                            .background(Color(.systemGray))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            // disable while publishing/un-publishing
                            .disabled(room.microphoneTrackState.isBusy)
                        } else {
                            Button(action: {
                                room.toggleMicrophoneEnabled()
                            },
                            label: {
                                Image(systemSymbol: .micFill)
                                    .renderingMode(room.microphoneTrackState.isPublished ? .original : .template)
                                    .padding()
                            })
                            .background(Color(.systemBlue))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            // disable while publishing/un-publishing
                            .disabled(room.microphoneTrackState.isBusy)
                        }
                        
                        
                        // spacer
                        Spacer()
                        
                        // Disconnect
                        Button(action: {
                            roomCtx.disconnect()
                        },
                        label: {
                            Image(systemSymbol: .xmarkCircleFill)
                                .renderingMode(.original)
                                .padding()
                        })
                        .background(Color(.systemRed))
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        
                    }

                }
                .background(Color(.systemBackground))
        }
        .onAppear {
            //
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                DispatchQueue.main.async {
                    withAnimation {
                        self.showConnectionTime = false
                    }
                }
            }
        }
    }
}

struct ParticipantLayout<Content: View>: View {

    let views: [AnyView]
    let spacing: CGFloat

    init<Data: RandomAccessCollection>(
        _ data: Data,
        id: KeyPath<Data.Element, Data.Element> = \.self,
        spacing: CGFloat,
        @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.spacing = spacing
        self.views = data.map { AnyView(content($0[keyPath: id])) }
    }

    func computeColumn(with geometry: GeometryProxy) -> (x: Int, y: Int) {
        let sqr = Double(views.count).squareRoot()
        let r: [Int] = [Int(sqr.rounded()), Int(sqr.rounded(.up))]
        let c = geometry.isTall ? r : r.reversed()
        return (x: c[0], y: c[1])
    }

    func grid(axis: Axis, geometry: GeometryProxy) -> some View {
        ScrollView([ axis == .vertical ? .vertical : .horizontal ]) {
            HorVGrid(axis: axis, columns: [GridItem(.flexible())], spacing: spacing) {
                ForEach(0..<views.count, id: \.self) { i in
                    views[i]
                        .aspectRatio(1, contentMode: .fill)
                }
            }
            .padding(axis == .horizontal ? [.leading, .trailing] : [.top, .bottom],
                     max(0, ((axis == .horizontal ? geometry.size.width : geometry.size.height)
                                - ((axis == .horizontal ? geometry.size.height : geometry.size.width) * CGFloat(views.count)) - (spacing * CGFloat(views.count - 1))) / 2))
        }
    }

    var body: some View {
        GeometryReader { geometry in
            if views.isEmpty {
                EmptyView()
            } else if geometry.size.width <= 300 {
                grid(axis: .vertical, geometry: geometry)
            } else if geometry.size.height <= 300 {
                grid(axis: .horizontal, geometry: geometry)
            }
//            if views.isEmpty {
//                EmptyView()
//            } else if geometry.size.width <= 300 {
//                grid(axis: .vertical, geometry: geometry)
//            } else if geometry.size.height <= 300 {
//                grid(axis: .horizontal, geometry: geometry)
//            } else {
//
//                let verticalWhenTall: Axis = geometry.isTall ? .vertical : .horizontal
//                let horizontalWhenTall: Axis = geometry.isTall ? .horizontal : .vertical
//
//                switch views.count {
//                // simply return first view
//                case 1: views[0]
//                case 3: HorVStack(axis: verticalWhenTall, spacing: spacing) {
//                    views[0]
//                    HorVStack(axis: horizontalWhenTall, spacing: spacing) {
//                        views[1]
//                        views[2]
//                    }
//                }
//                case 5: HorVStack(axis: verticalWhenTall, spacing: spacing) {
//                    views[0]
//                    if geometry.isTall {
//                        HStack(spacing: spacing) {
//                            views[1]
//                            views[2]
//                        }
//                        HStack(spacing: spacing) {
//                            views[3]
//                            views[4]
//
//                        }
//                    } else {
//                        VStack(spacing: spacing) {
//                            views[1]
//                            views[3]
//                        }
//                        VStack(spacing: spacing) {
//                            views[2]
//                            views[4]
//                        }
//                    }
//                }
//                default:
//                    let c = computeColumn(with: geometry)
//                    VStack(spacing: spacing) {
//                        ForEach(0...(c.y - 1), id: \.self) { y in
//                            HStack(spacing: spacing) {
//                                ForEach(0...(c.x - 1), id: \.self) { x in
//                                    let index = (y * c.x) + x
//                                    if index < views.count {
//                                        views[index]
//                                    }
//                                }
//                            }
//                        }
//                    }
//
//                }
//            }
        }
    }
}

struct HorVStack<Content: View>: View {
    let axis: Axis
    let horizontalAlignment: HorizontalAlignment
    let verticalAlignment: VerticalAlignment
    let spacing: CGFloat?
    let content: () -> Content

    init(axis: Axis = .horizontal,
         horizontalAlignment: HorizontalAlignment = .center,
         verticalAlignment: VerticalAlignment = .center,
         spacing: CGFloat? = nil,
         @ViewBuilder content: @escaping () -> Content) {

        self.axis = axis
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        Group {
            if axis == .vertical {
                VStack(alignment: horizontalAlignment, spacing: spacing, content: content)
            } else {
                HStack(alignment: verticalAlignment, spacing: spacing, content: content)
            }
        }
    }
}

struct HorVGrid<Content: View>: View {
    let axis: Axis
    let spacing: CGFloat?
    let content: () -> Content
    let columns: [GridItem]

    init(axis: Axis = .horizontal,
         columns: [GridItem],
         spacing: CGFloat? = nil,
         @ViewBuilder content: @escaping () -> Content) {

        self.axis = axis
        self.spacing = spacing
        self.columns = columns
        self.content = content
    }

    var body: some View {
        Group {
            if axis == .vertical {
                LazyVGrid(columns: columns, spacing: spacing, content: content)
            } else {
                LazyHGrid(rows: columns, spacing: spacing, content: content)
            }
        }
    }
}

extension GeometryProxy {

    public var isTall: Bool {
        size.height > size.width
    }

    var isWide: Bool {
        size.width > size.height
    }
}
