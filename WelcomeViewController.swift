import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var bodyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleUI()
    }

    private func styleUI() {
        // MARK: - Gradient background
        addGradientBackground(colors: [UIColor.systemBlue, UIColor.systemTeal])
        
        // MARK: - Body Text
        bodyLabel.textColor = .white   // pops against mint-to-white gradient
        bodyLabel.font = UIFont.systemFont(ofSize: 18)
        bodyLabel.textAlignment = .left

        // MARK: - Header
        headerLabel.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        headerLabel.textColor = .white
        headerLabel.font = UIFont.boldSystemFont(ofSize: 24)
        headerLabel.textAlignment = .center
        headerLabel.text = "PneumoDetector"
        headerLabel.layer.cornerRadius = 12
        headerLabel.layer.masksToBounds = true

        // MARK: - Button styling
        styleButton(getStartedButton, color: .systemPurple)
    }

    private func styleButton(_ button: UIButton, color: UIColor) {
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradientFrame()
    }

    @IBAction func getStartedTapped(_ sender: UIButton) {
        guard let tabBarController = storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") else {
            print("MainTabBarController not found")
            return
        }

        tabBarController.modalPresentationStyle = .fullScreen
        tabBarController.modalTransitionStyle = .crossDissolve

        present(tabBarController, animated: true)
    }
}




