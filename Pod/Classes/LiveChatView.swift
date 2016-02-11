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
    private weak var bottomConstraint: NSLayoutConstraint?
    private let tableView = LiveChatTableView()
    private var oldContentOffset = CGFloat(-1)
    private var isDraggingKeyboard = false
    private lazy var toolbar: LiveChatToolbar = {
        let _toolbar = LiveChatToolbar(socket: self.socket!)
        _toolbar.delegate = self
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
        tableView.delegate = self

        //Add Subviews
        addSubview(tableView)
        constrain(self, tableView) { [unowned self] view, tableView in
            tableView.top == view.top
            tableView.left == view.left
            tableView.right == view.right
            self.bottomConstraint = (tableView.bottom == view.bottom - self.toolbar.frame.size.height)
        }

        //Listen to keyboard change and user tap
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapGestureHandler")
        tableView.addGestureRecognizer(tapGesture)
        
        becomeFirstResponder()
    }
    
    //MARK: Keyboard
    public override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override public var inputAccessoryView: UIView {
        return toolbar
    }
    
//    public override func didMoveToSuperview() {
//        super.didMoveToSuperview()
//        self.becomeFirstResponder()
//    }

    func tapGestureHandler() {
        self.becomeFirstResponder()
    }
    
//    func keyboardWillChangeFrame(notification: NSNotification) {
//        if bounds.size.height == 0 { return }
//        let endFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
//
//////        let oldInset = tableView.contentInset.top
////        let newInset = bounds.size.height - endFrame.origin.y
//////        let newOffset = tableView.contentOffset.y - (newInset - oldInset)
//////        tableView.contentOffset = CGPoint(x: 0, y: newOffset)
////        tableView.contentInset = UIEdgeInsets(top: newInset, left: 0, bottom: 0, right: 0)
//    }
    
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

extension LiveChatView: LiveChatToolbarDelegate {
    func liveChatToolbarDidChangePosition(positionY: CGFloat) {
        if bounds.size.height == 0 { return }
        let keyboardHeight = bounds.size.height - positionY
        bottomConstraint?.constant = -keyboardHeight
        layoutIfNeeded()
        
        if isDraggingKeyboard {
            tableView.contentOffset = CGPoint(x: 0, y: oldContentOffset)
        } else {
            oldContentOffset = tableView.contentOffset.y
            if tableView.dragging {
                isDraggingKeyboard = true
            }
        }
    }
}

extension LiveChatView: UITableViewDelegate {
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        for cell in tableView.visibleCells as! [EventCell] {
            cell.alpha = tableView.alphaForCell(cell)
        }
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isDraggingKeyboard = false
    }
}