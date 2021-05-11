import UIKit

// Class that draws a circle around sweep days on the calendar view

class DateCollectionViewCell: UICollectionViewCell {
    
	// MARK: Controls
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var Circle: UIView!
    
    // MARK: Methods
    
    func DrawCircle() {
        
		// Create circle center
        let circleCenter = Circle.center
        
		// Create circle path
        let circlePath = UIBezierPath(arcCenter: circleCenter, radius: (Circle.bounds.width/2 - 5), startAngle: -CGFloat.pi/2, endAngle: (2 * CGFloat.pi), clockwise: true)
        
		// Create circle layer
        let CircleLayer = CAShapeLayer()
		
		// Set layer properties
        CircleLayer.path = circlePath.cgPath
        CircleLayer.strokeColor = UIColor.systemBlue.cgColor
        CircleLayer.lineWidth = 2
        CircleLayer.strokeEnd = 0
        CircleLayer.fillColor = UIColor.clear.cgColor
        CircleLayer.lineCap = CAShapeLayerLineCap.round
        
		// Create circle animation
        let Animation = CABasicAnimation(keyPath: "strokeEnd")
		
		// Set animation properties
        Animation.duration = 1.5
        Animation.toValue = 1
        Animation.fillMode = CAMediaTimingFillMode.forwards
        Animation.isRemovedOnCompletion = false
        
		// Add animation to layer
        CircleLayer.add(Animation, forKey: nil)
		
		// Add layer to circle object and add background color
        Circle.layer.addSublayer(CircleLayer)
        Circle.layer.backgroundColor = UIColor.clear.cgColor
        
    }
}
