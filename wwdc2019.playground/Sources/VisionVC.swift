import AVFoundation
import PlaygroundSupport
import UIKit

public final class VisionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    // ui elements
    private var imageView: UIImageView = UIImageView()
    private var prescriptionSlider: UISlider = UISlider()
    private var currentPrescriptionLabel: UILabel = UILabel()
    private var arButton: UIButton = UIButton()
    private var nextImageButton: UIButton = UIButton()
    private var controlBackground: UIView = UIView()
    
    /// currently simulating prescription
    private var prescription: Double = 0
    
    /// all images to display
    private var displayImages: [UIImage] = []
    /// currently displayed image
    private var currentImageIndex: Int = 0
    
    // width and height of screen
    private var width: CGFloat!
    private var height: CGFloat!
    
    // live camera properties
    private var displayingAR: Bool = false
    private var cameraSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    public var quality: Quality = .low
    
    override public func loadView() {
        displayImages = [UIImage(named: "applepark.png")!, UIImage(named: "wwdc.png")!, UIImage(named: "poster.png")!]
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        view.backgroundColor = UIColor.white
        self.view = view
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        initAll()
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateAll()
    }
    
    /// initialize all ui elements
    private func initAll() {
        width = self.view.frame.width
        height = self.view.frame.height
        
        initImageView()
        initControlBackground()
        initSlider()
        initLabel()
        initButtons()
        
        displayImage(image: displayImages[currentImageIndex])
    }
    
    /// update frames for all ui elements
    private func updateAll() {
        width = self.view.frame.width
        height = self.view.frame.height
        updateImageView()
        updateControlBackground()
        updateSlider()
        updateLabel()
        updateButtons()
    }
    
    private func initImageView() {
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin]
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)
    }
    
    private func updateImageView() {
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
    }
    
    /// Display the image
    ///
    /// - Parameters:
    ///   - ciimage: ciimage input
    ///   - prescription: prescription
    private func displayImage(ciimage: CIImage) {
        // Added "CIAffineClamp" filter
        let blurRadius = blurForPrescription(self.prescription)
        let affineClampFilter = CIFilter(name: "CIAffineClamp")!
        affineClampFilter.setDefaults()
        affineClampFilter.setValue(ciimage, forKey: kCIInputImageKey)
        let resultClamp = affineClampFilter.value(forKey: kCIOutputImageKey)
        
        // resultClamp is used as input for "CIGaussianBlur" filter
        let filter: CIFilter = CIFilter(name:"CIGaussianBlur")!
        filter.setDefaults()
        filter.setValue(resultClamp, forKey: kCIInputImageKey)
        filter.setValue(blurRadius, forKey: kCIInputRadiusKey)
        
        let ciContext = CIContext(options: nil)
        guard let result = filter.value(forKey: kCIOutputImageKey) as? CIImage else { return }
        guard let cgImage = ciContext.createCGImage(result, from: ciimage.extent, format: CIFormat.RGBAh, colorSpace: nil) else { return }
        
        let image = UIImage(cgImage: cgImage)
        DispatchQueue.main.async {
            self.imageView.image = image
        }
    }
    
    private func displayImage(image: UIImage) {
        guard let ciimage = CIImage(image: image) else { return }
        displayImage(ciimage: ciimage)
    }
    
    private func initControlBackground() {
        controlBackground.backgroundColor = darkGrayColor
        view.addSubview(controlBackground)
    }
    
    private func updateControlBackground() {
        controlBackground.frame = CGRect(x: 0, y: height * 0.9, width: width, height: height * 0.15)
        
    }
    
    /// initialize the slider
    private func initSlider() {
        prescriptionSlider.maximumValue = 4
        prescriptionSlider.minimumValue = 0
        prescriptionSlider.tintColor = offwhiteColor
        prescriptionSlider.value = 0
        prescriptionSlider.maximumTrackTintColor = UIColor.darkGray
        prescriptionSlider.addTarget(self, action: #selector(updatePrescription(sender:)), for: .valueChanged)
        view.addSubview(prescriptionSlider)
    }
    
    private func updateSlider() {
        let widthScale: CGFloat = 0.4
        prescriptionSlider.frame = CGRect(x: CGFloat(0.5 - widthScale / 2) * width, y: height * 0.95, width: width * widthScale, height: height * 0.04)
        prescriptionSlider.transform = CGAffineTransform(scaleX: 0.666, y: 0.666)
    }
    
    private func initLabel() {
        currentPrescriptionLabel.textAlignment = .center
        currentPrescriptionLabel.font = UIFont(name: "Avenir-Medium", size: 18)
        currentPrescriptionLabel.textColor = offwhiteColor
        currentPrescriptionLabel.attributedText = stringForPrescription(prescription: self.prescription)
        view.addSubview(currentPrescriptionLabel)
    }
    
    private func updateLabel() {
        let widthScale: CGFloat = 0.6
        currentPrescriptionLabel.frame = CGRect(x: CGFloat((1 - widthScale) / 2) * width, y: height * 0.91, width: width * widthScale, height: height * 0.03)
    }
    
    private func initButtons() {
        nextImageButton.setImage(UIImage(named: "picture")?.tint(with: offwhiteColor), for: .normal)
        nextImageButton.imageView?.contentMode = .scaleAspectFit
        nextImageButton.addTarget(self, action: #selector(nextImage), for: .touchUpInside)
        view.addSubview(nextImageButton)
        
        arButton.setImage(UIImage(named: "camera")?.tint(with: offwhiteColor), for: .normal)
        arButton.imageView?.contentMode = .scaleAspectFit
        arButton.addTarget(self, action: #selector(switchToAR), for: .touchUpInside)
        view.addSubview(arButton)
    }
    
    private func updateButtons() {
        let widthScale: CGFloat = 0.15
        nextImageButton.frame = CGRect(x: (0.125 - widthScale / 2) * width, y: 0.925 * height, width: width * widthScale, height: height * 0.05)
        arButton.frame = CGRect(x: (0.875 - widthScale / 2) * width, y: 0.925 * height, width: width * widthScale, height: height * 0.05)
    }
    
    @objc func switchToAR() {
        if (displayingAR) {
            cameraSession.stopRunning()
            displayImage(image: displayImages[currentImageIndex])
        } else {
            cameraSession = AVCaptureSession()
            
            switch quality {
            case .low: cameraSession.sessionPreset = .low
            case .medium: cameraSession.sessionPreset = .medium
            case .high: cameraSession.sessionPreset = .high
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: self.cameraSession)
            previewLayer.frame = self.imageView.bounds
            setupCameraSession()
            cameraSession.startRunning()
        }
        displayingAR = !displayingAR
    }
    
    @objc func nextImage() {
        if displayingAR { return }
        currentImageIndex = (currentImageIndex + 1) % displayImages.count
        displayImage(image: displayImages[currentImageIndex])
    }
    
    @objc func updatePrescription(sender: UISlider) {
        prescription = Double(sender.value)
        self.currentPrescriptionLabel.attributedText = stringForPrescription(prescription: self.prescription)
        if displayingAR {
            return
        }
        let when = DispatchTime.now() + 0.1
        DispatchQueue.main.asyncAfter(deadline: when) {
            if self.prescription == Double(sender.value) {
                self.displayImage(image: self.displayImages[self.currentImageIndex])
            }
        }
    }
    
    /// This method converts a UIDeviceOrientation to its according AVCaptureVideoOrientation.
    ///
    /// - Parameter orientation: The orientation of the device.
    /// - Returns: The orientation of the output.
    private func outputOrientation(for orientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
        switch orientation {
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }
    
    private func setupCameraSession() {
        guard let captureDevice: AVCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            cameraSession.beginConfiguration()
            
            if (cameraSession.canAddInput(deviceInput) == true) {
                cameraSession.addInput(deviceInput)
            }
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): NSNumber(value: kCVPixelFormatType_32BGRA)]
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            if (cameraSession.canAddOutput(dataOutput) == true) {
                cameraSession.addOutput(dataOutput)
            }
            dataOutput.connections.first?.videoOrientation = outputOrientation(for: UIScreen.main.orientation)
            cameraSession.commitConfiguration()
            
            let queue = DispatchQueue(label: "ac.video", attributes: [])
            dataOutput.setSampleBufferDelegate(self, queue: queue)
            
        } catch let error {
            NSLog("\(error), \(error.localizedDescription)")
        }
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // do stuff here
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciimage = CIImage(cvPixelBuffer: imageBuffer)
        
        let blurRadius = blurForPrescription(self.prescription)
        let affineClampFilter = CIFilter(name: "CIAffineClamp")!
        affineClampFilter.setDefaults()
        affineClampFilter.setValue(ciimage, forKey: kCIInputImageKey)
        let resultClamp = affineClampFilter.value(forKey: kCIOutputImageKey)
        
        // resultClamp is used as input for "CIGaussianBlur" filter
        let filter: CIFilter = CIFilter(name:"CIGaussianBlur")!
        filter.setDefaults()
        filter.setValue(resultClamp, forKey: kCIInputImageKey)
        filter.setValue(blurRadius, forKey: kCIInputRadiusKey)
        
        let ciContext = CIContext(options: nil)
        guard let result = filter.value(forKey: kCIOutputImageKey) as? CIImage else { return }
        guard let cgImage = ciContext.createCGImage(result, from: ciimage.extent, format: CIFormat.RGBAh, colorSpace: nil) else { return }
        
        let image = UIImage(cgImage: cgImage)
        
        DispatchQueue.main.async {
            self.imageView.image = image
        }
    }
}



