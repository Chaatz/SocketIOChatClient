//
//  MessageToolbar.swift
//  Pods
//
//  Created by Kenneth on 1/2/2016.
//
//

import Cartography

final class LiveChatToolbar: UIView {
    //MARK: Init
    weak private var socket: SocketIOChatClient?

    lazy var textField: TransparentTextField = {
        let _textField = TransparentTextField(maxLength: (self.socket?.maxMessageLength)!)
        _textField.delegate = self
        _textField.font = UIFont.systemFontOfSize(15)
        _textField.returnKeyType = .Send
        return _textField
    }()
    
    lazy var sendButton: UIButton = {
       let _button = UIButton(type: .System)
        _button.setTitle("Send", forState: .Normal)
        _button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        _button.titleLabel?.font = UIFont.systemFontOfSize(15)
        _button.addTarget(self, action: "sendButtonTapped", forControlEvents: .TouchUpInside)
        _button.setContentHuggingPriority(UILayoutPriorityRequired, forAxis: .Horizontal)
        return _button
    }()
    
    //MARK: Layout
    convenience init(socket: SocketIOChatClient) {
        self.init()
        self.socket = socket

        backgroundColor = UIColor.clearColor()
        let line = UIView()
        line.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        
        addSubview(line)
        addSubview(textField)
        addSubview(sendButton)
        
        constrain(self, line) { view, line in
            line.top == view.top
            line.left == view.left + 10
            line.right == view.right - 10
            line.height == max(0.5, 1.0 / UIScreen.mainScreen().scale)
        }
        
        constrain(self, sendButton, textField) { view, sendButton, textField in
            sendButton.top == view.top
            sendButton.bottom == view.bottom
            sendButton.right == view.right - 10
            
            textField.left == view.left + 10
            textField.right == sendButton.left - 10
            textField.top == view.top + 8
            textField.bottom == view.bottom - 8
        }
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 50.0)
    }

    //MARK: Send/Receive Message
    func sendButtonTapped() {
        guard let message = textField.text else { return }
        if message.isEmpty { return }
        if socket?.sendMessage(message) == true{
            textField.text = nil
//        } else {
//            let alertController = UIAlertController(title: "Network problem", message: "Please try again", preferredStyle: .Alert)
//            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
//            presentViewController(alertController, animated: true, completion: nil)
        }
    }
}

//MARK: UITextFieldDelegate
extension LiveChatToolbar: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        guard let _ = textField.text else { return false }
        sendButtonTapped()
        return true
    }
}

//MARK: TransparentTextField
final class TransparentTextField: UITextField {
    
    var maxLength = 140
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        initTextField()
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        initTextField()
//    }
    
    convenience init(maxLength: Int) {
        self.init()
        self.maxLength = maxLength
        initTextField()
    }
    
    func initTextField() {
        borderStyle = .RoundedRect
        backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        showPlaceholder(true)
    }

    override func becomeFirstResponder() -> Bool {
        showPlaceholder(false)
        UIView.animateWithDuration(0.25) { () -> Void in
            self.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        }
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        showPlaceholder(true)
        if text?.isEmpty != false {
            UIView.animateWithDuration(0.25) { () -> Void in
                self.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
            }
        }
        return super.resignFirstResponder()
    }
    
    private func showPlaceholder(show: Bool) {
        if show {
            attributedPlaceholder = NSAttributedString(string: "Say something...", attributes: [NSForegroundColorAttributeName:UIColor(white: 1.0, alpha: 0.5)])
        } else {
            placeholder = nil
        }
    }
}