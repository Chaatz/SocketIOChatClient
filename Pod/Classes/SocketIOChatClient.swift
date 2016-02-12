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
    func socketIOEventForReceivedData(eventName: String, items: NSArray?) -> SocketIOEvent?
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
        
        socket.onAny { [weak self] (event) -> Void in
            guard let event = self?.delegate?.socketIOEventForReceivedData(event.event, items: event.items) else { return }
            self?.liveChatView.appendEvent(event)
        }
        
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
        
        socket.on("error") { (data, Ack) -> Void in
            print("⛔️⛔️⛔️⛔️⛔️error⛔️⛔️⛔️⛔️⛔️")
        }
        
        socket.connect(timeoutAfter: timeout, withTimeoutHandler: { [weak self] () -> Void in
            print("⛔️⛔️⛔️⛔️⛔️connect fail⛔️⛔️⛔️⛔️⛔️")
            self?.delegate?.socketIOConnectFail()
        })
    }
    
    public func disconnect() {
        socket.disconnect()
    }
    
    //MARK: Handle Events
    func sendMessage(message: String) -> Bool {
        if socket.status == SocketIOClientStatus.Connected {
            socket.emit("new message", message)
            let event = SocketIOEvent(type: .NewMessage, username: self.username, message: message)
            liveChatView.appendEvent(event)
            return true
        } else {
            return false
        }
    }
}