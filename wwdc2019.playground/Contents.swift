//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport


class VisionViewController: UIViewController {
    
    private var imageView: UIImageView!
    private var prescriptionSlider: UISlider!
    private var prescription: Double = 0
    private var currentPrescriptionLabel: UILabel!
    private var arButton: UIButton!
    private var nextImageButton: UIButton!
    
    private var displayImages: [UIImage] = []
    private var currentImageIndex: Int = 0

    private var width: CGFloat!
    private var height: CGFloat!
    var baseView: UIView!

    override func loadView() {
        displayImages = [UIImage(named: "applepark.jpg")!, UIImage(named: "wwdc.jpg")!, UIImage(named: "poster.jpg")!]
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        view.backgroundColor = UIColor.white
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        width = self.view.frame.width
        height = self.view.frame.height
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageView.frame
        view.frame
        view.addSubview(imageView)

        displayImage(UIImage(named: "wwdc.jpg")!, prescription: 0)
        
        initControlBackground()
        initSlider()
        initLabel()
        initButtons()
    }
    
    /// Displays the given image
    ///
    /// - Parameter largeImage: image to display
    private func displayImage(_ image: UIImage, prescription: Double) {
        let largeImage = image
        let heightRatio = largeImage.size.height / largeImage.size.width
        guard let resizedImage = largeImage.withSize(targetSize: CGSize(width: 2 * width, height: 2 * heightRatio * width)) else { return }
        let prescriptionImage = resizedImage.withPrescription(perscription: prescription, original: resizedImage.size)
        imageView.image = prescriptionImage
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
    }
    
    private func initControlBackground() {
        height
        let controlBackground = UIView(frame: CGRect(x: 0, y: height * 0.9, width: width, height: height * 0.2))
        controlBackground.layer.cornerRadius = 20
        controlBackground.layer.masksToBounds = true
        controlBackground.backgroundColor = darkGrayColor
        view.addSubview(controlBackground)
    }
    
    /// initialize the slider
    private func initSlider() {
        imageView.bounds.maxY
        imageView.bounds.maxY * 0.2
        height
        let widthScale: CGFloat = 0.7
        prescriptionSlider = UISlider(frame: CGRect(x: CGFloat((1 - widthScale) / 2) * width, y: height * 0.95, width: width * widthScale, height: height * 0.04))
        prescriptionSlider.frame
        prescriptionSlider.maximumValue = 4
        prescriptionSlider.minimumValue = 0
        prescriptionSlider.tintColor = offwhiteColor
        prescriptionSlider.value = 0
        prescriptionSlider.maximumTrackTintColor = UIColor.darkGray
        prescriptionSlider.transform = CGAffineTransform(scaleX: 0.666, y: 0.666)
        prescriptionSlider.addTarget(self, action: #selector(updatePrescription(sender:)), for: .valueChanged)
        view.addSubview(prescriptionSlider)
    }

    private func initLabel() {
        let widthScale: CGFloat = 0.6
        currentPrescriptionLabel = UILabel(frame: CGRect(x: CGFloat((1 - widthScale) / 2) * width, y: height * 0.91, width: width * widthScale, height: height * 0.03))
        currentPrescriptionLabel.textAlignment = .center
        currentPrescriptionLabel.font = UIFont(name: "Avenir-Medium", size: 18)
        currentPrescriptionLabel.textColor = offwhiteColor
        currentPrescriptionLabel.attributedText = stringForPrescription(prescription: self.prescription)
        view.addSubview(currentPrescriptionLabel)
    }
    
    private func initButtons() {
        let widthScale: CGFloat = 0.15
        nextImageButton = UIButton(frame: CGRect(x: (0.125 - widthScale / 2) * width, y: 0.925 * height, width: width * widthScale, height: height * 0.05))
        nextImageButton.setImage(UIImage(named: "picture")?.tint(with: offwhiteColor), for: .normal)
        nextImageButton.imageView?.contentMode = .scaleAspectFit
        nextImageButton.addTarget(self, action: #selector(nextImage), for: .touchUpInside)
        view.addSubview(nextImageButton)
        
        arButton = UIButton(frame: CGRect(x: (0.875 - widthScale / 2) * width, y: 0.925 * height, width: width * widthScale, height: height * 0.05))
        arButton.setImage(UIImage(named: "camera")?.tint(with: offwhiteColor), for: .normal)
        arButton.imageView?.contentMode = .scaleAspectFit
        arButton.addTarget(self, action: #selector(switchToAR), for: .touchUpInside)
        view.addSubview(arButton)
        
    }
    
    @objc func switchToAR() {
        print("switching to ar!")
    }
    
    @objc func nextImage() {
        currentImageIndex = (currentImageIndex + 1) % displayImages.count
        displayImage(displayImages[currentImageIndex], prescription: prescription)
    }
    
    @objc func updatePrescription(sender: UISlider) {
        prescription = Double(sender.value)
        let when = DispatchTime.now() + 0.1
        DispatchQueue.main.asyncAfter(deadline: when) {
            if self.prescription == Double(sender.value) {
                self.displayImage(self.displayImages[self.currentImageIndex], prescription: self.prescription)
                self.currentPrescriptionLabel.attributedText = stringForPrescription(prescription: self.prescription)
            }
        }
    }
}

func stringForPrescription(prescription: Double) -> NSAttributedString {
    let prescriptionValue = String(format: "%.1f", prescription)
    let baseAttrs: [NSAttributedString.Key: Any] = [ NSAttributedString.Key.foregroundColor: offwhiteColor, NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 16)! ]
    let attrString = NSMutableAttributedString(string: "prescription: " + prescriptionValue, attributes: baseAttrs)
    let range = NSRange(location: 0, length: 13)
    let lowerOpacity = [NSAttributedString.Key.foregroundColor: offwhiteColor.withAlphaComponent(0.7), NSAttributedString.Key.font: UIFont(name: "Avenir-Book", size: 16)!]
    attrString.addAttributes(lowerOpacity, range: range)
    return attrString
}



//PlaygroundPage.current.needsIndefiniteExecution = true

// Present the view controller in the Live View window
let visionVC = VisionViewController()
PlaygroundPage.current.liveView = visionVC


