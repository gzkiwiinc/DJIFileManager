//
//  ViewController.swift
//  DJIFileManager
//
//  Created by zyphs21 on 08/23/2018.
//  Copyright (c) 2018 zyphs21. All rights reserved.
//

import UIKit
import DJISDK
import DJIFileManager

class ViewController: UIViewController {

    @IBOutlet weak var activationState: UILabel!
    @IBOutlet weak var aircraftBindState: UILabel!
    @IBOutlet weak var bridgeModeSwitch: UISwitch!
    @IBOutlet weak var darkStyleModeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func connectAircraft(_ sender: Any) {
        ConnectManager.shared.enableBridgeMode = bridgeModeSwitch.isOn
        ConnectManager.shared.registerApp()
        DJISDKManager.appActivationManager().delegate = self
        activationState.text = DJISDKManager.appActivationManager().appActivationState.description
        aircraftBindState.text = DJISDKManager.appActivationManager().aircraftBindingState.description
    }
    
    @IBAction func login(_ sender: Any) {
        DJISDKManager.userAccountManager().logIntoDJIUserAccount(withAuthorizationRequired: true) { (userAccountState, error) in
            if let error = error {
                print("Login error: " + error.localizedDescription)
                DemoHelper.showAlert(message: "Login error: " + error.localizedDescription)
            } else {
                print("Login Success")
            }
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        DJISDKManager.userAccountManager().logOutOfDJIUserAccount { error in
            if let error = error {
                print("Logout error: " + error.localizedDescription)
                DemoHelper.showAlert(message: "Logout error: " + error.localizedDescription)
            }
        }
    }
    
    @IBAction func toDJIFileManagerBrowser(_ sender: Any) {
        let theme: DJIFileManagerTheme.Type = darkStyleModeSwitch.isOn ? DJIFileManagerDarkTheme.self : DJIFileManagerLightTheme.self
        let mediaFilesViewController = DJIMediaFilesViewController(style: theme)
        if DJISDKManager.appActivationManager().aircraftBindingState != .bound {
//            mediaFilesViewController.mediaFileModelList = fetchTestData()
        }
        self.navigationController?.pushViewController(mediaFilesViewController, animated: true)
    }
    
    func fetchTestData() -> [MediaFileModel] {
        var mediaFileArray = [MediaFileModel]()
        for _ in 0..<40 {
            let testFile = MediaFileModel(djiMediaFile: DJIMediaFile())
            testFile.thumbnailImage = UIImage(named: "image_logo")
            mediaFileArray.append(testFile)
        }
        return mediaFileArray
    }
}


// MARK: - DJIAppActivationManagerDelegate

extension ViewController: DJIAppActivationManagerDelegate {
    
    func manager(_ manager: DJIAppActivationManager!, didUpdate appActivationState: DJIAppActivationState) {
        activationState.text = appActivationState.description
    }
    
    func manager(_ manager: DJIAppActivationManager!, didUpdate aircraftBindingState: DJIAppActivationAircraftBindingState) {
        aircraftBindState.text = aircraftBindingState.description
    }
}

