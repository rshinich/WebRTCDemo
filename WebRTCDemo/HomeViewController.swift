//
//  HomeViewController.swift
//  WebRTCDemo
//
//  Created by 张忠瑞 on 2020/6/16.
//  Copyright © 2020 张忠瑞. All rights reserved.
//

import UIKit
import WebRTC
import SnapKit

enum RTCConnectStatus {
    case unconneted
    case connected
}

class HomeViewController: UIViewController {

    //MARK: - Property
    private var webRTCClient: WebRTCClient
    private var signalClient: SignalingClient

    private var signalClientDidConnect: Bool = false {
        didSet {
            if signalClientDidConnect {
                self.socketLabel.text = "Socket连接状态：🟢"
            } else {
                self.socketLabel.text = "Socket连接状态：🔴"
            }
        }
    }
    private var rtcStatus: RTCConnectStatus = .unconneted {
        didSet {

        }
    }
    private var hasLocalSdp: Bool = false {
        didSet {
            DispatchQueue.main.async {
                if self.hasLocalSdp {
                    self.localStatusLabel.text = "本地SDP状态：🟢"
                } else {
                    self.localStatusLabel.text = "本地SDP状态：🔴"
                }
            }
        }
    }
    private var localCandidateCount: Int = 0 {
        didSet {

        }
    }
    private var hasRemoteSdp: Bool = false {
        didSet {
            DispatchQueue.main.async {
                if self.hasRemoteSdp {
                    self.remoteStatusLabel.text = "远程SDP状态：🟢"
                } else {
                    self.remoteStatusLabel.text = "远程SDP状态：🔴"
                }
            }
        }
    }
    private var remoteCandidateCount: Int = 0 {
        didSet {

        }
    }

    private let socketLabel = UILabel.init()
    private let localStatusLabel = UILabel.init()
    private let remoteStatusLabel = UILabel.init()

    let sendOfferBtn = UIButton.init()
    let sendAnswerBtn = UIButton.init()

    let localVideoView = UIView.init()
    let remoteVideoView = UIView.init()

    //MARK: - Implementation

    init(signalClient: SignalingClient, webRTCClient: WebRTCClient) {

        self.signalClient = signalClient
        self.webRTCClient = webRTCClient

        super.init(nibName: nil, bundle: Bundle.main)

    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupViews()
        self.setupWebRTC()
        self.setupRender()

    }
    

    //MARK: - Private method

    func setupViews() {

        self.view.backgroundColor = UIColor.white

        self.view.addSubview(self.socketLabel)
        self.view.addSubview(self.localStatusLabel)
        self.view.addSubview(self.remoteStatusLabel)
        self.view.addSubview(self.sendOfferBtn)
        self.view.addSubview(self.sendAnswerBtn)
        self.view.addSubview(self.localVideoView)
        self.view.addSubview(self.remoteVideoView)

        self.socketLabel.text = "Socket连接状态：🔴"
        self.socketLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.view.snp.left)
            make.right.equalTo(self.view.snp.right)
            make.top.equalTo(self.view.snp.top).offset(20)
            make.height.equalTo(50)
        }

        self.localStatusLabel.text = "本地SDP状态：🔴"
        self.localStatusLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.socketLabel.snp.left)
            make.right.equalTo(self.socketLabel.snp.right)
            make.top.equalTo(self.socketLabel.snp.bottom)
            make.height.equalTo(50)
        }

        self.remoteStatusLabel.text = "远程SDP状态：🔴"
        self.remoteStatusLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.localStatusLabel.snp.left)
            make.right.equalTo(self.localStatusLabel.snp.right)
            make.top.equalTo(self.localStatusLabel.snp.bottom)
            make.height.equalTo(50)
        }

        self.sendOfferBtn.setTitle("发送Offer", for: .normal)
        self.sendOfferBtn.setTitleColor(UIColor.systemTeal, for: .normal)
        self.sendOfferBtn.addTarget(self, action: #selector(sendOfferBtnClicked), for: .touchUpInside)
        self.sendOfferBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self.remoteStatusLabel.snp.left)
            make.top.equalTo(self.remoteStatusLabel.snp.bottom)
            make.width.equalTo(200)
            make.height.equalTo(50)
        }

        self.sendAnswerBtn.setTitle("发送Answer", for: .normal)
        self.sendAnswerBtn.setTitleColor(UIColor.systemTeal, for: .normal)
        self.sendAnswerBtn.addTarget(self, action: #selector(sendAnswerBtnClicked), for: .touchUpInside)
        self.sendAnswerBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self.sendOfferBtn.snp.left)
            make.right.equalTo(self.sendOfferBtn.snp.right)
            make.top.equalTo(self.sendOfferBtn.snp.bottom)
            make.height.equalTo(50)
        }

        self.localVideoView.frame = CGRect.init(x: 0, y: 300, width: 200, height: 200)
        self.remoteVideoView.frame = CGRect.init(x: 200, y: 300, width: 200, height: 200)
    }

    func setupRender() {

        #if arch(arm64)

        let localRender = RTCMTLVideoView(frame: self.localVideoView.bounds)
        localRender.videoContentMode = .scaleToFill

        let remoteRender = RTCMTLVideoView(frame: self.remoteVideoView.bounds)
        remoteRender.videoContentMode = .scaleToFill

        #else

        let localRender = RTCEAGLVideoView(frame: self.localVideoView.bounds)
        let remoteRender = RTCEAGLVideoView(frame: self.remoteVideoView.bounds)

        #endif

        self.webRTCClient.startCaptureLocalVideo(renderer: localRender)
        self.webRTCClient.renderRemoteVideo(to: remoteRender)

        self.localVideoView.addSubview(localRender)
        self.remoteVideoView.addSubview(remoteRender)

    }

    func setupWebRTC() {

        self.signalClient.deleagte = self
        self.signalClient.connect()

        self.webRTCClient.delegate = self

    }

    //MARK:- Event

    @objc func sendOfferBtnClicked() {

        self.webRTCClient.offer { (sdp) in

            self.hasLocalSdp = true
            self.signalClient.send(sdp: sdp)
        }

    }

    @objc func sendAnswerBtnClicked() {

        self.webRTCClient.answer { (localSdp) in
            self.hasLocalSdp = true
            self.signalClient.send(sdp: localSdp)
        }
    }

}

//MARK: - WebRTCClientDelegate

extension HomeViewController: WebRTCClientDelegate {

    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        self.localCandidateCount += 1
        self.signalClient.send(candidate: candidate)
    }

    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        switch state {
        case .connected, .completed:
            self.rtcStatus = .connected
        default:
            self.rtcStatus = .unconneted
        }
    }

    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {

        DispatchQueue.main.async {
            let message = String(data: data, encoding: .utf8) ?? "(Binary: \(data.count) bytes)"
            let alert = UIAlertController(title: "收到信息", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

    }
}

//MARK: - SignalClientDelegate

extension HomeViewController: SignalClientDelegate {

    func signalClientDidConnect(_ signalClient: SignalingClient) {
        self.signalClientDidConnect = true
    }

    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        self.signalClientDidConnect = false
    }

    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {

        self.webRTCClient.set(remoteSdp: sdp) { (error) in
            self.hasRemoteSdp = true
        }

    }

    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {

        self.remoteCandidateCount += 1
        self.webRTCClient.set(remoteCandidate: candidate)
    }
}

