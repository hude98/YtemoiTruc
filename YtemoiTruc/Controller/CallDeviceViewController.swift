//
//  CallDeviceViewController.swift
//  ytemoi_app_yta
//
//  Created by Ta Huy Hung on 25/05/2021.
//

import UIKit
import linphonesw

class CallDeviceViewController: UIViewController {
    @IBOutlet weak var lblPatientName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnVolume: UIButton!
    @IBOutlet weak var imgLedStatus: UIImageView!
    @IBOutlet weak var lblConnectStatus: UILabel!
    
    var patientSip = ""
    var patientName = ""
    var isSpeakerEnabled : Bool = false
    var currentTime = 0
    var timeInterval : TimeInterval?
    var timer : Timer?
    
    var mCore: Core!
    var coreVersion: String = Core.getVersion
    var mAccount: Account?
    var mCoreDelegate : CoreDelegate!
    var username : String?
    var passwd : String?
    var domain : String?
    var callMsg : String = ""
    var isCallRunning : Bool = false
    var remoteAddress : String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        initWhenScreenAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        terminateCall()
    }
    
    @IBAction func onVolumeBtnPressed(_ sender: Any) {
        toggleSpeaker()
        setVolumeImage()
    }
    
    @IBAction func onCancelCallBtnPressed(_ sender: Any) {
        self.terminateCall()
        let listNewsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ListNewsViewController") as! ListNewsViewController
        let nav = UINavigationController()
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = nav
        nav.pushViewController(listNewsVC, animated: true)
    }
    
    @objc func appMovedToBackground(){
        self.terminateCall()
    }
    
    private func setVolumeImage(){
        if btnVolume.currentImage == UIImage(named: "volume") {
            btnVolume.setImage(UIImage(named: "ico_mute"), for: .normal)
        }
        else{
            btnVolume.setImage(UIImage(named: "volume"), for: .normal)
        }
    }
    
    func getTimeFormat(_ timeInterval : TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    
    @objc func updateTime(){
        currentTime += 1
        timeInterval = TimeInterval(currentTime)
        lblTime.text = getTimeFormat(timeInterval!)
    }
    
    func stopTimer() {
        if let timer = timer {
            print("stop timer")
            timer.invalidate()
        }
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    func changeConnectStatus(_ imgName : String, _ status : String){
        imgLedStatus.image = UIImage(named: imgName)
        lblConnectStatus.text = status
    }
    
    
    private func initWhenScreenAppear(){
        self.navigationController?.isNavigationBarHidden = true
        lblPatientName.text = "Bệnh nhân: \(patientName)"
        changeConnectStatus("led_inprogress", "Đang kết nối...")
        
        username = Utils.getUserInfo().sipGlobal
        passwd = Utils.getUserInfo().sipGlobalPass
        domain = Network.domain
        remoteAddress = "sip:\(patientSip)@\(domain!):5060"
        
        print("remoteAddress : \(remoteAddress ?? "")")
        linphoneInit()
        outgoingCall()
    }
    
    
    private func linphoneInit()
    {
        LoggingService.Instance.logLevel = LogLevel.Debug
        
        if Linphone.shared.getLinphoneCore() == nil {
            try? mCore = Factory.Instance.createCore(configPath: "", factoryConfigPath: "", systemContext: nil)
            Linphone.shared.setLinphoneCore(mCore)
        }
        else{
            mCore = Linphone.shared.getLinphoneCore()
        }
        
        try? mCore.start()
        
        mCoreDelegate = CoreDelegateStub( onCallStateChanged: { (core: Core, call: Call, state: Call.State, message: String) in
            
            self.callMsg = message
            
            if (state == .OutgoingInit) {
                print("OutgoingInit")
            }
            
            else if (state == .OutgoingProgress) {
                print("OutgoingProgress")
            }
            
            else if (state == .OutgoingRinging) {
                print("It is now ringing remotely !\n")
            }
            
            else if (state == .Connected) {
                print("We are connected !\n")
            }
            
            else if (state == .StreamsRunning) {
                print("Media streams established !\n")
                self.isCallRunning = true
                self.startTimer()
                self.changeConnectStatus("led_connected", "Đã kết nối thành công")
            }
            
            else if (state == .Paused) {
                print("Paused")
            }
            
            else if (state == .PausedByRemote) {
                print("PausedByRemote")
            }
            
            else if (state == .Updating) {
                print("Updating")
            }
            
            else if (state == .UpdatedByRemote) {
                print("UpdatedByRemote")
            }
            
            else if (state == .Released) {
                self.isCallRunning = false
                print("Released")
            }
            
            else if (state == .Error) {
                print("Call failure ! Reason: \(message)")
            }
            
            else{
                print("Current call state : \(state)\n")
            }
            
        })
        mCore.addDelegate(delegate: mCoreDelegate)
        
        login()
    }
    
    func login() {
        do {
            let transport = TransportType.Udp
            let authInfo = try Factory.Instance.createAuthInfo(username: username!, userid: "", passwd: passwd!, ha1: "", realm: "", domain: domain)
            let accountParams = try mCore.createAccountParams()
            let identity = try Factory.Instance.createAddress(addr: String("sip:" + username! + "@" + domain!))
            try! accountParams.setIdentityaddress(newValue: identity)
            let address = try Factory.Instance.createAddress(addr: String("sip:" + domain!))
            try address.setTransport(newValue: transport)
            try accountParams.setServeraddress(newValue: address)
            accountParams.registerEnabled = true
            mAccount = try mCore.createAccount(params: accountParams)
            mCore.addAuthInfo(info: authInfo)
            try mCore.addAccount(account: mAccount!)
            mCore.defaultAccount = mAccount
            
        } catch { NSLog(error.localizedDescription) }
    }
    
    func unregister()
    {
        if let account = mCore.defaultAccount {
            let params = account.params
            let clonedParams = params?.clone()
            clonedParams?.registerEnabled = false
            account.params = clonedParams
        }
    }
    
    func delete() {
        if let account = mCore.defaultAccount {
            mCore.removeAccount(account: account)
            mCore.clearAccounts()
            mCore.clearAllAuthInfo()
        }
    }
    
    
    func outgoingCall() {
        do {
            // As for everything we need to get the SIP URI of the remote and convert it to an Address
            let remoteAddress = try Factory.Instance.createAddress(addr: remoteAddress!)
            
            // We also need a CallParams object
            // Create call params expects a Call object for incoming calls, but for outgoing we must use null safely
            let params = try mCore.createCallParams(call: nil)
            
            // We can now configure it
            // Here we ask for no encryption but we could ask for ZRTP/SRTP/DTLS
            params.mediaEncryption = MediaEncryption.None
            // If we wanted to start the call with video directly
            //params.videoEnabled = true
            
            // Finally we start the call
            let _ = mCore.inviteAddressWithParams(addr: remoteAddress, params: params)
            // Call process can be followed in onCallStateChanged callback from core listener
        } catch { NSLog(error.localizedDescription) }
        
    }
    
    func terminateCall() {
        do {
            if (mCore.callsNb == 0) { return }
            
            // If the call state isn't paused, we can get it using core.currentCall
            let coreCall = (mCore.currentCall != nil) ? mCore.currentCall : mCore.calls[0]
            
            // Terminating a call is quite simple
            if let call = coreCall {
                try call.terminate()
            }
        } catch { NSLog(error.localizedDescription) }
        self.unregister()
        self.delete()
    }
    
    
    func toggleSpeaker() {
        // Get the currently used audio device
        let currentAudioDevice = mCore.currentCall?.outputAudioDevice
        let speakerEnabled = currentAudioDevice?.type == AudioDeviceType.Speaker
        
        let _ = currentAudioDevice?.deviceName
        // We can get a list of all available audio devices using
        // Note that on tablets for example, there may be no Earpiece device
        for audioDevice in mCore.audioDevices {
            
            // For IOS, the Speaker is an exception, Linphone cannot differentiate Input and Output.
            // This means that the default output device, the earpiece, is paired with the default phone microphone.
            // Setting the output audio device to the microphone will redirect the sound to the earpiece.
            if (speakerEnabled && audioDevice.type == AudioDeviceType.Microphone) {
                mCore.currentCall?.outputAudioDevice = audioDevice
                isSpeakerEnabled = false
                return
            } else if (!speakerEnabled && audioDevice.type == AudioDeviceType.Speaker) {
                mCore.currentCall?.outputAudioDevice = audioDevice
                isSpeakerEnabled = true
                return
            }
            /* If we wanted to route the audio to a bluetooth headset
            else if (audioDevice.type == AudioDevice.Type.Bluetooth) {
            core.currentCall?.outputAudioDevice = audioDevice
            }*/
        }
    }
    
}
