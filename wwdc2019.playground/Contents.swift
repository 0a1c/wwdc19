//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

// quality of live camera (default is high)
// options are .low, .medium, and .high
var quality: Quality = Quality.high

let visionVC = VisionViewController()
visionVC.quality = quality
PlaygroundPage.current.liveView = visionVC


