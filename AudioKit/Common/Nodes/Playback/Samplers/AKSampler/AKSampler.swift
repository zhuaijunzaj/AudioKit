//
//  AKSampler.swift
//  AudioKit
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Stereo Chorus
///
open class AKSampler: AKPolyphonicNode, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKSamplerAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "AKss")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var masterVolumeParameter: AUParameter?
    fileprivate var pitchBendParameter: AUParameter?
    fileprivate var vibratoDepthParameter: AUParameter?
    fileprivate var filterCutoffParameter: AUParameter?
    fileprivate var filterEgStrengthParameter: AUParameter?
    fileprivate var filterResonanceParameter: AUParameter?

    fileprivate var attackTimeParameter: AUParameter?
    fileprivate var decayTimeParameter: AUParameter?
    fileprivate var sustainLevelParameter: AUParameter?
    fileprivate var releaseTimeParameter: AUParameter?

    fileprivate var filterAttackTimeParameter: AUParameter?
    fileprivate var filterDecayTimeParameter: AUParameter?
    fileprivate var filterSustainLevelParameter: AUParameter?
    fileprivate var filterReleaseTimeParameter: AUParameter?

    fileprivate var filterEnableParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    @objc open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Master volume (fraction)
    @objc open dynamic var masterVolume: Double = 1.0 {
        willSet {
            if masterVolume == newValue {
                return
            }

            if internalAU?.isSetUp ?? false {
                if token != nil && masterVolumeParameter != nil {
                    masterVolumeParameter?.setValue(Float(newValue), originator: token!)
                    return
                }
            }

            internalAU?.masterVolume = newValue
        }
    }

    /// Pitch offset (semitones)
    @objc open dynamic var pitchBend: Double = 0.0 {
        willSet {
            if pitchBend == newValue {
                return
            }

            if internalAU?.isSetUp ?? false {
                if token != nil && pitchBendParameter != nil {
                    pitchBendParameter?.setValue(Float(newValue), originator: token!)
                    return
                }
            }

            internalAU?.pitchBend = newValue
        }
    }

    /// Vibrato amount (semitones)
    @objc open dynamic var vibratoDepth: Double = 1.0 {
        willSet {
            if vibratoDepth == newValue {
                return
            }

            if internalAU?.isSetUp ?? false {
                if token != nil && vibratoDepthParameter != nil {
                    vibratoDepthParameter?.setValue(Float(newValue), originator: token!)
                    return
                }
            }

            internalAU?.vibratoDepth = newValue
        }
    }

    /// Filter cutoff (harmonic ratio)
    @objc open dynamic var filterCutoff: Double = 4.0 {
        willSet {
            if filterCutoff == newValue {
                return
            }

            if internalAU?.isSetUp ?? false {
                if token != nil && filterCutoffParameter != nil {
                    filterCutoffParameter?.setValue(Float(newValue), originator: token!)
                    return
                }
            }

            internalAU?.filterCutoff = newValue
        }
    }

    /// Filter EG strength (harmonic ratio)
    @objc open dynamic var filterEgStrength: Double = 20.0 {
        willSet {
            if filterEgStrength == newValue {
                return
            }

            if internalAU?.isSetUp ?? false {
                if token != nil && filterEgStrengthParameter != nil {
                    filterEgStrengthParameter?.setValue(Float(newValue), originator: token!)
                    return
                }
            }

            internalAU?.filterEgStrength = newValue
        }
    }

    /// Filter resonance (dB)
    @objc open dynamic var filterResonance: Double = 0.0 {
        willSet {
            if filterResonance == newValue {
                return
            }

            if internalAU?.isSetUp ?? false {
                if token != nil && filterResonanceParameter != nil {
                    filterResonanceParameter?.setValue(Float(newValue), originator: token!)
                    return
                }
            }

            internalAU?.filterResonance = newValue
        }
    }

    /// Amp attack time (seconds)
    @objc open dynamic var attackTime: Double = 0.0 {
        willSet {
            if attackTime != newValue {
                internalAU?.attackTime = newValue
            }
        }
    }

    /// Amp Decay time (seconds)
    @objc open dynamic var decayTime: Double = 0.0 {
        willSet {
            if decayTime != newValue {
                internalAU?.decayTime = newValue
            }
        }
    }

    /// Amp sustain level (fraction)
    @objc open dynamic var sustainLevel: Double = 1.0 {
        willSet {
            if sustainLevel != newValue {
                internalAU?.sustainLevel = newValue
            }
        }
    }

    /// Amp Release time (seconds)
    @objc open dynamic var releaseTime: Double = 0.0 {
        willSet {
            if releaseTime != newValue {
                internalAU?.releaseTime = newValue
            }
        }
    }

    /// Filter attack time (seconds)
    @objc open dynamic var filterAttackTime: Double = 0.0 {
        willSet {
            if filterAttackTime != newValue {
                internalAU?.filterAttackTime = newValue
            }
        }
    }

    /// Filter Decay time (seconds)
    @objc open dynamic var filterDecayTime: Double = 0.0 {
        willSet {
            if filterDecayTime != newValue {
                internalAU?.filterDecayTime = newValue
            }
        }
    }

    /// Filter sustain level (fraction)
    @objc open dynamic var filterSustainLevel: Double = 1.0 {
        willSet {
            if filterSustainLevel != newValue {
                internalAU?.filterSustainLevel = newValue
            }
        }
    }

    /// Filter Release time (seconds)
    @objc open dynamic var filterReleaseTime: Double = 0.0 {
        willSet {
            if filterReleaseTime != newValue {
                internalAU?.filterReleaseTime = newValue
            }
        }
    }

    /// Filter Enable (boolean, 0.0 for false or 1.0 for true)
    @objc open dynamic var filterEnable: Bool = false {
        willSet {
            if filterEnable != newValue {
                internalAU?.filterEnable = newValue ? 1.0 : 0.0
            }
        }
    }

    // MARK: - Initialization

    /// Initialize this sampler node
    ///
    /// - Parameters:
    ///   - input: AKNode whose output will be processed (not used)
    ///   - masterVolume: 0.0 - 1.0
    ///   - pitchBend: semitones, signed
    ///   - vibratoDepth: semitones, typically less than 1.0
    ///   - filterCutoff: relative to sample playback pitch, 1.0 = fundamental, 2.0 = 2nd harmonic etc
    ///   - filterEgStrength: same units as filterCutoff; amount filter EG adds to filterCutoff
    ///   - filterResonance: dB, -20.0 - 20.0
    ///   - attackTime: seconds, 0.0 - 10.0
    ///   - decayTime: seconds, 0.0 - 10.0
    ///   - sustainLevel: 0.0 - 1.0
    ///   - releaseTime: seconds, 0.0 - 10.0
    ///   - filterEnable: true to enable per-voice filters
    ///   - filterAttackTime: seconds, 0.0 - 10.0
    ///   - filterDecayTime: seconds, 0.0 - 10.0
    ///   - filterSustainLevel: 0.0 - 1.0
    ///   - filterReleaseTime: seconds, 0.0 - 10.0
    ///
    @objc public init(
        _ input: AKNode? = nil,
        masterVolume: Double = 1.0,
        pitchBend: Double = 0.0,
        vibratoDepth: Double = 0.0,
        filterCutoff: Double = 4.0,
        filterEgStrength: Double = 20.0,
        filterResonance: Double = 0.0,
        attackTime: Double = 0.0,
        decayTime: Double = 0.0,
        sustainLevel: Double = 1.0,
        releaseTime: Double = 0.0,
        filterEnable: Bool = false,
        filterAttackTime: Double = 0.0,
        filterDecayTime: Double = 0.0,
        filterSustainLevel: Double = 1.0,
        filterReleaseTime: Double = 0.0) {

        self.masterVolume = masterVolume
        self.pitchBend = pitchBend
        self.vibratoDepth = vibratoDepth
        self.filterCutoff = filterCutoff
        self.filterEgStrength = filterEgStrength
        self.filterResonance = filterResonance
        self.attackTime = attackTime
        self.decayTime = decayTime
        self.sustainLevel = sustainLevel
        self.releaseTime = releaseTime
        self.filterEnable = filterEnable
        self.filterAttackTime = filterAttackTime
        self.filterDecayTime = filterDecayTime
        self.filterSustainLevel = filterSustainLevel
        self.filterReleaseTime = filterReleaseTime

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in
            guard let strongSelf = self else {
                AKLog("Error: self is nil")
                return
            }
            strongSelf.avAudioNode = avAudioUnit
            strongSelf.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input?.connect(to: self!)
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        self.masterVolumeParameter = tree["masterVolume"]
        self.pitchBendParameter = tree["pitchBend"]
        self.vibratoDepthParameter = tree["vibratoDepth"]
        self.filterCutoffParameter = tree["filterCutoff"]
        self.filterEgStrengthParameter = tree["filterEgStrength"]
        self.filterResonanceParameter = tree["filterResonance"]
        self.attackTimeParameter = tree["attackTime"]
        self.decayTimeParameter = tree["decayTime"]
        self.sustainLevelParameter = tree["sustainLevel"]
        self.releaseTimeParameter = tree["releaseTime"]
        self.filterAttackTimeParameter = tree["filterAttackTime"]
        self.filterDecayTimeParameter = tree["filterDecayTime"]
        self.filterSustainLevelParameter = tree["filterSustainLevel"]
        self.filterReleaseTimeParameter = tree["filterReleaseTime"]
        self.filterEnableParameter = tree["filterEnable"]

        token = tree.token(byAddingParameterObserver: { [weak self] _, _ in

            guard let _ = self else {
                AKLog("Unable to create strong reference to self")
                return
            } // Replace _ with strongSelf if needed
            DispatchQueue.main.async {
                // This node does not change its own values so we won't add any
                // value observing, but if you need to, this is where that goes.
            }
        })

        self.internalAU?.setParameterImmediately(.masterVolumeParam, value: masterVolume)
        self.internalAU?.setParameterImmediately(.pitchBendParam, value: pitchBend)
        self.internalAU?.setParameterImmediately(.vibratoDepthParam, value: vibratoDepth)
        self.internalAU?.setParameterImmediately(.filterCutoffParam, value: filterCutoff)
        self.internalAU?.setParameterImmediately(.filterEgStrengthParam, value: filterEgStrength)
        self.internalAU?.setParameterImmediately(.filterResonanceParam, value: filterResonance)
        self.internalAU?.setParameterImmediately(.attackTimeParam, value: attackTime)
        self.internalAU?.setParameterImmediately(.decayTimeParam, value: decayTime)
        self.internalAU?.setParameterImmediately(.sustainLevelParam, value: sustainLevel)
        self.internalAU?.setParameterImmediately(.releaseTimeParam, value: releaseTime)
        self.internalAU?.setParameterImmediately(.filterAttackTimeParam, value: filterAttackTime)
        self.internalAU?.setParameterImmediately(.filterDecayTimeParam, value: filterDecayTime)
        self.internalAU?.setParameterImmediately(.filterSustainLevelParam, value: filterSustainLevel)
        self.internalAU?.setParameterImmediately(.filterReleaseTimeParam, value: filterReleaseTime)
        self.internalAU?.setParameterImmediately(.filterEnableParam, value: filterEnable ? 1.0 : 0.0)
    }

    open func loadAKAudioFile(from sampleDescriptor: AKSampleDescriptor, file: AKAudioFile) {
        let sampleRate = Float(file.sampleRate)
        let sampleCount = Int32(file.samplesCount)
        let channelCount = Int32(file.channelCount)
        let flattened = Array(file.floatChannelData!.joined())
        let data = UnsafeMutablePointer<Float>(mutating: flattened)
        internalAU?.loadSampleData(from: AKSampleDataDescriptor(sampleDescriptor: sampleDescriptor,
                                                                sampleRate: sampleRate,
                                                                isInterleaved: false,
                                                                channelCount: channelCount,
                                                                sampleCount: sampleCount,
                                                                data: data) )
    }

    open func stopAllVoices() {
        internalAU?.stopAllVoices()
    }

    open func restartVoices() {
        internalAU?.restartVoices()
    }

    open func loadRawSampleData(from sampleDataDescriptor: AKSampleDataDescriptor) {
        internalAU?.loadSampleData(from: sampleDataDescriptor)
    }

    open func loadCompressedSampleFile(from sampleFileDescriptor: AKSampleFileDescriptor) {
        internalAU?.loadCompressedSampleFile(from: sampleFileDescriptor)
    }

    open func unloadAllSamples() {
        internalAU?.unloadAllSamples()
    }

    open func buildSimpleKeyMap() {
        internalAU?.buildSimpleKeyMap()
    }

    open func buildKeyMap() {
        internalAU?.buildKeyMap()
    }

    open func setLoop(thruRelease: Bool) {
        internalAU?.setLoop(thruRelease: thruRelease)
    }

    open override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, frequency: Double) {
        internalAU?.playNote(noteNumber: noteNumber, velocity: velocity, noteFrequency: Float(frequency))
    }

    open override func stop(noteNumber: MIDINoteNumber) {
        internalAU?.stopNote(noteNumber: noteNumber, immediate: false)
    }

    open func silence(noteNumber: MIDINoteNumber) {
        internalAU?.stopNote(noteNumber: noteNumber, immediate: true)
    }

    open func sustainPedal(pedalDown: Bool) {
        internalAU?.sustainPedal(down: pedalDown)
    }
}