# KLineWebRTC Example App for iOS

This app demonstrates the basic usage of [KLineWebRTC](https://github.com/klinechatdev/KLineWebRTC) SDK.

# How to run the example

### Get the code

1. Clone this [Example](https://github.com/klinechatdev/klinewebrtc-swift-example) repo.
2. Open `KlineWebRTCSwiftExample.xcodeproj`.
3. Wait for packages to sync.

### Change bundle id & code signing information
1. Select the `KlineWebRTCSwiftExample` project from the left Navigator.
2. For each **Target**, select **Signing & Capabilities** tab and update your **Team** and **Bundle Identifier** to your preference.


### Connect

Server URL would typically look like `ws://localhost:7880` depending on your configuration. It should start with `ws://` for *non-secure* and `wss://` for *secure* connections.

### Permissions

iOS will ask you to grant permission when enabling **Camera**, **Microphone** and/or **Screen Share**. Simply allow this to continue publishing the track.
