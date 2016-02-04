//
//  GrowingTextView.swift
//  Pods
//
//  Created by Kenneth on 4/2/2016.
//
//

import UIKit
import Cartography

class GrowingTextView: UITextView {
    private weak var heightConstraint: NSLayoutConstraint?
//    var placeHolder: UILabel = UILabel()
    let activeBackgroundColor = UIColor(white: 1.0, alpha: 0.9)
    let deactiveBackgroundColor = UIColor(white: 1.0, alpha: 0.2)
    var shouldShowPlaceHolder = true
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        layer.cornerRadius = 4.0
        backgroundColor = deactiveBackgroundColor
//        addSubview(placeHolder)
//        constrain(self, placeHolder) { view, placeHolder in
//            placeHolder.left == view.left + 4
//            placeHolder.center == view.center
//        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = sizeThatFits(CGSizeMake(bounds.size.width, CGFloat.max))
        
        if (heightConstraint == nil) {
            heightConstraint = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: size.height)
            addConstraint(heightConstraint!)
        }
        
        if size.height != heightConstraint?.constant {
            heightConstraint!.constant = size.height;
            NSNotificationCenter.defaultCenter().postNotificationName("SocketIOChatClient_GrowingTextViewDidChangeSize", object: nil)
            scrollRangeToVisible(NSMakeRange(0, 0))
        }
    }
    
    override func becomeFirstResponder() -> Bool {
//        placeHolder.hidden = true
        showPlaceHolder(false)
        UIView.animateWithDuration(0.25) { () -> Void in
            self.backgroundColor = self.activeBackgroundColor
        }
        return super.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        text = text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if text?.isEmpty != false {
            UIView.animateWithDuration(0.25) { () -> Void in
                self.backgroundColor = self.deactiveBackgroundColor
            }
//            placeHolder.hidden = false
            showPlaceHolder(true)
        }
        return super.resignFirstResponder()
    }
    
    private func showPlaceHolder(show: Bool) {
        shouldShowPlaceHolder = show
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        if shouldShowPlaceHolder {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = textAlignment
            
            let rect = CGRectMake(textContainerInset.left + 5,
                textContainerInset.top,
                self.frame.size.width - textContainerInset.left - textContainerInset.right,
                self.frame.size.height)
            
            NSString(string: "Say something...").drawInRect(rect, withAttributes: [
                NSFontAttributeName: UIFont.systemFontOfSize(15),
                NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 0.5),
                NSParagraphStyleAttributeName: paragraphStyle
                ])
        }
        
    }
}

//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    
//    if (self.shouldDisplayPlaceholder && self.placeholder && self.placeholderColor) {
//        
//        UIEdgeInsets inset = self.contentInset;
//        
//        if ([self respondsToSelector:@selector(textContainerInset)]) {
//            inset = self.textContainerInset;
//        }
//        
//        if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)]) {
//            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//            paragraphStyle.alignment = self.textAlignment;
//            [self.placeholder drawInRect:CGRectMake(inset.left + 5,
//            inset.top,
//            self.frame.size.width - inset.left - inset.right,
//            self.frame.size.height)
//            withAttributes:@{NSFontAttributeName:self.font,
//            NSForegroundColorAttributeName:self.placeholderColor,
//            NSParagraphStyleAttributeName:paragraphStyle}];
//        }
//        else {
//            // iOS 6
//            /*
//            [self.placeholderColor set];
//            [self.placeholder drawInRect:CGRectMake(8.0f,
//            8.0f,
//            self.frame.size.width - 16.0f,
//            self.frame.size.height)
//            withFont:self.font];
//            */
//        }
//    }
//}
