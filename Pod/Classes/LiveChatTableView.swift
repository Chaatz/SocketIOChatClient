//
//  SocketIOEventView.swift
//  Pods
//
//  Created by Kenneth on 27/1/2016.
//
//

import UIKit

final class LiveChatTableView: UITableView {
    //MARK: Customizable Properties
    let eventCacheSize = 100
    let visibleProportion = CGFloat(0.3)
    let fadingDistance = CGFloat(100)

    //MARK: Init
    private var eventArray = [SocketIOEvent]()
    private var screenHeight = max(UIScreen.mainScreen().bounds.size.height, UIScreen.mainScreen().bounds.size.width)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        commonInit()
    }
    
    private func commonInit() {
        separatorStyle = .None
        backgroundColor = UIColor.clearColor()
        showsVerticalScrollIndicator = false
        tableFooterView = UIView()
        rowHeight = UITableViewAutomaticDimension
        estimatedRowHeight = 44.0
        dataSource = self
        delegate = self
        keyboardDismissMode = .Interactive
        
        let podBundle = NSBundle(forClass: self.classForCoder)
        if let bundleURL = podBundle.URLForResource("SocketIOChatClient", withExtension: "bundle") {
            if let bundle = NSBundle(URL: bundleURL) {
                registerNib(UINib(nibName: "MessageCell", bundle: bundle), forCellReuseIdentifier: "MessageCell")
                registerNib(UINib(nibName: "UserJoinCell", bundle: bundle), forCellReuseIdentifier: "UserJoinCell")
            }else {
                assertionFailure("Could not load xib from bundle")
            }
        }else {
            assertionFailure("Could not create a path to the bundle")
        }
        transform = CGAffineTransformMakeScale (1,-1);
    }
    
    //MARK: Managing Events
    func appendEvent(event: SocketIOEvent) {
//        let currentOffset = contentOffset
        print("before: \(contentOffset.y)")
        
        self.beginUpdates()
        
        if self.eventArray.count > self.eventCacheSize {
            self.eventArray.removeLast()
            let indexPath = NSIndexPath(forRow: self.eventArray.count, inSection: 0)
            self.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        }
        
        self.eventArray.insert(event, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
        
//        setContentOffset(currentOffset, animated: true)

        self.endUpdates()
        
        print("after: \(contentOffset.y)")
    }
}

//MARK: UITableViewDataSource
extension LiveChatTableView: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventArray.count
    }
    
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

extension LiveChatTableView: UITableViewDelegate {
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        let visiblePos = screenHeight * visibleProportion
//        for cell in visibleCells as! [EventCell] {
//            let cellPos = convertPoint(cell.frame.origin, toView: self).y - contentOffset.y
//            if cellPos <= visiblePos {
//                cell.contentView.alpha = 1.0
//            } else if cellPos < visiblePos + fadingDistance {
//                cell.contentView.alpha = 1.0 - ((cellPos - visiblePos) / fadingDistance)
//            } else {
//                cell.contentView.alpha = 0.0
//            }
//        }
//    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        for cell in visibleCells as! [EventCell] {
            cell.alpha = alphaForCellAtFrame(cell.frame)
        }
    }
}

extension LiveChatTableView: EventCellDelegate {
    func alphaForCellAtFrame(frame: CGRect) -> CGFloat {
        let visiblePos = screenHeight * visibleProportion
        let cellPos = frame.origin.y - contentOffset.y
        if cellPos <= visiblePos {
            return 1.0
        } else if cellPos < visiblePos + fadingDistance {
            return 1.0 - ((cellPos - visiblePos) / fadingDistance)
        } else {
            return 0.0
        }
    }
}

//MARK: Handle Touches
extension LiveChatTableView {
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let superview = superview {
            superview.touchesBegan(touches, withEvent: event)
        }
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let superview = superview {
            superview.touchesEnded(touches, withEvent: event)
        }
        super.touchesEnded(touches, withEvent: event)
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        if let superview = superview {
            superview.touchesCancelled(touches, withEvent: event)
        }
        super.touchesCancelled(touches, withEvent: event)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let superview = superview {
            superview.touchesMoved(touches, withEvent: event)
        }
        super.touchesMoved(touches, withEvent: event)
    }
}
