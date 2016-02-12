//
//  SocketIO.swift
//  Pods
//
//  Created by Kenneth on 26/1/2016.
//
//

import SocketIOClientSwift

public protocol SocketIOChatClientDelegate: class {
    func socketIOConnectSuccess()
    func socketIOConnectFail()
    func socketIODisconnected()
    func socketIOReceiveEvent(event: SocketIOEvent)
    func socketIOSendMessageFail()
    func socketIOSendMessageSuccess()
}

final public class SocketIOChatClient {
    //MARK: Init
    private let socket: SocketIOClient
    private let timeout: Int
    private let username: String
    private let showLog: Bool
    private weak var delegate: SocketIOChatClientDelegate?
    public lazy var liveChatView: LiveChatView = {
        let _liveChatView = LiveChatView(socket: self)
        _liveChatView.toolbar.startLoading()
        return _liveChatView
    }()
    
    public init(socketURL: NSURL, username: String, timeout: Int, delegate: SocketIOChatClientDelegate?, showLog: Bool) {
        self.timeout = timeout
        self.delegate = delegate
        self.showLog = showLog
        self.username = username
        socket = SocketIOClient(socketURL: socketURL, options: [.Log(showLog), .ReconnectWait(3)])
    }
    
    deinit {
        disconnect()
    }
    
    //MARK: Socket Life Cycle
    public func connect() {
//        socket.onAny {
//            print("[Socket.IO Event] \($0.event), \($0.items)")
//        }
        
        socket.on("connect") { [weak self] (data, Ack) -> Void in
            if let username = self?.username {
                print("✅✅✅✅✅connect✅✅✅✅✅")
                self?.delegate?.socketIOConnectSuccess()
                self?.socket.emit("add user", username)
                self?.liveChatView.toolbar.stopLoading()
            }
        }
        
        socket.on("disconnect") { [weak self] (data, Ack) -> Void in
            print("❎❎❎❎❎disconnect❎❎❎❎❎")
            self?.delegate?.socketIODisconnected()
            self?.liveChatView.toolbar.startLoading()
        }
        
        socket.on("reconnect") { [weak self] (data, Ack) -> Void in
            print("✴️✴️✴️✴️✴️reconnect✴️✴️✴️✴️✴️")
            self?.liveChatView.toolbar.startLoading()
        }
        
//        socket.on("reconnectAttempt") { [weak self] (data, Ack) -> Void in
//            print("✴️✴️✴️✴️✴️reconnectAttempt✴️✴️✴️✴️✴️")
//            self?.liveChatView.toolbar.startLoading()
//        }
        
        socket.on("error") { (data, Ack) -> Void in
            print("⛔️⛔️⛔️⛔️⛔️error⛔️⛔️⛔️⛔️⛔️")
        }
        
        socket.on("login") { [weak self] (data, Ack) -> Void in
            if let username = self?.username {
                let event = SocketIOEvent(dict: data[0], username: username, type: .Login)
                self?.receiveEvent(event)
            }
        }
        
        socket.on("user joined") { [weak self] (data, Ack) -> Void in
            let event = SocketIOEvent(dict: data[0], type: .UserJoined)
            self?.receiveEvent(event)
        }

        socket.on("user left") { [weak self] (data, Ack) -> Void in
            let event = SocketIOEvent(dict: data[0], type: .UserLeft)
            self?.receiveEvent(event)
        }

        socket.on("new message") { [weak self] (data, Ack) -> Void in
            let event = SocketIOEvent(dict: data[0], type: .NewMessage)
            self?.receiveEvent(event)
        }

        socket.connect(timeoutAfter: timeout, withTimeoutHandler: { [weak self] () -> Void in
            self?.delegate?.socketIOConnectFail()
        })
    }
    
    public func disconnect() {
        socket.disconnect()
    }
    
    //MARK: Handle Events
    private func receiveEvent(event: SocketIOEvent?) {
        guard let event = event else { return }
        liveChatView.appendEvent(event)
        delegate?.socketIOReceiveEvent(event)
    }
    
    func sendMessage(message: String) -> Bool {
        if socket.status == SocketIOClientStatus.Connected {
            if let event = SocketIOEvent(username: self.username, message: message, type: .NewMessage) {
                socket.emit("new message", message)
                receiveEvent(event)
            }
            delegate?.socketIOSendMessageSuccess()
            return true
        } else {
            delegate?.socketIOSendMessageFail()
            return false
        }
    }
}