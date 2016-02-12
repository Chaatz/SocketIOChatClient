//
//  MessageToolbar.swift
//  Pods
//
//  Created by Kenneth on 1/2/2016.
//
//

import Cartography

protocol LiveChatToolbarDelegate {
    func keyboardDidChangeHeight(height: CGFloat)
}

final class LiveChatToolbar: UIView {
    //MARK: Init
    private weak var socket: SocketIOChatClient?
    private weak var heightConstraint: NSLayoutConstraint?
    private var centerContext = 0
    var delegate: LiveChatToolbarDelegate?

    lazy private var textView: GrowingTextView = {
        let _textView = GrowingTextView()
        _textView.delegate = self
        _textView.growingDelegate = self
        _textView.returnKeyType = .Send
        _textView.font = UIFont.systemFontOfSize(15)
        _textView.placeHolder = "Say something..."
        _textView.placeHolderColor = UIColor(white: 1.0, alpha: 0.5)
        _textView.keyboardDismissMode = .Interactive
        _textView.keyboardAppearance = .Dark
        return _textView
    }()
        
    lazy private var sendButton: UIButton = {
       let _button = UIButton(type: .System)
        _button.setTitle("Send", forState: .Normal)
        _button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        _button.titleLabel?.font = UIFont.systemFontOfSize(15)
        _button.addTarget(self, action: "sendButtonTapped", forControlEvents: .TouchUpInside)
        _button.setContentHuggingPriority(UILayoutPriorityRequired, forAxis: .Horizontal)
        return _button
    }()
    
    lazy private var activityIndicatorView: UIActivityIndicatorView = {
        let _activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .White)
        _activityIndicatorView.hidesWhenStopped = true
        return _activityIndicatorView
    }()
    
    convenience init(socket: SocketIOChatClient) {
        self.init(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: 50))
        self.socket = socket

        backgroundColor = UIColor.clearColor()
        let line = UIView()
        line.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        
        let colorTop = UIColor(white: 0.0, alpha: 0.0).CGColor
        let colorBottom = UIColor(white: 0.0, alpha: 0.6).CGColor
        let locations = [0.0, 1.0]
        let gradientView = GradientView(colors: [colorTop, colorBottom], locations: locations)

        addSubview(gradientView)
        addSubview(line)
        addSubview(textView)
        addSubview(sendButton)
        addSubview(activityIndicatorView)
        
        constrain(self, line, gradientView) { view, line, gradientView in
            gradientView.edges == inset(view.edges, -20, 0, -44, 0)
            line.top == view.top
            line.left == view.left + 10
            line.right == view.right - 10
            line.height == max(0.5, 1.0 / UIScreen.mainScreen().scale)
        }

        constrain(self, sendButton, textView, activityIndicatorView) { view, sendButton, textView, activityIndicatorView in
            sendButton.top == view.top
            sendButton.bottom == view.bottom
            sendButton.right == view.right - 10
            
            textView.left == view.left + 10
            textView.right == sendButton.left - 10
            textView.centerY == view.centerY
            
            activityIndicatorView.center == sendButton.center
        }
    }
    
    //MARK: Layout
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        guard let newSuperview = newSuperview else {
            self.superview?.removeObserver(self, forKeyPath: "center")
            return
        }
        let options = NSKeyValueObservingOptions([.New, .Old])
        newSuperview.addObserver(self, forKeyPath: "center", options: options, context: &centerContext)
    }

    override func addConstraint(constraint: NSLayoutConstraint) {
        if constraint.firstItem === self {
            self.heightConstraint = constraint
        }
        super.addConstraint(constraint)
    }

    //MARK: Send/Receive Message
    func sendButtonTapped() {
        guard let message = textView.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) else { return }
        if message.isEmpty { return }
        if socket?.sendMessage(message) == true{
            textView.text = nil
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &centerContext {
            guard let superViewFrame = superview?.frame else {
                super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
                return
            }
            //Calculate keyboard Height
            let keyboardHeight = UIScreen.mainScreen().bounds.size.height - superViewFrame.origin.y
            
            //Set textview alpha
            if textView.text?.isEmpty != false {
                var textViewAlpha = (keyboardHeight - bounds.size.height)/200
                textViewAlpha = max(min(textViewAlpha, 0.9), 0.2)
                textView.backgroundColor = UIColor(white: 1.0, alpha: textViewAlpha)
            } else {
                textView.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
            }
            
            //Callback
            delegate?.keyboardDidChangeHeight(keyboardHeight)
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    func startLoading() {
        sendButton.hidden = true
        activityIndicatorView.startAnimating()
    }
    
    func stopLoading() {
        activityIndicatorView.stopAnimating()
        sendButton.hidden = false
    }
}

//MARK: UITextViewDelegate (Press Enter, Characters Limit)
extension LiveChatToolbar: UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            sendButtonTapped()
            return false
        }
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        guard let maxMessageLength = socket?.liveChatView.maxMessageLength else { return }
        if textView.text.characters.count > maxMessageLength {
            let endIndex = textView.text.startIndex.advancedBy(maxMessageLength)
            textView.text = textView.text.substringToIndex(endIndex)
            textView.undoManager?.removeAllActions()
        }
    }
}

extension LiveChatToolbar: GrowingTextViewDelegate {
    func growingTextViewDidChangeHeight(height: CGFloat) {
        if let heightConstraint = heightConstraint {
            heightConstraint.constant = height + 16
            UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.CurveLinear], animations: { () -> Void in
                self.superview?.layoutIfNeeded()
                }, completion: nil)
        }
    }
}