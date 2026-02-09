// Singleton that persists across Turbo Drive navigations.
// Holds the LiveKit Room instance so audio continues when navigating between rooms.
class MingleManager {
  constructor() {
    this.livekitRoom = null
    this.callId = null
    this.roomId = null
    this.muted = false
    this.listeners = new Set()
    this._livekit = null
  }

  get inCall() {
    return this.livekitRoom !== null
  }

  subscribe(listener) {
    this.listeners.add(listener)
    return () => this.listeners.delete(listener)
  }

  notify() {
    this.listeners.forEach(l => l(this))
  }

  async join({ callsUrl, csrfToken }) {
    const response = await fetch(callsUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken
      }
    })

    if (!response.ok) throw new Error("Failed to start/join call")

    const { token, ws_url, room_name, call_id } = await response.json()
    this.callId = call_id

    console.log("[Mingle] Connecting to LiveKit:", ws_url, "room:", room_name)

    const lk = await this._loadLiveKit()
    console.log("[Mingle] LiveKit client loaded")

    this.livekitRoom = new lk.Room({
      audioCaptureDefaults: {
        autoGainControl: true,
        noiseSuppression: true,
        echoCancellation: true
      }
    })

    this.livekitRoom.on(lk.RoomEvent.TrackSubscribed, this._onTrackSubscribed.bind(this))
    this.livekitRoom.on(lk.RoomEvent.TrackUnsubscribed, this._onTrackUnsubscribed.bind(this))
    this.livekitRoom.on(lk.RoomEvent.Disconnected, this._onDisconnected.bind(this))
    this.livekitRoom.on(lk.RoomEvent.ParticipantConnected, () => this.notify())
    this.livekitRoom.on(lk.RoomEvent.ParticipantDisconnected, () => this.notify())

    await this.livekitRoom.connect(ws_url, token)
    console.log("[Mingle] Connected to LiveKit successfully")

    const audioTrack = await lk.createLocalAudioTrack()
    await this.livekitRoom.localParticipant.publishTrack(audioTrack)
    console.log("[Mingle] Audio track published")

    this.roomId = Current.room?.id
    this.muted = false
    this.notify()
  }

  async leave({ callsUrl, csrfToken }) {
    if (this.callId) {
      try {
        await fetch(`${callsUrl}/${this.callId}`, {
          method: "DELETE",
          headers: { "X-CSRF-Token": csrfToken }
        })
      } catch (e) {
        console.warn("Failed to notify server of call leave:", e)
      }
    }
    this._disconnect()
  }

  toggleMute() {
    if (!this.livekitRoom) return

    this.muted = !this.muted
    this.livekitRoom.localParticipant.setMicrophoneEnabled(!this.muted)
    this.notify()
  }

  _onTrackSubscribed(track) {
    if (track.kind === "audio") {
      const audioElement = track.attach()
      audioElement.id = `lk-audio-${track.sid}`
      audioElement.style.display = "none"
      document.body.appendChild(audioElement)
    }
  }

  _onTrackUnsubscribed(track) {
    track.detach().forEach(el => el.remove())
  }

  _onDisconnected() {
    this._cleanup()
    this.notify()
  }

  _disconnect() {
    if (this.livekitRoom) {
      this.livekitRoom.disconnect()
    }
    this._cleanup()
    this.notify()
  }

  _cleanup() {
    document.querySelectorAll("[id^='lk-audio-']").forEach(el => el.remove())
    this.livekitRoom = null
    this.callId = null
    this.roomId = null
    this.muted = false
  }

  async _loadLiveKit() {
    if (!this._livekit) {
      try {
        this._livekit = await import("livekit-client")
      } catch (e) {
        console.error("[Mingle] Failed to load livekit-client:", e)
        throw e
      }
    }
    return this._livekit
  }
}

const mingleManager = new MingleManager()
export default mingleManager
