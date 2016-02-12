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
    lazy var socket: SocketIOChatClient = {
        return SocketIOChatClient(socketURL: self.socketURL, username: self.username, timeout: 10, delegate: self, showLog: false)
    }()

    //MARK: ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        socket.liveChatView.canSendMessage = true
        view.addSubview(socket.liveChatView)
        constrain(view, socket.liveChatView) { view, liveChatView in
            liveChatView.edges == inset(view.edges, 0)
        }
        socket.connect()
    }

    deinit {
        socket.disconnect()
    }

//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        print("touchBegan")
//    }
}

extension ChatViewController: SocketIOChatClientDelegate {
    func socketIOConnectSuccess() {
    }
    func socketIOConnectFail() {
    }
    func socketIODisconnected() {
    }
    func socketIOReceiveEvent(message: SocketIOEvent) {
    }
    func socketIOSendMessageFail() {
    }
    func socketIOSendMessageSuccess() {
    }
}