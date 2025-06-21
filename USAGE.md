# WebRTC

WebRTC is provided as a static library. Its package includes API headers and static archive files. Once deployed into your QNX Software Development Platform (SDP), the headers are accessible from:

${QNX_TARGET}/usr/include

By default, the static library `libwebrtc.a` is located at:

${QNX_TARGET}/<CPU>/usr/lib


## Library Variants

The QNX WebRTC port utilizes network, video, and audio services. Notably, the **network** and **audio** services are available in different combinations:

- `io-pkt` / `io-sock`
- `io-audio` / `io-snd`

If WebRTC is built with a variant other than the default, `libwebrtc.a` will be placed in a corresponding subdirectory:

${QNX_TARGET}/<CPU>/usr/lib/<NET_AUDIO>


Where `<NET_AUDIO>` can be one of:

- `iopkt_ioaudio`
- `iopkt_iosnd`
- `iosock_ioaudio`
- `iosock_iosnd`

In such cases, ensure the compiler can locate the library by adding the appropriate search path:

-L${QNX_TARGET}/<CPU>/usr/lib/<NET_AUDIO>


## Audio and Video Modules

As with other platforms, the QNX port includes default implementations for the **Audio Device Module (ADM)** and **Video Capture Module**. While originally designed for testing and demo purposes, these can also be used in production WebRTC applications.

### Default ADM

The default ADM is implemented using ALSA/SALSA APIs. Audio device parameters can be configured via **JSON files** or **environment variables**.

#### Configuration Files

ADM reads playback and capture parameters from:

- `/etc/webrtc/playout_pcm.cfg`
- `/etc/webrtc/capture_pcm.cfg`

Example content of a configuration file:

```json
{
  "card": 0,
  "device": 1,
  "plugin": false,
  "format": "S16",
  "channels": 2,
  "rate": 48000,
  "period": 480,
  "buffer": 9600
}
```

The `format` field supports the following values:

```
"S8", "U8", "S16", "U16", "S24", "U24", "S32", "U32", "FLOAT", "FLOAT64"
```

All parameters are optional. If any parameter is missing, ADM will use a default value.

#### Environment Variables

Audio devices can alternatively be selected using environment variables:

```bash
WEBRTC_AUDIO_PLAY_DEVICE=3:0 WEBRTC_AUDIO_RECORD_DEVICE=2:0 <WEBRTC APP>
```

This configures ADM to use `card3:device0` for playback and `card2:device0` for recording.


## Running Demo Applications on QNX

### Prerequisites

Ensure that both audio devices and the Sensor Framework-backed camera are correctly configured.

### Start the Server

```bash
./peerconnection_server --port=8888
```

### Start the First Client

```bash
./peerconnection_client --server <SERVER IP ADDRESS> --port=8888 --autoconnect
```

### Start the Second Client (on another target)

```bash
./peerconnection_client --server <SERVER IP ADDRESS> --port=8888 --autoconnect --autocall
```

> **Note:** You can also run the server and one client on a Linux machine, provided you've built the Linux version of the demo.

### Help

To display all available options for the client or server, run:

```bash
./peerconnection_client --helpfull
./peerconnection_server --helpfull
```

