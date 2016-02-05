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
    public var username: String
    public var message: String?
    public var userCount: Int?
    
    //MARK: For all incoming events
    init?(dict: AnyObject?, type: Type) {
        guard let dict = dict as? [String: AnyObject] else { return nil }
        guard let username = dict["username"] as? String else { return nil }
        if username.isEmpty { return nil }
        self.type = type
        self.username = username
        
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
        self.userCount = numUsers
    }
    
    //MARK: For message sent by myself
    init?(username: String, message: String, type: Type) {
        self.type = type
        self.username = username
        self.message = message
    }
}