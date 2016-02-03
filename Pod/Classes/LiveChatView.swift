//
//  ChatView.swift
//  Pods
//
//  Created by Kenneth on 2/2/2016.
//
//

import SnapKit

public final class LiveChatView: UIView {
    
    //MARK: Init
    private weak var socket: SocketIOChatClient?
    private weak var toolbarBottomConstraint: Constraint?
    private let tableView = LiveChatTableView()
    private lazy var toolbar: LiveChatToolbar = {
        return LiveChatToolbar(socket: self.socket!)
    }()

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "keyboardWillChangeFrame:", object: nil)
    }
    
    //MARK: Layout
    public convenience init(socket: SocketIOChatClient) {
        self.init()
        self.socket = socket
        clipsToBounds = true
        backgroundColor = UIColor.clearColor()
        let gradientView = GradientView()
        
        //Add Subviews
        addSubview(gradientView)
        addSubview(tableView)
        addSubview(toolbar)
        
        tableView.snp_makeConstraints { [unowned self] (make) -> Void in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(self)
            make.bottom.equalTo(self.toolbar.snp_top)
        }
        
        toolbar.snp_makeConstraints { [unowned self] (make) -> Void in
            make.left.equalTo(0)
            make.right.equalTo(self)
            self.toolbarBottomConstraint = make.bottom.equalTo(self).constraint
        }
        
        gradientView.snp_makeConstraints { [unowned self] (make) -> Void in
            make.left.equalTo(0)
            make.right.equalTo(self)
            make.height.equalTo(self.toolbar).multipliedBy(2.0)
            make.bottom.equalTo(self.toolbar)
        }

        //Listen to keyboard change and user tap
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapGestureHandler")
        tableView.addGestureRecognizer(tapGesture)
    }
    
    //MARK: Show and Hide Keyboard
    func keyboardWillChangeFrame(notification: NSNotification) {
        let endFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        self.toolbarBottomConstraint?.updateOffset(-(CGRectGetHeight(self.bounds) - endFrame.origin.y))
        UIView.animateWithDuration(0.25) {
            self.layoutIfNeeded()
        }
    }
    
    func tapGestureHandler() {
        toolbar.textField.resignFirstResponder()
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

class GradientView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clearColor()
        layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
        layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    private let gradientLayer: CAGradientLayer = {
        let colorTop = UIColor(white: 0.0, alpha: 0.0).CGColor
        let colorBottom = UIColor(white: 0.0, alpha: 0.4).CGColor
        let _gradientLayer = CAGradientLayer()
        _gradientLayer.colors = [ colorTop, colorBottom]
        _gradientLayer.locations = [ 0.0, 1.0]
        return _gradientLayer
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}