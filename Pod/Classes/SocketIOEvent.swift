//
//  SocketIOEvent.swift
//  Pods
//
//  Created by Kenneth on 2/2/2016.
//
//

public struct SocketIOEvent {
    public enum Type {
        case Login
        case UserJoined
        case UserLeft
        case NewMessage
    }
    public var type: Type
    public var userId: Int
    public var username: String
    public var message: String?
    public var userCount: Int?
    
    public var identityColor: UIColor {
        if userId <= 2 {
            return UIColor(red: 249.0/255.0, green: 222.0/255.0, blue: 143.0/255.0, alpha: 1.0)
        } else if userId <= 4 {
            return UIColor(red: 153.0/255.0, green: 214.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        } else if userId <= 6 {
            return UIColor(red: 161.0/255.0, green: 219.0/255.0, blue: 202.0/255.0, alpha: 1.0)
        } else if userId <= 8 {
            return UIColor(red: 166.0/255.0, green: 208.0/255.0, blue: 212.0/255.0, alpha: 1.0)
        } else {
            return UIColor(red: 214.0/255.0, green: 220.0/255.0, blue: 161.0/255.0, alpha: 1.0)
        }
    }
    
    //MARK: For all incoming events
    init?(dict: AnyObject?, type: Type) {
        guard let dict = dict as? [String: AnyObject] else { return nil }
        guard let username = dict["username"] as? String else { return nil }
        if username.isEmpty { return nil }
        self.type = type
        self.username = username
        self.userId = SocketIOEvent.randomUserId()
        
        switch type {
        case .NewMessage:
            guard let message = dict["message"] as? String else { return nil }
            if message.isEmpty { return nil }
            self.message = message
        case .UserJoined, .UserLeft:
            guard let numUsers = dict["numUsers"] as? Int else { return nil }
            self.userCount = numUsers
        default:
            break
        }
    }
    
    //MARK: For login event
    init?(dict: AnyObject?, username: String, type: Type) {
        guard let dict = dict as? [String: AnyObject] else { return nil }
        guard let numUsers = dict["numUsers"] as? Int else { return nil }
        self.type = type
        self.username = username
        self.userId = SocketIOEvent.randomUserId()
        self.userCount = numUsers
    }
    
    //MARK: For message sent by myself
    init?(username: String, message: String, type: Type) {
        self.type = type
        self.username = username
        self.userId = SocketIOEvent.randomUserId()
        self.message = message
    }
    
    static func randomUserId() -> Int {
        let number = arc4random_uniform(9) + 1
        return Int(number)
    }
}