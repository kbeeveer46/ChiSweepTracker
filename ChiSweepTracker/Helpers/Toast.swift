// MIT License
//
// Copyright (c) 2018 Gallagher Group Ltd
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import UIKit

public class Toast {
	
	// Creates a toast message as a subview of the application's key window
	
	func toast(_ message:String) {
		guard let window = UIApplication.shared.keyWindow else {
			return
		}
		window.toast(message)
	}
}

fileprivate class ToastLabel : UILabel { }

extension UIView {
	
	func toast(_ message:String) {
		
		let duration = 2.0
		
		let lbl = ToastLabel()
		lbl.textColor = UIColor.white
		lbl.backgroundColor = UIColor(hexString: "#BF1A2F") //UIColor(hexString: "#D81B60")
		lbl.text = message
		lbl.textAlignment = .center
		lbl.translatesAutoresizingMaskIntoConstraints = false
		lbl.alpha = 0
		lbl.numberOfLines = 0
		//lbl.padding = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)
		lbl.font = UIFont.preferredFont(forTextStyle: .body)
		lbl.clipsToBounds = true
		lbl.layer.cornerRadius = 6
		
		// Remove any existing toasts
		for subView in subviews {
			if let existingToast = subView as? ToastLabel {
				existingToast.removeFromSuperview()
			}
		}
		
		// Add view and constraints
		addSubview(lbl)
		addConstraints([
			NSLayoutConstraint(item: self, attribute: .leadingMargin, relatedBy: .equal, toItem: lbl, attribute: .leading, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: self, attribute: .trailingMargin, relatedBy: .equal, toItem: lbl, attribute: .trailing, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: self, attribute: .bottomMargin, relatedBy: .equal, toItem: lbl, attribute: .bottom, multiplier: 1, constant: 0),
		])
		
		// Add animations
		UIView.animate(withDuration: 0.1, animations: { lbl.alpha = 0.9 }, completion: { f in
			UIView.animate(withDuration: 1.2, delay: duration, options:.curveEaseOut, animations: { lbl.alpha = 0 }, completion: { f in
				lbl.removeFromSuperview() }) })
	}
}

// Extension for adding padding to toasts
//extension UILabel {
//
//	private struct AssociatedKeys {
//		static var padding = UIEdgeInsets()
//	}
//
//	public var padding: UIEdgeInsets? {
//		get {
//			return objc_getAssociatedObject(self, &AssociatedKeys.padding) as? UIEdgeInsets
//		}
//		set {
//			if let newValue = newValue {
//				objc_setAssociatedObject(self, &AssociatedKeys.padding, newValue as UIEdgeInsets?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//			}
//		}
//	}
//
//	override open func draw(_ rect: CGRect) {
//		if let insets = padding {
//			self.drawText(in: rect.inset(by: insets))
//		} else {
//			self.drawText(in: rect)
//		}
//	}
//
//	override open var intrinsicContentSize: CGSize {
//
//		guard let text = self.text else { return super.intrinsicContentSize }
//
//		var contentSize = super.intrinsicContentSize
//		var textWidth: CGFloat = frame.size.width
//		var insetsHeight: CGFloat = 0.0
//		var insetsWidth: CGFloat = 0.0
//
//		if let insets = padding {
//			insetsWidth += insets.left + insets.right
//			insetsHeight += insets.top + insets.bottom
//			textWidth -= insetsWidth
//		}
//
//		let newSize = text.boundingRect(with: CGSize(width: textWidth, height: CGFloat.greatestFiniteMagnitude),
//										options: NSStringDrawingOptions.usesLineFragmentOrigin,
//										attributes: [NSAttributedString.Key.font: self.font!], context: nil)
//
//		contentSize.height = ceil(newSize.size.height) + insetsHeight
//		contentSize.width = ceil(newSize.size.width) + insetsWidth
//
//		return contentSize
//	}
//}
