//
//  SocketIOEventView.swift
//  Pods
//
//  Created by Kenneth on 27/1/2016.
//
//

final class LiveChatTableView: UITableView {
    //MARK: Customizable Properties
    let fadeoutEventsScreenPortion = CGFloat(0.4)
    let minNumberOfEventsDisplay = 10
    let fadeoutTimer = NSTimeInterval(10)

    //MARK: Init
    private var eventArray = [SocketIOEvent]()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initTableView()
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        initTableView()
    }
    
    private func initTableView() {
        scrollEnabled = false
        separatorStyle = .None
        backgroundColor = UIColor.clearColor()
        tableFooterView = UIView()
        rowHeight = UITableViewAutomaticDimension
        estimatedRowHeight = 44.0
        dataSource = self
        
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
        eventArray.insert(event, atIndex: 0)
        beginUpdates()
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        insertRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
        endUpdates()
        
        // Delete cells that moved out of the screen
        deleteInvisibleEvents()

        // Fadeout cells that reach the top half of the screen, but always keep first 4 rows
        fadeoutExpiredEvents()
    }
    
    private func deleteInvisibleEvents() {
        guard let lastVisibleRow = indexPathsForVisibleRows?.last?.row else { return }
        
        // Keep 1 more page incase when device rotate or keyboard show/hide
        let lastRow = numberOfRowsInSection(0) / 2
        
        if lastRow > lastVisibleRow {
            beginUpdates()
            for row in lastVisibleRow+1 ... lastRow {
                self.eventArray.removeLast()
                let indexPath = NSIndexPath(forRow: row, inSection: 0)
                deleteRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            }
            endUpdates()
        }
    }

    private func fadeoutExpiredEvents() {
        let fadeoutPoint = bounds.size.height * fadeoutEventsScreenPortion
        for cell in visibleCells as! [EventCell] {
            if let row = indexPathForCell(cell)?.row {
                if row >= minNumberOfEventsDisplay && cell.frame.origin.y > fadeoutPoint {
                    if eventArray[row].expire == SocketIOEvent.Expire.Waiting {
                        eventArray[row].expire = SocketIOEvent.Expire.Immediately
                        cell.fadeout()
                    }
                }
            }
        }
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
            cell.event = eventArray[indexPath.row]
            if eventArray[indexPath.row].expire == .Immediately {
                cell.alpha = 0.0
            }
            if eventArray[indexPath.row].expire == .None {
                eventArray[indexPath.row].expire = .Waiting
                cell.startFadeoutTimer(fadeoutTimer)
            }
            return cell
        case .UserJoined, .UserLeft, .Login:
            let cell = tableView.dequeueReusableCellWithIdentifier("UserJoinCell", forIndexPath: indexPath) as! UserJoinCell
            cell.event = eventArray[indexPath.row]
            if eventArray[indexPath.row].expire == .Immediately {
                cell.alpha = 0.0
            }
            if eventArray[indexPath.row].expire == .None {
                eventArray[indexPath.row].expire = .Waiting
                cell.startFadeoutTimer(fadeoutTimer)
            }
            return cell
        }
        
    }
}