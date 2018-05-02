//
//  AKSamplerAudioUnit.swift
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKSamplerAudioUnit: AKGeneratorAudioUnitBase {

    var pDSP: UnsafeMutableRawPointer?

    func setParameter(_ address: AKSamplerParameter, value: Double) {
        setParameterWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    func setParameterImmediately(_ address: AKSamplerParameter, value: Double) {
        setParameterImmediatelyWithAddress(AUParameterAddress(address.rawValue), value: Float(value))
    }

    var masterVolume: Double = 0.0 {
        didSet { setParameter(.masterVolumeParam, value: masterVolume) }
    }

    var pitchBend: Double = 0.0 {
        didSet { setParameter(.pitchBendParam, value: pitchBend) }
    }

    var vibratoDepth: Double = 1.0 {
        didSet { setParameter(.vibratoDepthParam, value: vibratoDepth) }
    }

    var filterCutoff: Double = 4.0 {
        didSet { setParameter(.filterCutoffParam, value: filterCutoff) }
    }

    var filterEgStrength: Double = 20.0 {
        didSet { setParameter(.filterEgStrengthParam, value: filterCutoff) }
    }

    var filterResonance: Double = 0.0 {
        didSet { setParameter(.filterResonanceParam, value: filterResonance) }
    }

    var rampTime: Double = 0.0 {
        didSet { setParameter(.rampTimeParam, value: rampTime) }
    }

    var attackTime: Double = 0.0 {
        didSet { setParameter(.attackTimeParam, value: attackTime) }
    }

    var decayTime: Double = 0.0 {
        didSet { setParameter(.decayTimeParam, value: decayTime) }
    }

    var sustainLevel: Double = 0.0 {
        didSet { setParameter(.sustainLevelParam, value: sustainLevel) }
    }

    var releaseTime: Double = 0.0 {
        didSet { setParameter(.releaseTimeParam, value: releaseTime) }
    }

    var filterAttackTime: Double = 0.0 {
        didSet { setParameter(.filterAttackTimeParam, value: filterAttackTime) }
    }

    var filterDecayTime: Double = 0.0 {
        didSet { setParameter(.filterDecayTimeParam, value: filterDecayTime) }
    }

    var filterSustainLevel: Double = 0.0 {
        didSet { setParameter(.filterSustainLevelParam, value: filterSustainLevel) }
    }

    var filterReleaseTime: Double = 0.0 {
        didSet { setParameter(.filterReleaseTimeParam, value: filterReleaseTime) }
    }

    var filterEnable: Double = 0.0 {
        didSet { setParameter(.filterEnableParam, value: filterEnable) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> UnsafeMutableRawPointer! {
        pDSP = createAKSamplerDSP(Int32(count), sampleRate)
        return pDSP
    }

    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let rampFlags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp]
        let nonRampFlags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable]

        var paramAddress = 0
        let masterVolumeParam = AUParameterTree.createParameter(withIdentifier: "masterVolume",
                                                                name: "Master Volume",
                                                                address: AUParameterAddress(paramAddress),
                                                                min: 0.0, max: 1.0,
                                                                unit: .generic, unitName: nil,
                                                                flags: rampFlags,
                                                                valueStrings: nil, dependentParameters: nil)
        paramAddress += 1
        let pitchBendParam = AUParameterTree.createParameter(withIdentifier: "pitchBend",
                                                       name: "Pitch Offset (semitones)",
                                                       address: AUParameterAddress(paramAddress),
                                                       min: -1_000.0, max: 1_000.0,
                                                       unit: .relativeSemiTones, unitName: nil,
                                                       flags: rampFlags,
                                                       valueStrings: nil, dependentParameters: nil)
        paramAddress += 1
        let vibratoDepthParam = AUParameterTree.createParameter(withIdentifier: "vibratoDepth",
                                                        name: "Vibrato amount (semitones)",
                                                        address: AUParameterAddress(paramAddress),
                                                        min: 0.0, max: 24.0,
                                                        unit: .relativeSemiTones, unitName: nil,
                                                        flags: rampFlags,
                                                        valueStrings: nil, dependentParameters: nil)
        paramAddress += 1
        let filterCutoffParam = AUParameterTree.createParameter(withIdentifier: "filterCutoff",
                                                                name: "Filter cutoff (harmonic))",
                                                                address: AUParameterAddress(paramAddress),
                                                                min: 1.0, max: 1_000.0,
                                                                unit: .ratio, unitName: nil,
                                                                flags: rampFlags,
                                                                valueStrings: nil, dependentParameters: nil)
        paramAddress += 1
        let filterEgStrengthParam = AUParameterTree.createParameter(withIdentifier: "filterEgStrength",
                                                                name: "Filter EG strength",
                                                                address: AUParameterAddress(paramAddress),
                                                                min: 0.0, max: 1_000.0,
                                                                unit: .ratio, unitName: nil,
                                                                flags: rampFlags,
                                                                valueStrings: nil, dependentParameters: nil)
        paramAddress += 1
        let filterResonanceParam = AUParameterTree.createParameter(withIdentifier: "filterResonance",
                                                                name: "Filter resonance (dB))",
                                                                address: AUParameterAddress(paramAddress),
                                                                min: -20.0, max: 20.0,
                                                                unit: .decibels, unitName: nil,
                                                                flags: rampFlags,
                                                                valueStrings: nil, dependentParameters: nil)

        paramAddress += 1
        let attackTimeParam = AUParameterTree.createParameter(withIdentifier: "attackTime",
                                                                name: "Amp Attack time (seconds)",
                                                                address: AUParameterAddress(paramAddress),
                                                                min: 0.0, max: 1_000.0,
                                                                unit: .seconds, unitName: nil,
                                                                flags: nonRampFlags,
                                                                valueStrings: nil, dependentParameters: nil)
        paramAddress += 1
        let decayTimeParam = AUParameterTree.createParameter(withIdentifier: "decayTime",
                                                              name: "Amp Decay time (seconds)",
                                                              address: AUParameterAddress(paramAddress),
                                                              min: 0.0, max: 1_000.0,
                                                              unit: .seconds, unitName: nil,
                                                              flags: nonRampFlags,
                                                              valueStrings: nil, dependentParameters: nil)
        paramAddress += 1
        let sustainLevelParam = AUParameterTree.createParameter(withIdentifier: "sustainLevel",
                                                             name: "Amp Sustain level (fraction)",
                                                             address: AUParameterAddress(paramAddress),
                                                             min: 0.0, max: 1.0,
                                                             unit: .generic, unitName: nil,
                                                             flags: nonRampFlags,
                                                             valueStrings: nil, dependentParameters: nil)
        paramAddress += 1
        let releaseTimeParam = AUParameterTree.createParameter(withIdentifier: "releaseTime",
                                                              name: "Amp Release time (seconds)",
                                                              address: AUParameterAddress(paramAddress),
                                                              min: 0.0, max: 1_000.0,
                                                              unit: .seconds, unitName: nil,
                                                              flags: nonRampFlags,
                                                              valueStrings: nil, dependentParameters: nil)
        paramAddress += 1
        let filterAttackTimeParam = AUParameterTree.createParameter(withIdentifier: "filterAttackTime",
                                                                 name: "Filter Attack time (seconds)",
                                                                 address: AUParameterAddress(paramAddress),
                                                                 min: 0.0, max: 1_000.0,
                                                                 unit: .seconds, unitName: nil,
                                                                 flags: nonRampFlags,
                                                                 valueStrings: nil, dependentParameters: nil)
        paramAddress += 1
        let filterDecayTimeParam = AUParameterTree.createParameter(withIdentifier: "filterDecayTime",
                                                                name: "Filter Decay time (seconds)",
                                                                address: AUParameterAddress(paramAddress),
                                                                min: 0.0, max: 1_000.0,
                                                                unit: .seconds, unitName: nil,
                                                                flags: nonRampFlags,
                                                                valueStrings: nil, dependentParameters: nil)
        paramAddress += 1
        let filterSustainLevelParam = AUParameterTree.createParameter(withIdentifier: "filterSustainLevel",
                                                                   name: "Filter Sustain level (fraction)",
                                                                   address: AUParameterAddress(paramAddress),
                                                                   min: 0.0, max: 1.0,
                                                                   unit: .generic, unitName: nil,
                                                                   flags: nonRampFlags,
                                                                   valueStrings: nil, dependentParameters: nil)
        paramAddress += 1
        let filterReleaseTimeParam = AUParameterTree.createParameter(withIdentifier: "filterReleaseTime",
                                                                  name: "Filter Release time (seconds)",
                                                                  address: AUParameterAddress(paramAddress),
                                                                  min: 0.0, max: 1_000.0,
                                                                  unit: .seconds, unitName: nil,
                                                                  flags: nonRampFlags,
                                                                  valueStrings: nil, dependentParameters: nil)
        paramAddress += 1
        let filterEnableParam = AUParameterTree.createParameter(withIdentifier: "filterEnable",
                                                                     name: "Filter Enable",
                                                                     address: AUParameterAddress(paramAddress),
                                                                     min: 0.0, max: 1.0,
                                                                     unit: .boolean, unitName: nil,
                                                                     flags: nonRampFlags,
                                                                     valueStrings: nil, dependentParameters: nil)

        setParameterTree(AUParameterTree.createTree(withChildren: [masterVolumeParam, pitchBendParam, vibratoDepthParam,
                                                                   filterCutoffParam, filterEgStrengthParam, filterResonanceParam,
                                                                   attackTimeParam, decayTimeParam,
                                                                   sustainLevelParam, releaseTimeParam,
                                                                   filterAttackTimeParam, filterDecayTimeParam,
                                                                   filterSustainLevelParam, filterReleaseTimeParam,
                                                                   filterEnableParam ]))
        masterVolumeParam.value = 1.0
        pitchBendParam.value = 0.0
        vibratoDepthParam.value = 0.0
        filterCutoffParam.value = 4.0
        filterEgStrengthParam.value = 20.0
        filterResonanceParam.value = 0.0
        attackTimeParam.value = 0.0
        decayTimeParam.value = 0.0
        sustainLevelParam.value = 1.0
        releaseTimeParam.value = 0.0
        filterAttackTimeParam.value = 0.0
        filterDecayTimeParam.value = 0.0
        filterSustainLevelParam.value = 1.0
        filterReleaseTimeParam.value = 0.0
        filterEnableParam.value = 0.0
    }

    public override var canProcessInPlace: Bool { return true; }

    public func stopAllVoices() {
        doAKSamplerStopAllVoices(pDSP)
    }

    public func restartVoices() {
        doAKSamplerRestartVoices(pDSP)
    }

    public func loadSampleData(from sampleDataDescriptor: AKSampleDataDescriptor) {
        var copy = sampleDataDescriptor
        doAKSamplerLoadData(pDSP, &copy)
    }

    public func loadCompressedSampleFile(from sampleFileDescriptor: AKSampleFileDescriptor) {
        var copy = sampleFileDescriptor
        doAKSamplerLoadCompressedFile(pDSP, &copy)
    }

    public func unloadAllSamples() {
        doAKSamplerUnloadAllSamples(pDSP)
    }

    public func buildSimpleKeyMap() {
        doAKSamplerBuildSimpleKeyMap(pDSP)
    }

    public func buildKeyMap() {
        doAKSamplerBuildKeyMap(pDSP)
    }

    public func setLoop(thruRelease: Bool) {
        doAKSamplerSetLoopThruRelease(pDSP, thruRelease)
    }

    public func playNote(noteNumber: UInt8, velocity: UInt8, noteFrequency: Float) {
        doAKSamplerPlayNote(pDSP, noteNumber, velocity, noteFrequency)
    }

    public func stopNote(noteNumber: UInt8, immediate: Bool) {
        doAKSamplerStopNote(pDSP, noteNumber, immediate)
    }

    public func sustainPedal(down: Bool) {
        doAKSamplerSustainPedal(pDSP, down)
    }

}