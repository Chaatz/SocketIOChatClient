//
//  MessageToolbar.swift
//  Pods
//
//  Created by Kenneth on 1/2/2016.
//
//

import SnapKit

final class LiveChatToolbar: UIView {
    //MARK: Init
    weak private var socket: SocketIOChatClient?

    lazy var textField: TransparentTextField = {
        let _textField = TransparentTextField()
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
        
        line.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(0)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(max(0.5, 1.0 / UIScreen.mainScreen().scale))
        }
        
        sendButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(0)
            make.bottom.equalTo(0)
            make.right.equalTo(-10)
        }
        
        textField.snp_makeConstraints { [unowned self] (make) -> Void in
            make.left.equalTo(10)
            make.right.equalTo(self.sendButton.snp_left).offset(-10)
            make.top.equalTo(8)
            make.bottom.equalTo(-8)
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
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initTextField()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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