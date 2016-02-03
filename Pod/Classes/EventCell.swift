//
//  MessageCell.swift
//  Pods
//
//  Created by Kenneth on 29/1/2016.
//
//

//MARK: Base Cell Class
class EventCell: UITableViewCell {
    private var timer: NSTimer?
    private var didFadeout = false
    @IBOutlet private weak var bubbleView: UIView!

    override func awakeFromNib() {
        backgroundColor = UIColor.clearColor()
        transform = CGAffineTransformMakeScale (1,-1);
        bubbleView.layer.cornerRadius = 4.0
        bubbleView.clipsToBounds = true
    }

    deinit {
        timer?.invalidate()
    }
    
    func startFadeoutTimer(fadeoutAfter: NSTimeInterval) {
        timer?.invalidate()
        didFadeout = false
        contentView.alpha = 0.9
        timer = NSTimer.scheduledTimerWithTimeInterval(fadeoutAfter, target: self, selector: "fadeout", userInfo: nil, repeats: false)
    }
    
    func fadeout() {
        timer?.invalidate()
        didFadeout = true
        UIView.animateWithDuration(1.5) { () -> Void in
            self.contentView.alpha = 0.0
        }
    }
}

//MARK: Cell for chat message
final class MessageCell: EventCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var iconView: UIImageView!
    var event: SocketIOEvent? {
        didSet {
            iconView?.backgroundColor = UIColor.orangeColor()
            if let event = event {
                nameLabel.text = "@" + event.username
                messageLabel.text = event.message
            } else {
                nameLabel.text = "@"
                messageLabel.text = " "
            }
        }
    }
}

//MARK: Cell for user joined/left event
final class UserJoinCell: EventCell {
    @IBOutlet private weak var eventLabel: UILabel!
    var event: SocketIOEvent? {
        didSet {
            bubbleView.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
            if let event = event {
                switch event.type {
                case .UserJoined, .Login:
                    eventLabel.text = event.username + " joined"
                case .UserLeft:
                    eventLabel.text = event.username + " left"
                default:
                    eventLabel.text = " "
                }
            } else {
                eventLabel.text = " "
            }
        }
    }
}