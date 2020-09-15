//
//  ViewController.swift
//  demo
//
//  Created by Johan Halin on 12/03/2018.
//  Copyright © 2018 Dekadence. All rights reserved.
//

import UIKit
import AVFoundation
import SceneKit
import Foundation

typealias CurrentModifier = (modifier: Modifier, value1: CGFloat, value2: CGFloat)

class ViewController: UIViewController, SCNSceneRendererDelegate {
    let autostart = true
    
    let audioPlayer: AVAudioPlayer
//    let sceneView = SCNView()
//    let camera = SCNNode()
    let startButton: UIButton
    let qtFoolingBgView: UIView = UIView.init(frame: CGRect.zero)
    let contentView = UIView()
    let yellow = UIColor(red: 247.0 / 255.0, green: 237.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
    let modifiers: [Modifier]

    var wordLabels = [UILabel]()

    var currentBar = 0
    var currentTickInBar = 0
    var currentWord: (word: String, index: Int) = ("", 0)
    var currentWordIndex = 1
    var currentModifier: CurrentModifier? = nil
    var currentModifierIndex = 0

    // MARK: - UIViewController
    
    init() {
        if let trackUrl = Bundle.main.url(forResource: "specialdiscoversion", withExtension: "m4a") {
            guard let audioPlayer = try? AVAudioPlayer(contentsOf: trackUrl) else {
                abort()
            }
            
            self.audioPlayer = audioPlayer
        } else {
            abort()
        }
        
        let camera = SCNCamera()
        camera.zFar = 600
//        camera.vignettingIntensity = 1
//        camera.vignettingPower = 1
//        camera.colorFringeStrength = 3
//        camera.bloomIntensity = 1
//        camera.bloomBlurRadius = 40
//        self.camera.camera = camera // lol
        
        let startButtonText =
            "\"special disco version\"\n" +
                "by jumalauta\n" +
                "\n" +
                "programming and music by ylvaes\n" +
                "\n" +
                "presented at jumalauta 20 years party\n" +
                "\n" +
        "tap anywhere to start"
        self.startButton = UIButton.init(type: UIButton.ButtonType.custom)
        self.startButton.setTitle(startButtonText, for: UIControl.State.normal)
        self.startButton.titleLabel?.numberOfLines = 0
        self.startButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.startButton.backgroundColor = UIColor.black

        self.modifiers = generateModifierList()

        super.init(nibName: nil, bundle: nil)
        
        self.startButton.addTarget(self, action: #selector(startButtonTouched), for: UIControl.Event.touchUpInside)
        
        self.view.backgroundColor = .black
//        self.sceneView.backgroundColor = .black
//        self.sceneView.delegate = self
        
        self.qtFoolingBgView.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        
        // barely visible tiny view for fooling Quicktime player. completely black images are ignored by QT
        self.view.addSubview(self.qtFoolingBgView)
        
//        self.view.addSubview(self.sceneView)

        self.contentView.backgroundColor = self.yellow
        self.contentView.isHidden = true
        self.view.addSubview(self.contentView)

        let labelCount = DemoDictionary.words
            .flatMap { $0 }
            .max(by: { $1.count > $0.count })!
            .count

        for i in 0..<labelCount {
            let label = UILabel()
            label.backgroundColor = .clear
            label.textColor = .black
            label.isHidden = true
            label.lineBreakMode = .byClipping
            label.layer.zPosition = CGFloat(-100 + (i * 10))
            self.contentView.addSubview(label)
            self.wordLabels.append(label)
        }

        self.wordLabels[0].isHidden = false

        self.currentWord = word(index: 0)

        if !self.autostart {
            self.view.addSubview(self.startButton)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.audioPlayer.prepareToPlay()
        
//        self.sceneView.scene = createScene()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.qtFoolingBgView.frame = CGRect(
            x: (self.view.bounds.size.width / 2) - 1,
            y: (self.view.bounds.size.height / 2) - 1,
            width: 2,
            height: 2
        )

//        self.sceneView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
//        self.sceneView.isPlaying = true
//        self.sceneView.isHidden = true

        self.contentView.frame = self.view.bounds

        self.startButton.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)

        setWordLabelFont()

        for label in self.wordLabels {
            positionLabel(label)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.autostart {
            start()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.audioPlayer.stop()
    }
    
    // MARK: - SCNSceneRendererDelegate

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // this function is run in a background thread.
//        DispatchQueue.main.async {
//        }
    }
    
    // MARK: - Private
    
    @objc
    fileprivate func startButtonTouched(button: UIButton) {
        self.startButton.isUserInteractionEnabled = false
        
        // long fadeout to ensure that the home indicator is gone
        UIView.animate(withDuration: 4, animations: {
            self.startButton.alpha = 0
        }, completion: { _ in
            self.start()
        })
    }
    
    fileprivate func start() {
//        self.sceneView.isHidden = false
        
        self.audioPlayer.play()

        self.contentView.isHidden = false

        scheduleEvents()
    }
    
    private func scheduleEvents() {
        let bars = SoundtrackStructure.length

        for bar in 0...bars {
            let barStart = Double(bar) * SoundtrackConfig.barLength

            for tick in 0..<16 {
                let currentTick = barStart + (Double(tick) * SoundtrackConfig.tickLength)

                perform(#selector(event), with: nil, afterDelay: currentTick)
            }
        }
    }

    @objc private func event() {
        self.currentTickInBar += 1

        if self.currentTickInBar >= 16 {
            self.currentTickInBar = 0
            self.currentBar += 1

            switch self.currentBar {
            case SoundtrackStructure.quietHit1,
                 SoundtrackStructure.quietHit2:
                print("todo")
            case SoundtrackStructure.loudHit1,
                 SoundtrackStructure.loudHit2,
                 SoundtrackStructure.loudHit3:
                print("todo")
            case SoundtrackStructure.end:
                print("todo")
                self.contentView.isHidden = true // FIXME
            default:
                break
            }
        }

        for label in self.wordLabels {
            if self.currentWordIndex == 0 {
                for label in self.wordLabels {
                    label.isHidden = true
                    positionLabel(label)
                    label.transform = .identity
                    label.layer.transform = CATransform3DIdentity
                }

                self.wordLabels[0].isHidden = false
            }

            label.text = String(self.currentWord.word.prefix(self.currentWordIndex))
        }

        if let modifier = self.currentModifier {
            applyModifier(modifier, index: self.currentWordIndex, count: self.currentWord.word.count)
        }

        self.currentWordIndex += 1

        if self.currentWordIndex > self.currentWord.word.count {
            self.currentWordIndex = 0

            let groupIndex: Int
            if self.currentWord.index == 2 {
                groupIndex = 0

                if self.currentBar >= SoundtrackStructure.modifierStart {
                    self.currentModifier = (
                        modifier: self.modifiers[self.currentModifierIndex],
                        value1: randomRange(),
                        value2: randomRange()
                    )

                    self.currentModifierIndex += 1
                }
            } else {
                groupIndex = self.currentWord.index + 1
            }

            self.currentWord = word(index: groupIndex)
        }
    }

    func positionLabel(_ label: UILabel) {
        label.text = self.currentWord.word
        label.sizeToFit()
        label.frame = CGRect(
            x: self.view.bounds.midX - (label.bounds.size.width / 2.0),
            y: self.view.bounds.midY - (label.bounds.size.height / 2.0),
            width: label.bounds.size.width,
            height: label.bounds.size.height
        )
        label.text = ""
    }
    
    func word(index: Int) -> (word: String, index: Int) {
        if self.currentBar < 43 {
            return (DemoDictionary.words[index].randomElement()!, index)
        } else {
            return (DemoDictionary.words[index][0], index)
        }
    }

    func applyModifier(_ modifier: CurrentModifier, index: Int, count: Int) {
        if index < 2 || modifier.modifier == .none {
            return
        }

        let correctedIndex = index - 1
        let label = self.wordLabels[correctedIndex]
        label.isHidden = false
        label.textColor = UIColor(white: CGFloat(correctedIndex - 1) / CGFloat(count), alpha: 1.0)

//        let mod = Modifier.modifyXModifyY(animated: false)

        switch modifier.modifier {
//        switch mod {
        case .none:
            break
        case .modifyX(animated: let animated):
            label.frame.origin.x += modifier.value1 * CGFloat(correctedIndex - 1)
            modifyViews(animated: animated, block: {
                label.frame.origin.x += modifier.value1
            })
        case .modifyY(animated: let animated):
            label.frame.origin.y += modifier.value1 * CGFloat(correctedIndex - 1)
            modifyViews(animated: animated, block: {
                label.frame.origin.y += modifier.value1
            })
        case .modifyXModifyY(animated: let animated):
            label.frame.origin.x += modifier.value1 * CGFloat(correctedIndex - 1)
            label.frame.origin.y += modifier.value2 * CGFloat(correctedIndex - 1)
            modifyViews(animated: animated, block: {
                label.frame.origin.x += modifier.value1
                label.frame.origin.y += modifier.value2
            })
        case .random(animated: let animated):
            modifyViews(animated: animated, block: {
                label.frame.origin.x += CGFloat.random(in: abs(modifier.value1)...abs(modifier.value1) * 2) * (Bool.random() ? -1 : 1)
                label.frame.origin.y += CGFloat.random(in: abs(modifier.value1)...abs(modifier.value1) * 2) * (Bool.random() ? -1 : 1)
            })
        case .rotate2d(animated: let animated):
            label.transform = CGAffineTransform.identity
                .translatedBy(x: CGFloat(10 * (correctedIndex - 1)), y: 0)
                .rotated(by: 0.5 * (CGFloat(correctedIndex - 1) / CGFloat(count)))
            modifyViews(animated: animated, block: {
                label.transform = CGAffineTransform.identity
                    .translatedBy(x: CGFloat(10 * correctedIndex), y: 0)
                    .rotated(by: 0.5 * (CGFloat(correctedIndex) / CGFloat(count)))
            })
        case .rotate3d(animated: let animated):
            label.layer.transform.m34 = -0.002
            label.layer.transform = CATransform3DRotate(CATransform3DIdentity, (CGFloat(correctedIndex - 1) / CGFloat(count)), 1, 1, 1)
            modifyViews(animated: animated, block: {
                label.layer.transform = CATransform3DRotate(label.layer.transform, (CGFloat(correctedIndex) / CGFloat(count)), 1, 1, 1)
            })
            break
        }
    }

    func modifyViews(animated: Bool, block: @escaping () -> ()) {
        if animated {
            UIView.animate(withDuration: SoundtrackConfig.tickLength, delay: 0, options: [.curveLinear], animations: block, completion: nil)
        } else {
            block()
        }
    }

    func setWordLabelFont() {
        // first pass: figure out which word is the widest

        let firstPassFont = UIFont.systemFont(ofSize: 24, weight: .heavy)
        let label = UILabel(frame: .zero)
        label.font = firstPassFont

        var widestWord: (word: String, width: CGFloat)? = nil

        for wordGroup in DemoDictionary.words {
            for word in wordGroup {
                label.text = word
                label.sizeToFit()

                if let wideWord = widestWord {
                    if label.bounds.size.width > wideWord.width {
                        widestWord = (word, label.bounds.size.width)
                    }
                } else {
                    widestWord = (word, label.bounds.size.width)
                }
            }
        }

        // second pass: figure out the max width

        var maxSizeFound = false
        let maxWidth = self.view.bounds.size.width
        var fontSize = 24

        label.text = widestWord!.word

        while !maxSizeFound {
            let font = UIFont.systemFont(ofSize: CGFloat(fontSize), weight: .heavy)
            label.font = font
            label.sizeToFit()

            if label.bounds.size.width < maxWidth {
                fontSize += 1
            } else {
                fontSize -= 1
                maxSizeFound = true
            }
        }

        // done!

        for label in self.wordLabels {
            label.font = UIFont.systemFont(ofSize: CGFloat(fontSize), weight: .heavy)
        }
    }

    fileprivate func createScene() -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor.black
        
//        self.camera.position = SCNVector3Make(0, 0, 58)
//        
//        scene.rootNode.addChildNode(self.camera)
        
        configureLight(scene)
        
        return scene
    }
    
    fileprivate func configureLight(_ scene: SCNScene) {
        let omniLightNode = SCNNode()
        omniLightNode.light = SCNLight()
        omniLightNode.light?.type = SCNLight.LightType.omni
        omniLightNode.light?.color = UIColor(white: 1.0, alpha: 1.0)
        omniLightNode.position = SCNVector3Make(0, 0, 60)
        scene.rootNode.addChildNode(omniLightNode)
    }
}
