//
//  ChatView.swift
//  Pods
//
//  Created by Kenneth on 2/2/2016.
//
//

import Cartography

public final class LiveChatView: UIView {    
    //MARK: Customizable
    public let eventCacheSize = 100
    public let visibleProportion = CGFloat(0.3)
    public let fadingDistance = CGFloat(100)
    public let maxMessageLength = 140

    //MARK: Core
    private weak var socket: SocketIOChatClient?
    private var eventArray = [SocketIOEvent]()
    public var canSendMessage = false {
        didSet {
            if canSendMessage {
                becomeFirstResponder()
            } else {
                endEditing(true)
            }
        }
    }

    //MARK: UI
    private var screenHeight = max(UIScreen.mainScreen().bounds.size.height, UIScreen.mainScreen().bounds.size.width)
    private weak var bottomConstraint: NSLayoutConstraint?
    private var oldContentOffset = CGFloat(-1)
    private var isDraggingKeyboard = false
    lazy var toolbar: LiveChatToolbar = {
        let _toolbar = LiveChatToolbar(socket: self.socket!)
        _toolbar.delegate = self
        return _toolbar
    }()
    private lazy var tableView: LiveChatTableView = {
        let _tableView = LiveChatTableView()
        _tableView.dataSource = self
        _tableView.delegate = self
        return _tableView
    }()
    
    //MARK: Layout
    public convenience init(socket: SocketIOChatClient) {
        self.init()
        self.socket = socket
        clipsToBounds = true
        backgroundColor = UIColor.clearColor()

        //Add Subviews
        addSubview(tableView)
        constrain(self, tableView) { [unowned self] view, tableView in
            tableView.top == view.top
            tableView.left == view.left
            tableView.right == view.right
            self.bottomConstraint = (tableView.bottom == view.bottom)
        }

        //Listen to keyboard change and user tap
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapGestureHandler")
        tableView.addGestureRecognizer(tapGesture)
        
        becomeFirstResponder()
    }
    
    //MARK: Keyboard
    public override func canBecomeFirstResponder() -> Bool {
        return canSendMessage
    }
    
    override public var inputAccessoryView: UIView {
        return toolbar
    }
    
    func tapGestureHandler() {
        self.becomeFirstResponder()
    }
    
    //MARK: Managing Events
    func appendEvent(event: SocketIOEvent) {
        tableView.beginUpdates()
        
        if self.eventArray.count > self.eventCacheSize {
            self.eventArray.removeLast()
            let indexPath = NSIndexPath(forRow: self.eventArray.count, inSection: 0)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        }
        
        self.eventArray.insert(event, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
        
        tableView.endUpdates()
    }

}

//MARK: UITableViewDataSource
extension LiveChatView: UITableViewDataSource {
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventArray.count
    }
  public   
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let event = eventArray[indexPath.row]
        
        switch event.type {
        case .NewMessage:
            let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! MessageCell
            cell.delegate = self
            cell.event = eventArray[indexPath.row]
            return cell
        case .UserJoined, .UserLeft, .Login:
            let cell = tableView.dequeueReusableCellWithIdentifier("UserJoinCell", forIndexPath: indexPath) as! UserJoinCell
            cell.delegate = self
            cell.event = eventArray[indexPath.row]
            return cell
        }
    }
}

//MARK: UITableViewDelegate
extension LiveChatView: UITableViewDelegate {
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        for cell in tableView.visibleCells as! [EventCell] {
            cell.alpha = alphaForCell(cell)
        }
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isDraggingKeyboard = false
    }
}

//MARK: EventCellDelegate
extension LiveChatView: EventCellDelegate {
    func alphaForCell(cell: EventCell) -> CGFloat {
        let visiblePos = screenHeight * visibleProportion
        let cellPos = cell.frame.origin.y - tableView.contentOffset.y
        if cellPos <= visiblePos {
            return 1.0
        } else if cellPos < visiblePos + fadingDistance {
            return 1.0 - ((cellPos - visiblePos) / fadingDistance)
        } else {
            return 0.0
        }
    }
}

//MARK: LiveChatToolbarDelegate
extension LiveChatView: LiveChatToolbarDelegate {
    func keyboardDidChangeHeight(height: CGFloat) {
//        if bounds.size.height == 0 { return }        
        bottomConstraint?.constant = -height
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