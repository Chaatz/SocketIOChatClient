//
//  ChatView.swift
//  Pods
//
//  Created by Kenneth on 2/2/2016.
//
//

import Cartography
import UIKit

public final class LiveChatView: UIView {    
    //MARK: Init
    private weak var socket: SocketIOChatClient?
    private let tableView = LiveChatTableView()
    private lazy var toolbar: LiveChatToolbar = {
        let _toolbar = LiveChatToolbar(socket: self.socket!)
        return _toolbar
    }()

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //MARK: Layout
    public convenience init(socket: SocketIOChatClient) {
        self.init()
        self.socket = socket
        clipsToBounds = true
        backgroundColor = UIColor.clearColor()

        //Add Subviews
        addSubview(tableView)
        constrain(self, tableView) { view, tableView in
            tableView.edges == inset(view.edges, 0)
        }

        //Listen to keyboard change and user tap
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidChangeFrame:", name: UIKeyboardDidChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapGestureHandler")
        tableView.addGestureRecognizer(tapGesture)

        becomeFirstResponder()

        tableView.contentInset = UIEdgeInsets(top: toolbar.bounds.size.height, left: 0, bottom: 0, right: 0)
    }
    
    //MARK: Keyboard
    public override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override public var inputAccessoryView: UIView {
        return toolbar
    }

    func tapGestureHandler() {
        self.becomeFirstResponder()
    }

    func keyboardDidChangeFrame(notification: NSNotification) {
        print("keyboardDidChangeFrame")
    }

    func keyboardWillChangeFrame(notification: NSNotification) {
        if bounds.size.height == 0 { return }
        let endFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()

//        let oldInset = tableView.contentInset.top
        let newInset = bounds.size.height - endFrame.origin.y
//        let newOffset = tableView.contentOffset.y - (newInset - oldInset)
//        tableView.contentOffset = CGPoint(x: 0, y: newOffset)
        tableView.contentInset = UIEdgeInsets(top: newInset, left: 0, bottom: 0, right: 0)
    }
    
    //MARK: Events
    func appendEvent(event: SocketIOEvent) {
        tableView.appendEvent(event)
//        switch event.type {
//        case .Login, .UserJoined, .UserLeft:
//            if let userCount = event.userCount {
//                
//            }
//        default:
//            break
//        }
    }
}