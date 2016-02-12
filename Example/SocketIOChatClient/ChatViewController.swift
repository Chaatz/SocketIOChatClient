//
//  ViewController.swift
//  SocketIO
//
//  Created by Keith on 01/26/2016.
//  Copyright (c) 2016 Keith. All rights reserved.
//

import UIKit
import SocketIOChatClient
import Cartography

class ChatViewController: UIViewController {

    //MARK: Init
    let socketURL = NSURL(string:"http://chat.socket.io")!
    var username: String!
    var canSendMessage: Bool!
    lazy var socket: SocketIOChatClient = {
        return SocketIOChatClient(socketURL: self.socketURL, username: self.username, timeout: 10, delegate: self, showLog: false)
    }()

    //MARK: ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        socket.liveChatView.canSendMessage = canSendMessage
        view.addSubview(socket.liveChatView)
        constrain(view, socket.liveChatView) { view, liveChatView in
            liveChatView.edges == inset(view.edges, 0)
        }
        socket.connect()
    }

    deinit {
        socket.disconnect()
    }
}

extension ChatViewController: SocketIOChatClientDelegate {
    func socketIOConnectSuccess() {
    }
    func socketIOConnectFail() {
    }
    func socketIODisconnected() {
    }
    func socketIOSendMessageFail() {
    }
    func socketIOSendMessageSuccess() {
    }

    func socketIOEventForReceivedData(eventName: String, items: NSArray?) -> SocketIOEvent? {
        guard let items = items else { return nil }
        switch eventName {
            
        case "login":
            return SocketIOEvent(type: .Login, username: username)
            
        case "user joined":
            guard let dict = items[0] as? [String: AnyObject] else { return nil }
            guard let username = dict["username"] as? String else { return nil }
            if username.isEmpty { return nil }
            return SocketIOEvent(type: .UserJoined, username: username)
            
        case "user left":
            guard let dict = items[0] as? [String: AnyObject] else { return nil }
            guard let username = dict["username"] as? String else { return nil }
            if username.isEmpty { return nil }
            return SocketIOEvent(type: .UserLeft, username: username)

        case "new message":
            guard let dict = items[0] as? [String: AnyObject] else { return nil }
            guard let username = dict["username"] as? String else { return nil }
            guard let message = dict["message"] as? String else { return nil }
            if username.isEmpty { return nil }
            if message.isEmpty { return nil }
            return SocketIOEvent(type: .NewMessage, username: username, message: message)

        default:
            return nil
        }
    }
}