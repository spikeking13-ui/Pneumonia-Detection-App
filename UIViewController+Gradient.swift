import UIKit

extension UIViewController {
    func addGradientBackground(colors: [UIColor]) {
        // Remove old gradient if it exists
        if let sublayers = view.layer.sublayers {
            for layer in sublayers {
                if layer.name == "gradientLayer" {
                    layer.removeFromSuperlayer()
                }
            }
        }

        let gradient = CAGradientLayer()
        gradient.name = "gradientLayer" // so we can remove it later
        gradient.frame = view.bounds
        gradient.colors = colors.map { $0.cgColor }
        gradient.locations = [0.0, 1.0]
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    // Call this in viewDidLayoutSubviews to handle rotation
    func updateGradientFrame() {
        if let sublayers = view.layer.sublayers {
            for layer in sublayers {
                if let gradientLayer = layer as? CAGradientLayer, layer.name == "gradientLayer" {
                    gradientLayer.frame = view.bounds
                }
            }
        }
    }
    
    func styleHeader(_ titleLabel: UILabel?) {
        guard let titleLabel = titleLabel else { return }
        
        // background style
        titleLabel.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        
        // text style
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        titleLabel.textAlignment = .center
        
        // optional rounded edges
        titleLabel.layer.cornerRadius = 12
        titleLabel.layer.masksToBounds = true
    }

}

