//
//  ChatView.swift
//  Pods
//
//  Created by Kenneth on 2/2/2016.
//
//

import Cartography

public final class LiveChatView: UIView {    
    //MARK: Init
    private weak var socket: SocketIOChatClient?
    private weak var toolbarBottomConstraint: NSLayoutConstraint?
    private let tableView = LiveChatTableView()
    private lazy var toolbar: LiveChatToolbar = {
        return LiveChatToolbar(socket: self.socket!)
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

        let colorTop = UIColor(white: 0.0, alpha: 0.0).CGColor
        let colorBottom = UIColor(white: 0.0, alpha: 0.6).CGColor
        let locations = [0.0, 1.0]
        let gradientView = GradientView(colors: [colorTop, colorBottom], locations: locations)
        
        //Add Subviews
        addSubview(gradientView)
        addSubview(tableView)
        addSubview(toolbar)
        
        constrain(self, tableView, toolbar, gradientView) { view, tableView, toolbar, gradientView in
            tableView.top == view.top
            tableView.left == view.left
            tableView.right == view.right
            tableView.bottom == toolbar.top
            
            toolbar.left == view.left
            toolbar.right == view.right
            toolbarBottomConstraint = (toolbar.bottom == view.bottom)
            
            gradientView.left == view.left
            gradientView.right == view.right
            gradientView.height == toolbar.height + 88
            gradientView.bottom == toolbar.bottom + 44
        }
        
        //Listen to keyboard change and user tap
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapGestureHandler")
        tableView.addGestureRecognizer(tapGesture)
        
        //Listen to textfield size change
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "growingTextViewDidChangeSize:", name:"SocketIOChatClient_GrowingTextViewDidChangeSize", object: nil)
    }
    
    //MARK: Show and Hide Keyboard
    func keyboardWillChangeFrame(notification: NSNotification) {
        let endFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        toolbarBottomConstraint?.constant = -(CGRectGetHeight(self.bounds) - endFrame.origin.y)
        UIView.animateWithDuration(0.25) {
            self.layoutIfNeeded()
        }
    }
    
    func tapGestureHandler() {
        endEditing(true)
    }

    func growingTextViewDidChangeSize(notification: NSNotification) {
        UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.CurveLinear], animations: { () -> Void in
            self.layoutIfNeeded()
            }, completion: nil)
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