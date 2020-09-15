//
//  Modifiers.swift
//  demo
//
//  Created by Johan Halin on 14.9.2020.
//  Copyright © 2020 Dekadence. All rights reserved.
//

import Foundation
import UIKit

enum Modifier: Equatable {
    case none
    case modifyX(animated: Bool)
    case modifyY(animated: Bool)
    case modifyXModifyY(animated: Bool)
    case random(animated: Bool)
    case rotate2d(animated: Bool)
    case rotate3d(animated: Bool)
}

func generateModifierList() -> [Modifier] {
    let shortestSequence = DemoDictionary.words[0].min(by: { $0.count < $1.count })!.count
        + DemoDictionary.words[1].min(by: { $0.count < $1.count })!.count
        + DemoDictionary.words[2].min(by: { $0.count < $1.count })!.count
        + 2 // "spaces"
    let length = (SoundtrackStructure.length * 16) - SoundtrackStructure.modifierStart
    let sequenceCount = length / shortestSequence

    let allModifiers: [Modifier] = [
        .none,
        .modifyX(animated: false),
        .modifyY(animated: false),
        .modifyXModifyY(animated: false),
        .random(animated: false),
        .rotate2d(animated: false),
        .rotate2d(animated: false),
        .modifyX(animated: true),
        .modifyY(animated: true),
        .modifyXModifyY(animated: true),
        .random(animated: true),
        .rotate2d(animated: true),
        .rotate2d(animated: true),
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

func randomRange() -> CGFloat {
    return CGFloat.random(in: 10...30) * CGFloat(Bool.random() ? -1 : 1)
}
