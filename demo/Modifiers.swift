//
//  Modifiers.swift
//  demo
//
//  Created by Johan Halin on 14.9.2020.
//  Copyright © 2020 Dekadence. All rights reserved.
//

import Foundation

enum Modifier: Equatable {
    case none
    case addX(animated: Bool)
    case addY(animated: Bool)
    case subY(animated: Bool)
    case addXAddY(animated: Bool)
    case addXSubY(animated: Bool)
    case random(animated: Bool)
    case scaleUp(animated: Bool)
    case scaleDown(animated: Bool)
    case rotate2d(animated: Bool)
    case rotate3d(animated: Bool)
}

func generateModifierList() -> [Modifier] {
    let shortestSequence = DemoDictionary.words[0].min(by: { $0.count < $1.count })!.count
        + DemoDictionary.words[1].min(by: { $0.count < $1.count })!.count
        + DemoDictionary.words[2].min(by: { $0.count < $1.count })!.count
        + 2 // "spaces"
    let length = SoundtrackStructure.length * 16
    let sequenceCount = length / shortestSequence
    let allModifiers: [Modifier] = [
        .none,
        .addX(animated: false),
        .addY(animated: false),
        .subY(animated: false),
        .addXAddY(animated: false),
        .addXSubY(animated: false),
        .random(animated: false),
        .scaleUp(animated: false),
        .scaleDown(animated: false),
        .rotate2d(animated: false),
        .rotate3d(animated: false),
        .addX(animated: true),
        .addY(animated: true),
        .subY(animated: true),
        .addXAddY(animated: true),
        .addXSubY(animated: true),
        .random(animated: true),
        .scaleUp(animated: true),
        .scaleDown(animated: true),
        .rotate2d(animated: true),
        .rotate3d(animated: true),
    ]

    var modifiers = [Modifier]()

    for _ in 0..<sequenceCount {
        var contentsOk = false
        var shuffledModifiers: [Modifier] = []

        while !contentsOk {
            let mods = allModifiers.shuffled()

            if let lastMod = modifiers.last {
                if mods.last != lastMod {
                    shuffledModifiers = mods
                    contentsOk = true
                }
            } else {
                shuffledModifiers = mods
                contentsOk = true
            }
        }

        modifiers.append(contentsOf: shuffledModifiers)
    }

    return modifiers
}
