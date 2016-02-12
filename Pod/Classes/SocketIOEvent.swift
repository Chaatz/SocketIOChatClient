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
    
    public init(type: Type, username: String) {
        self.type = type
        self.userId = SocketIOEvent.randomUserId()
        self.username = username
    }

    public init(type: Type, username: String, message: String) {
        self.type = type
        self.userId = SocketIOEvent.randomUserId()
        self.username = username
        self.message = message
    }

    static func randomUserId() -> Int {
        let number = arc4random_uniform(9) + 1
        return Int(number)
    }
}