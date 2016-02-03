//
//  ViewController.swift
//  SocketIO
//
//  Created by Keith on 01/26/2016.
//  Copyright (c) 2016 Keith. All rights reserved.
//

import UIKit
import SocketIOChatClient
import SnapKit

class ChatViewController: UIViewController {

    //MARK: Init
    let socketURL = NSURL(string:"http://chat.socket.io")!
    var username: String!
    lazy var socket: SocketIOChatClient = {
        return SocketIOChatClient(socketURL: self.socketURL, username: self.username, timeout: 10, delegate: self, showLog: true)
    }()

    //MARK: ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(socket.liveChatView)
        socket.liveChatView.snp_makeConstraints { [unowned self] (make) -> Void in
            make.edges.equalTo(self.view)
        }
        socket.connect()
    }

    deinit {
        socket.disconnect()
    }

}

extension ChatViewController: SocketIOChatClientDelegate {
    func SocketIOConnectSuccess() {
    }
    func SocketIOConnectFail() {
    }
    func SocketIODisconnected() {
    }
    func SocketIOReceiveEvent(message: SocketIOEvent) {
    }
}