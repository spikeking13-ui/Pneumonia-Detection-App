import UIKit
import CoreML
import Vision
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Outlets
    
    @IBOutlet weak var headerLabel: UILabel!   // Connect this in your storyboard
    @IBOutlet weak var imageView: UIImageView!
//    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var seeResultsButton: UIButton!
    @IBAction func seeResultsButtonTapped(_ sender: UIButton) {
        guard let image = imageView.image else {
                return
            }

            // Make sure predictions exist
            guard let predictedClass = predictedClassForResults,
                  let confidence = confidenceForResults else {
                return
            }

            // Resize for display
            let resizedForDisplay = resizeForDisplay(image)

            // Access Results tab
            guard let tabBarController = self.tabBarController,
                  let resultsVC = tabBarController.viewControllers?[1] as? ResultsViewController else {
                return
            }

            // Pass latest results
            resultsVC.passedImage = resizedForDisplay
            resultsVC.passedClass = predictedClass
            resultsVC.passedConfidence = String(format: "%.2f", confidence)


            // FADE TRANSITION
            let transition = CATransition()
            transition.type = .fade
            transition.duration = 0.3
            tabBarController.view.layer.add(transition, forKey: nil)

            // Switch to Results tab
            tabBarController.selectedIndex = 1
        }




    // Helper function to resize for display
    func resizeForDisplay(_ image: UIImage, maxSize: CGFloat = 300) -> UIImage {
        let aspectRatio = image.size.width / image.size.height
        var newSize: CGSize
        if aspectRatio > 1 {
            newSize = CGSize(width: maxSize, height: maxSize / aspectRatio)
        } else {
            newSize = CGSize(width: maxSize * aspectRatio, height: maxSize)
        }
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }




    
    // MARK: - Variables to pass results
    
    var selectedImageForResults: UIImage?
    var predictedClassForResults: String?
    var confidenceForResults: Float?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addGradientBackground()
        
        
        seeResultsButton.isEnabled = false   // Button cannot be tapped
        seeResultsButton.alpha = 0.5         // Make it look greyed out

        
        // If you have a navigation bar, it's typically just below the notch.
        // But here, we're adding our own “header” label in addition or instead.
        
        styleUI()
        layoutHeaderAndImageView()
        
        // For the Take Photo button
        takePhotoButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        takePhotoButton.addTarget(self, action: #selector(buttonReleased(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        takePhotoButton.titleLabel?.numberOfLines = 1
        takePhotoButton.titleLabel?.lineBreakMode = .byTruncatingTail
        takePhotoButton.titleLabel?.adjustsFontSizeToFitWidth = true
        takePhotoButton.titleLabel?.minimumScaleFactor = 0.7



        
        print("App loaded successfully.")
    }
    
    // MARK: - UI Styling
    
    private func styleUI() {
        // MARK: - Screen gradient
        addGradientBackground()
        
        // MARK: - Header
        headerLabel.backgroundColor = UIColor.white.withAlphaComponent(0.15) // transparent white
        headerLabel.textColor = .white
        headerLabel.font = UIFont.boldSystemFont(ofSize: 22)
        headerLabel.textAlignment = .center
        headerLabel.text = "Pneumonia Detection"
        headerLabel.layer.cornerRadius = 12
        headerLabel.layer.masksToBounds = true
        
        // MARK: - Image View
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        
        // MARK: - Buttons styling
        func styleButton(_ button: UIButton, color: UIColor) {
            button.backgroundColor = color
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 12
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 3)
            button.layer.shadowOpacity = 0.25
            button.layer.shadowRadius = 4
            button.layer.masksToBounds = false
            
            // Keep text on one line
            button.titleLabel?.lineBreakMode = .byClipping
            button.titleLabel?.numberOfLines = 1
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.7
        }
        
        styleButton(chooseImageButton, color: .systemBlue)
        styleButton(takePhotoButton, color: .systemTeal)
        styleButton(seeResultsButton, color: .systemPurple) // highlight or accent color
        
        // Initially disable the "See Results" button
        seeResultsButton.isEnabled = false
        seeResultsButton.alpha = 0.5
        seeResultsButton.setTitle("Processing...", for: .normal)
    }
    
    // Animate shrinking when pressed
    @objc private func buttonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        })
    }

    // Animate back to normal when released
    @objc private func buttonReleased(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = .identity
        })
    }

    
    /// Keep the gradient filling the entire screen on rotation
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let sublayers = view.layer.sublayers, !sublayers.isEmpty {
            if let gradientLayer = sublayers[0] as? CAGradientLayer {
                gradientLayer.frame = view.bounds
            }
        }
    }
    private func addGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemBlue.cgColor,
            UIColor.systemTeal.cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        // Actual frame set in viewDidLayoutSubviews()
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // MARK: - Layout Constraints
    
    private func layoutHeaderAndImageView() {
        // Disable autoresizing constraints
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Pin the header label to the safe area top to avoid the notch
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerLabel.heightAnchor.constraint(equalToConstant: 60),
            // Place the imageView below the header label
            imageView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ])
    }
    
    // MARK: - Button Actions
    
    @IBAction func chooseImage(_ sender: UIButton) {
        print("Choose Image button tapped.")
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func takePhotoButtonTapped(_ sender: UIButton) {
        print("Take Photo button tapped.")
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera not available on this device.")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }

    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        // Reset previous results before new prediction
        predictedClassForResults = nil
        confidenceForResults = nil
        seeResultsButton.isEnabled = false
        seeResultsButton.alpha = 0.5
        seeResultsButton.setTitle("Processing...", for: .normal)
        print("Image selected from camera or library.")
        
        if let selectedImage = info[.originalImage] as? UIImage {
            // Display full image
            imageView.image = selectedImage
            print("Original image size: \(selectedImage.size)")
            
            // Resize for model input
            if let resizedImage = resizeImage(image: selectedImage, targetSize: CGSize(width: 64, height: 64)) {
                print("Image resized to: \(resizedImage.size)")
                classifyImage(resizedImage)
            } else {
                print("Image resizing failed.")
            }
        } else {
            print("Failed to retrieve the selected image.")
        }
    }


    // MARK: - Classification Logic
    func classifyImage(_ image: UIImage) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let model = try model_neuralnetwork(configuration: MLModelConfiguration())
                
                guard let multiArrayInput = image.toMLMultiArray() else {
                    print("Failed to create MLMultiArray.")
                    return
                }
                
                let input = model_neuralnetworkInput(conv2d_8_input: multiArrayInput)
                let prediction = try model.prediction(input: input)
                
                let multiArrayOutput = prediction.Identity
                let values = multiArrayOutput.toArray()
                let classLabels = ["Healthy", "Pneumonia"]
                
                guard values.count == classLabels.count else {
                    print("Invalid model output.")
                    return
                }
                
                if let maxIndex = values.indices.max(by: { values[$0] < values[$1] }) {
                    let predictedClass = classLabels[maxIndex]
                    let confidence = values[maxIndex]
                    
                    DispatchQueue.main.async {
                        self.selectedImageForResults = image
                        self.predictedClassForResults = predictedClass
                        self.confidenceForResults = Float(confidence)

                        // ✅ Re-enable button and restore text
                        self.seeResultsButton.isEnabled = true
                        self.seeResultsButton.alpha = 1.0
                        self.seeResultsButton.setTitle("See Results", for: .normal)

                        print("✅ Prediction ready: \(predictedClass) (\(confidence))")
                    }
                }
                
            } catch {
                print("Error during model prediction: \(error)")
            }
        }
    }


    
    // MARK: - Image Resizing
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        print("Resized image created.")
        return convertToRGB(resizedImage)
    }
    
    func convertToRGB(_ image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContext(image.size)
        defer { UIGraphicsEndImageContext() }
        image.draw(at: .zero)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
// MARK: - UIImage Extension for MLMultiArray
extension UIImage {
    func toMLMultiArray() -> MLMultiArray? {
        guard let pixelBuffer = self.toCVPixelBuffer() else {
            print("Failed to create CVPixelBuffer.")
            return nil
        }
        
        // The shape is (1, 64, 64, 3) based on your model
        let shape = [1, 64, 64, 3] as [NSNumber]
        guard let multiArray = try? MLMultiArray(shape: shape, dataType: .float32) else {
            print("Failed to create MLMultiArray.")
            return nil
        }
        
        // Fill the MLMultiArray with normalized pixel data
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }
        
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            print("Failed to get CVPixelBuffer base address.")
            return nil
        }
        
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let channelCount = 3
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = y * bytesPerRow + x * channelCount
                let red   = Float(baseAddress.load(fromByteOffset: pixelIndex,     as: UInt8.self)) / 255.0
                let green = Float(baseAddress.load(fromByteOffset: pixelIndex + 1, as: UInt8.self)) / 255.0
                let blue  = Float(baseAddress.load(fromByteOffset: pixelIndex + 2, as: UInt8.self)) / 255.0
                
                let arrayIndex = (y * width + x) * channelCount
                multiArray[arrayIndex + 0] = NSNumber(value: red)
                multiArray[arrayIndex + 1] = NSNumber(value: green)
                multiArray[arrayIndex + 2] = NSNumber(value: blue)
            }
        }
        
        return multiArray
    }
    
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let attributes: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ]
        var pixelBuffer: CVPixelBuffer?
        let width = Int(size.width)
        let height = Int(size.height)
        let options = attributes as CFDictionary
        
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            options,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        ) else {
            CVPixelBufferUnlockBaseAddress(buffer, [])
            return nil
        }
        
        UIGraphicsPushContext(context)
        draw(in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return buffer
    }
}
// MARK: - MLMultiArray Extension
extension MLMultiArray {
    func toArray() -> [Double] {
        var array: [Double] = []
        for i in 0..<count {
            array.append(self[i].doubleValue)
        }
        return array
    }
}

