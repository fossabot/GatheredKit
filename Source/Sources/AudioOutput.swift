import AVFoundation

public final class AudioOutput: BasePollingSource, Source, ManuallyUpdatableValuesProvider {

    public static let availability: SourceAvailability = .available

    public static let name = "Audio Output"

    public private(set) var volume: GenericValue<Float, Percent>
    public private(set) var ports: [Port]

    public var allValues: [Value] {
        let ports = zip(self.ports, self.ports.indices).map {
            GenericUnitlessValue(
                displayName: "Port \($1 + 1)",
                backingValue: $0
            )
        }
        return ports + [volume]
    }

    public override init() {
        volume = GenericValue(
            displayName: "Volume",
            backingValue: AVAudioSession.sharedInstance().outputVolume
        )
        ports = []

        super.init()

        updateValues()
    }

    @discardableResult
    public func updateValues() -> [Value] {
        let audioSession = AVAudioSession.sharedInstance()
        volume.update(backingValue: audioSession.outputVolume)

        ports = audioSession.currentRoute.outputs.map(
            Port.init(portDescription:)
        )

        return allValues
    }

}

public extension AudioOutput {

    public struct Port: ValuesProvider {

        public let name: GenericUnitlessValue<String>

        @available(iOS 10.0, *)
        public var hasHardwareVoiceCallProcessing: GenericValue<Bool, Boolean> {
            return GenericValue(
                displayName: "Has Hardware Voice Call Processing",
                backingValue: _hasHardwareVoiceCallProcessing,
                unit: Boolean(trueString: "Yes", falseString: "No")
            )
        }

        private let _hasHardwareVoiceCallProcessing: Bool

        public let type: GenericUnitlessValue<AVAudioSession.Port>

        public var allValues: [Value] {
            if #available(iOS 10.0, *) {
                return [name, hasHardwareVoiceCallProcessing, type]
            } else {
                return [type]
            }
        }

        fileprivate init(portDescription: AVAudioSessionPortDescription) {
            name = GenericUnitlessValue(
                displayName: "Name",
                backingValue: portDescription.portName
            )

            if #available(iOS 10.0, *) {
                _hasHardwareVoiceCallProcessing = portDescription.hasHardwareVoiceCallProcessing
            } else {
                _hasHardwareVoiceCallProcessing = false
            }

            #if swift(>=4.2)
            type = GenericUnitlessValue(
                displayName: "Type",
                backingValue: portDescription.portType,
                formattedValue: portDescription.portType.displayValue
            )
            #else
            let portType = AVAudioSession.Port(string: portDescription.portType)
            type = GenericUnitlessValue(
                displayName: "Type",
                backingValue: portType,
                formattedValue: portType.displayValue
            )
            #endif
        }
    }

}


#if swift(>=4.2)
#else
extension AVAudioSession {

    public enum Port {

        case HDMI
        case airPlay
        case bluetoothA2DP
        case bluetoothHFP
        case bluetoothLE
        case builtInMic
        case builtInReceiver
        case builtInSpeaker
        case carAudio
        case headphones
        case headsetMic
        case lineIn
        case lineOut
        case usbAudio
        case unknown(String)

        init(string: String) {
            switch string {
            case AVAudioSessionPortHDMI:
                self = .HDMI
            case AVAudioSessionPortAirPlay:
                self = .airPlay
            case AVAudioSessionPortBluetoothA2DP:
                self = .bluetoothA2DP
            case AVAudioSessionPortBluetoothHFP:
                self = .bluetoothHFP
            case AVAudioSessionPortBluetoothLE:
                self = .bluetoothLE
            case AVAudioSessionPortBuiltInMic:
                self = .builtInMic
            case AVAudioSessionPortBuiltInReceiver:
                self = .builtInReceiver
            case AVAudioSessionPortBuiltInSpeaker:
                self = .builtInSpeaker
            case AVAudioSessionPortCarAudio:
                self = .carAudio
            case AVAudioSessionPortHeadphones:
                self = .headphones
            case AVAudioSessionPortHeadsetMic:
                self = .headsetMic
            case AVAudioSessionPortLineIn:
                self = .lineIn
            case AVAudioSessionPortLineOut:
                self = .lineOut
            case AVAudioSessionPortUSBAudio:
                self = .usbAudio
            default:
                self = .unknown(string)
            }
        }

    }
}
#endif

private extension AVAudioSession.Port {

    var displayValue: String {
        switch self {
        case .HDMI:
            return "HDMI"
        case .airPlay:
            return "Air Play"
        case .bluetoothA2DP:
            return "Bluetooth A2DP"
        case .bluetoothHFP:
            return "Bluetooth Hands-Free"
        case .bluetoothLE:
            return "Bluetooth Low Energy"
        case .builtInMic:
            return "Built in Microphone"
        case .builtInReceiver:
            return "Built in Receiver"
        case .builtInSpeaker:
            return "Built in Speaker"
        case .carAudio:
            return "Car Audio"
        case .headphones:
            return "Wired Headphones"
        case .headsetMic:
            return "Headset Microphone"
        case .lineIn:
            return "Line In"
        case .lineOut:
            return "Line Out"
        case .usbAudio:
            return "USB Audio"
            #if swift(>=4.2)
            default:
            return rawValue
            #else
        case .unknown(let string):
            return string
            #endif
        }
    }

}
