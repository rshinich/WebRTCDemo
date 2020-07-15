//
//  AppDelegate.swift
//  WebRTCDemo
//
//  Created by 张忠瑞 on 2020/6/10.
//  Copyright © 2020 张忠瑞. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    internal var window: UIWindow?

    //这里设置你的服务器端电脑连接的wifi的ip地址
    let defaultSighnalingServerUrl = URL(string: "ws://192.168.3.7:8080")!

    //谷歌的公共stun服务器
    let defaultIceServers:[String] = ["stun:stun.l.google.com:19302",
                                      "stun:stun1.l.google.com:19302",
                                      "stun:stun2.l.google.com:19302",
                                      "stun:stun3.l.google.com:19302",
                                      "stun:stun4.l.google.com:19302"]


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {


        let webSocket = StarscreamWebSocket.init(url: defaultSighnalingServerUrl)

        let signalClient = SignalingClient.init(webSocket: webSocket)

        let webRTCClient = WebRTCClient.init(iceServers: defaultIceServers)

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = HomeViewController(signalClient: signalClient, webRTCClient: webRTCClient)
        window.makeKeyAndVisible()
        self.window = window

        return true
    }
}

