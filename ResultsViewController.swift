import UIKit

class ResultsViewController: UIViewController {
    
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var treatmentPlanLabel: UILabel!
    @IBOutlet weak var resultsContainerView: UIView!
    @IBOutlet weak var sendResultsButton: UIButton!
    
    var passedImage: UIImage?
    var passedClass: String?
    var passedConfidence: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Apply gradient to entire view
        addGradientBackground(colors: [UIColor.systemBlue, UIColor.systemTeal])
        
        // Make sure container is transparent so gradient shows through
        resultsContainerView.backgroundColor = .clear
        
        styleUI()
        
        sendResultsButton.setTitleColor(.white, for: .normal)
        sendResultsButton.setTitleColor(.white, for: .highlighted)
        sendResultsButton.setTitleColor(.white, for: .disabled)
        sendResultsButton.setTitleColor(.white, for: .selected)

        // Also reset tintColor
        sendResultsButton.tintColor = .white
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateResults() // ✅ refresh results every time tab appears
    }
        
        private func styleUI() {
        
            // MARK: - Header
            headerLabel.backgroundColor = UIColor.white.withAlphaComponent(0.15)
            headerLabel.textColor = .white
            headerLabel.font = UIFont.boldSystemFont(ofSize: 22)
            headerLabel.textAlignment = .center
            headerLabel.layer.cornerRadius = 12
            headerLabel.layer.masksToBounds = true
            headerLabel.text = "Prediction Results"
        
            // MARK: - Image View
            resultImageView.contentMode = .scaleAspectFit
            resultImageView.layer.cornerRadius = 12
            resultImageView.layer.masksToBounds = true
            resultImageView.layer.borderWidth = 0
            resultImageView.layer.borderColor = nil
        
            // MARK: - Labels inside container
           
        
            let labels = [classLabel, confidenceLabel, treatmentPlanLabel]
            for label in labels {
                label?.textColor = .white
                label?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
                label?.textAlignment = .center
                label?.numberOfLines = 0
                
                // Remove individual backgrounds
                label?.backgroundColor = .clear
                label?.layer.cornerRadius = 0
                label?.layer.masksToBounds = false
            }
        
            // MARK: - Share Results Button
            styleSendResultsButton()
        }

    private func styleSendResultsButton() {
        sendResultsButton.backgroundColor = .systemPurple
        sendResultsButton.layer.cornerRadius = 12
        sendResultsButton.layer.shadowColor = UIColor.black.cgColor
        sendResultsButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        sendResultsButton.layer.shadowOpacity = 0.25
        sendResultsButton.layer.shadowRadius = 4
        sendResultsButton.layer.masksToBounds = false
        
        sendResultsButton.titleLabel?.lineBreakMode = .byClipping
        sendResultsButton.titleLabel?.numberOfLines = 1
        sendResultsButton.titleLabel?.adjustsFontSizeToFitWidth = true
        sendResultsButton.titleLabel?.minimumScaleFactor = 0.7
        
        // ✅ Force white title AFTER styling
        DispatchQueue.main.async {
            self.sendResultsButton.setTitleColor(.white, for: .normal)
            self.sendResultsButton.setTitleColor(.white, for: .highlighted)
            self.sendResultsButton.setTitleColor(.white, for: .disabled)
            self.sendResultsButton.setTitleColor(.white, for: .selected)
        }
    }
    
        private func populateResults() {
            DispatchQueue.main.async {
                self.resultImageView.image = self.passedImage
                self.classLabel.text = "Prediction: \(self.passedClass ?? "N/A")"
                
                // Format confidence
                if let confidenceString = self.passedConfidence,
                   let confidenceValue = Float(confidenceString) {
                    let confidencePercent = confidenceValue * 100
                    self.confidenceLabel.text = String(format: "Confidence: %.2f%%", confidencePercent)
                } else {
                    self.confidenceLabel.text = "Confidence: N/A"
                }
                
                // Treatment plan based on prediction
                if let predictedClass = self.passedClass {
                    switch predictedClass {
                    case "Healthy":
                        self.treatmentPlanLabel.text = "No signs of pneumonia detected. Maintain regular checkups."
                    case "Pneumonia":
                        self.treatmentPlanLabel.text = "Possible pneumonia detected. Consult a healthcare provider promptly."
                    default:
                        self.treatmentPlanLabel.text = "Prediction unavailable. Please try again."
                    }
                }
            }
        }
    
    @IBAction func sendResultsButtonTapped(_ sender: UIButton) {
    // Capture entire screen (self.view)
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: view.bounds.size, format: format)
        let fullScreenshot = renderer.image { ctx in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }

        // Present share sheet
        let activityVC = UIActivityViewController(activityItems: [fullScreenshot], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = sender
        present(activityVC, animated: true)
    }


    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
