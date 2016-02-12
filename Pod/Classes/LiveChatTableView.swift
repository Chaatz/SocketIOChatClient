//
//  SocketIOEventView.swift
//  Pods
//
//  Created by Kenneth on 27/1/2016.
//
//

final class LiveChatTableView: UITableView {
    //MARK: Init
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
