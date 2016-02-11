//
//  GrowingTextView.swift
//  Pods
//
//  Created by Kenneth on 4/2/2016.
//
//

import UIKit
import Cartography

protocol GrowingTextViewDelegate: class {
    func growingTextViewDidChangeHeight(height: CGFloat)
}

class GrowingTextView: UITextView {
    private weak var heightConstraint: NSLayoutConstraint?
    weak var growingDelegate: GrowingTextViewDelegate?

    //MARK: Customizable properties
    var activeBackgroundColor: UIColor? {
        didSet {
            if isFirstResponder() {
                backgroundColor = activeBackgroundColor
            }
        }
    }
    var deactiveBackgroundColor: UIColor? {
        didSet {
            if !isFirstResponder() {
                backgroundColor = deactiveBackgroundColor
            }
        }
    }
    var placeHolder: NSString? {
        didSet {
            setNeedsDisplay()
        }
    }
    var placeHolderColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    //MARK: Override functions
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        layer.cornerRadius = 4.0
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
        let size = sizeThatFits(CGSizeMake(bounds.size.width, CGFloat.max))
        
        if (heightConstraint == nil) {
            heightConstraint = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: size.height)
            addConstraint(heightConstraint!)
        }
        
        if size.height != heightConstraint?.constant {
            heightConstraint!.constant = size.height;
            growingDelegate?.growingTextViewDidChangeHeight(size.height)
            scrollRangeToVisible(NSMakeRange(0, 0))
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        setNeedsDisplay()
        if let color = activeBackgroundColor {
//            UIView.animateWithDuration(2.5) { () -> Void in
                self.backgroundColor = color
//            }
        }
        return super.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        text = text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if text?.isEmpty != false {
            setNeedsDisplay()
            if let color = deactiveBackgroundColor {
//                UIView.animateWithDuration(2.5) { () -> Void in
                    self.backgroundColor = color
//                }
            }
        }
        return super.resignFirstResponder()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        guard let placeHolder = placeHolder else { return }
        guard let placeHolderColor = placeHolderColor else { return }
        if !isFirstResponder() && text?.isEmpty != false {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = textAlignment
            
            let rect = CGRectMake(textContainerInset.left + 5,
                textContainerInset.top,
                self.frame.size.width - textContainerInset.left - textContainerInset.right,
                self.frame.size.height)
            
            let attributes = [
                NSFontAttributeName: font!,
                NSForegroundColorAttributeName: placeHolderColor,
                NSParagraphStyleAttributeName: paragraphStyle
            ]
            placeHolder.drawInRect(rect, withAttributes: attributes)
        }
    }
}