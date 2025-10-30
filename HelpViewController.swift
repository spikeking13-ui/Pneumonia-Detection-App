import UIKit

class HelpViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    

    @IBAction func backTapped(_ sender: UIButton) {
        print("Back tapped!")
        self.tabBarController?.selectedIndex = 0
    }
    @IBOutlet weak var helpSteps: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleUI()
        
        populateSteps()
        
        styleButton(backButton, color: .systemPurple)
        
        // Animate backButton on press
        backButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        backButton.addTarget(self, action: #selector(buttonReleased(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])

    }
    
    // MARK: - UI Styling
    private func styleUI() {
        
        // Gradient Background
        addGradientBackground(colors: [UIColor.systemBlue, UIColor.systemTeal])
        
        // Header
        headerLabel.text = "Help / Instructions"
        headerLabel.textColor = .white
        headerLabel.font = UIFont.boldSystemFont(ofSize: 22)
        headerLabel.textAlignment = .center
        headerLabel.layer.cornerRadius = 12
        headerLabel.layer.masksToBounds = true
        headerLabel.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        
        // Help Steps
        helpSteps.numberOfLines = 0         // allow unlimited lines
        helpSteps.lineBreakMode = .byWordWrapping
        helpSteps.textAlignment = .left     // easier to read for steps
        helpSteps.adjustsFontSizeToFitWidth = false // don’t shrink text
        
        

        
    }
    
    // MARK: - Button styling
        func styleButton(_ button: UIButton, color: UIColor) {
            button.backgroundColor = color
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 12
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 3)
            button.layer.shadowOpacity = 0.25
            button.layer.shadowRadius = 4
            button.layer.masksToBounds = false

            // keep text on one line
            button.titleLabel?.lineBreakMode = .byClipping
            button.titleLabel?.numberOfLines = 1
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.7
        }
    
    
    
    // Animate shrinking when pressed
    @objc private func buttonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    // Animate back to normal when released
    @objc private func buttonReleased(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
        }
    }


    
    // MARK: - Populate Step Texts
    private func populateSteps() {
    helpSteps.text = """
        1. Take a clear X-ray photo using the camera.
        
        2. Tap 'See Results' to get prediction and confidence.
        
        3. Share results with your doctor if needed.
        """
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradientFrame()
    }
    
}
