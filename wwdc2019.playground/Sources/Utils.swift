import UIKit

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
    
    /// Resize the image
    ///
    /// - Parameter targetSize: the new size
    /// - Returns: returns the new image
    open func withSize(targetSize: CGSize) -> UIImage? {
        let size = self.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    /// Resize the image with the given perscription
    ///
    /// - Parameter perscription: perscription
    /// - Returns: image resized
    open func withPrescription(perscription: Double, original: CGSize) -> UIImage? {
        let ratio = sizeRatio(for: perscription)
        let newSize = CGSize(width: original.width * ratio, height: original.height * ratio)
        return self.withSize(targetSize: newSize)
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
func distanceRatio(for prescription: Double) -> Double {
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
