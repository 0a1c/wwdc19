import UIKit
import AVFoundation

struct Constants {
    
}

public let darkGrayColor = UIColor(rgb: 0x0A0A0A)
public let offwhiteColor = UIColor(rgb: 0xF0F1EC)

public struct Screen {
    /// Retrieves the device bounds.
    public static var bounds: CGRect {
        return UIScreen.main.bounds
    }
    
    /// Retrieves the device width.
    public static var width: CGFloat {
        return bounds.width
    }
    
    /// Retrieves the device height.
    public static var height: CGFloat {
        return bounds.height
    }
    
    /// Retrieves the device scale.
    public static var scale: CGFloat {
        return UIScreen.main.scale
    }
}

extension UIImage {
    /**
     Creates a new image with the passed in color.
     - Parameter color: The UIColor to create the image from.
     - Returns: A UIImage that is the color passed in.
     */
    open func tint(with color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, Screen.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -size.height)
        
        context.setBlendMode(.multiply)
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.clip(to: rect, mask: cgImage!)
        color.setFill()
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image?.withRenderingMode(.alwaysOriginal)
    }
    
    /// resize image
    ///
    /// - Parameter newSize: new size
    /// - Returns: image resized
    open func withSize(newSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let image = renderer.image { _ in
            self.draw(in: CGRect.init(origin: CGPoint.zero, size: newSize))
        }
        return image
    }
    
    /// Resize the image with the given perscription
    ///
    /// - Parameter perscription: perscription
    /// - Returns: image resized
    open func withPrescription(perscription: Double, original: CGSize) -> UIImage? {
        let ratio = sizeRatio(for: perscription)
        let newSize = CGSize(width: original.width * ratio, height: original.height * ratio)
        return self.withSize(newSize: newSize)
    }
}


/// One over the distance ratio
///
/// - Parameter prescription: prescription
/// - Returns: ratio to resize
func sizeRatio(for prescription: Double) -> CGFloat {
    return 1 / sqrt(CGFloat(distanceRatio(for: prescription)))
}

/// Distance ratio of total feet / 20
///
/// - Parameter prescription: prescription
/// - Returns: ratio
public func distanceRatio(for prescription: Double) -> Double {
    if prescription < 0.5 {
        return 1
    } else if prescription < 2.5 {
        return 1.875 * prescription + 0.25
    } else if prescription < 3.75 {
        return 5.6 * prescription - 9.33
    } else {
        return 12 * prescription - 33
    }
}

/// return sigma value for blur
///
/// - Parameter prescription: prescription
/// - Returns: sigma
public func blurForPrescription(_ prescription: Double) -> Double {
    return sqrt((distanceRatio(for: prescription) - 1) / Double.pi)
}

/// Created attributed string for prescription label (highlight value)
///
/// - Parameter prescription: prescription
/// - Returns: the attributed string
public func stringForPrescription(prescription: Double) -> NSAttributedString {
    let prescriptionValue = String(format: "%.1f", prescription)
    let baseAttrs: [NSAttributedString.Key: Any] = [ NSAttributedString.Key.foregroundColor: offwhiteColor, NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 16)! ]
    let attrString = NSMutableAttributedString(string: "prescription: " + prescriptionValue, attributes: baseAttrs)
    let range = NSRange(location: 0, length: 13)
    let lowerOpacity = [NSAttributedString.Key.foregroundColor: offwhiteColor.withAlphaComponent(0.7), NSAttributedString.Key.font: UIFont(name: "Avenir-Book", size: 16)!]
    attrString.addAttributes(lowerOpacity, range: range)
    return attrString
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension UIScreen {
    open var orientation: UIDeviceOrientation {
        let point = coordinateSpace.convert(CGPoint.zero, to: fixedCoordinateSpace)
        switch (point.x, point.y) {
        case (0, 0):
            return .portrait
        case let (x, y) where x != 0 && y != 0:
            return .portraitUpsideDown
        case let (0, y) where y != 0:
            return .landscapeLeft
        case let (x, 0) where x != 0:
            return .landscapeRight
        default:
            return .unknown
        }
    }
}
