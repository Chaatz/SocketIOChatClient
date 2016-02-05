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

    lazy private var textView: GrowingTextView = {
        let _textView = GrowingTextView()
        _textView.delegate = self
        _textView.returnKeyType = .Send
        _textView.font = UIFont.systemFontOfSize(15)
        _textView.activeBackgroundColor = UIColor(white: 1.0, alpha: 0.9)
        _textView.deactiveBackgroundColor = UIColor(white: 1.0, alpha: 0.2)
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
    
    //MARK: Layout
    convenience init(socket: SocketIOChatClient) {
        self.init()
        self.socket = socket

        backgroundColor = UIColor.clearColor()
        let line = UIView()
        line.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        
        addSubview(line)
        addSubview(textView)
        addSubview(sendButton)
        
        constrain(self, sendButton, textView, line) { view, sendButton, textField, line in
            line.top == view.top
            line.left == view.left + 10
            line.right == view.right - 10
            line.height == max(0.5, 1.0 / UIScreen.mainScreen().scale)

            sendButton.top == view.top
            sendButton.bottom == view.bottom
            sendButton.right == view.right - 10
            
            textField.left == view.left + 10
            textField.right == sendButton.left - 10
            textField.top == view.top + 8
            textField.bottom == view.bottom - 8
        }
    }
    
    //MARK: Send/Receive Message
    func sendButtonTapped() {
        guard let message = textView.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) else { return }
        if message.isEmpty { return }
        if socket?.sendMessage(message) == true{
            textView.text = nil
//        } else {
//            let alertController = UIAlertController(title: "Network problem", message: "Please try again", preferredStyle: .Alert)
//            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
//            presentViewController(alertController, animated: true, completion: nil)
        }
//        endEditing(true)
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
        if textView.text.characters.count > 140 {
            let endIndex = textView.text.startIndex.advancedBy(140)
            textView.text = textView.text.substringToIndex(endIndex)
            textView.undoManager?.removeAllActions()
        }
    }
}