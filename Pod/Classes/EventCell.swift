//
//  MessageCell.swift
//  Pods
//
//  Created by Kenneth on 29/1/2016.
//
//

protocol EventCellDelegate: class {
    func alphaForCell(cell: EventCell) -> CGFloat
}

//MARK: Base Cell Class
class EventCell: UITableViewCell {
    @IBOutlet private weak var bubbleView: UIView!
    weak var delegate: EventCellDelegate?

    override func awakeFromNib() {
        backgroundColor = UIColor.clearColor()
        transform = CGAffineTransformMakeScale (1,-1);
        bubbleView.layer.cornerRadius = 4.0
        bubbleView.clipsToBounds = true
        addObserver(self, forKeyPath: "frame", options: .New, context: nil)
    }
    
    deinit {
        removeObserver(self, forKeyPath: "frame")
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let keyPath = keyPath else { return }
        switch keyPath {
        case "frame":
            if let alpha = delegate?.alphaForCell(self) {
                self.alpha = alpha
            } else {
                alpha = 1.0
            }
        default:
            break
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
            bubbleView.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
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
            bubbleView.backgroundColor = UIColor(white: 0.8, alpha: 0.9)
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