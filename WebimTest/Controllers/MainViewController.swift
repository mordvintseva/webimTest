//
//  ViewController.swift
//  WebimTest
//
//  Created by Alena on 02/07/2019.
//  Copyright © 2019 Alena. All rights reserved.
//

import UIKit
import VK_ios_sdk

class MainViewController: UIViewController {
    private var alert = UIAlertController(title: "Something went wrong", message: "Please, check your internet connection and try again", preferredStyle: .alert)
    private let APP_ID = "7041764"
    private let scope = ["friends"]
    private var sdkInstance: VKSdk!

    @IBAction private func AuthorizeButton(_ sender: Any) {
        makeWakeUpSession()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        sdkInstance = VKSdk.initialize(withAppId: APP_ID)
        sdkInstance.register(self)
        checkIfAuthorized()
    }
    
    func checkIfAuthorized() {
        VKSdk.wakeUpSession(scope) { (state, error) in
            if state == .authorized {
                guard let token = VKSdk.accessToken() else {
                    self.present(self.alert, animated: true, completion: nil)
                    return
                }
                self.goToInfoViewController(with: token)
            }
        }
    }
    
    func makeWakeUpSession() {
        VKSdk.wakeUpSession(scope) { (state, error) in
            switch state {
            case .authorized:
                guard let token = VKSdk.accessToken() else {
                    self.present(self.alert, animated: true, completion: nil)
                    return
                }
                self.goToInfoViewController(with: token)
            case .initialized:
                VKSdk.authorize(self.scope)
            case .error:
                self.present(self.alert, animated: true, completion: nil)
            default:
                break
            }
        }
    }
    
    func goToInfoViewController(with token: VKAccessToken) {
        if VKSdk.isLoggedIn() {
            guard let infoViewController = self.storyboard?.instantiateViewController(withIdentifier: "InfoViewController")
                as? InfoViewController, let navigatonController = navigationController else {
                return
            }
            infoViewController.set(token)
            navigatonController.pushViewController(infoViewController, animated: true)
        }
    }
}

extension MainViewController: VKSdkDelegate {
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        if let token = result.token {
            goToInfoViewController(with: token)
        } else if result.error != nil {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func vkSdkUserAuthorizationFailed() {
        self.present(alert, animated: true, completion: nil)
    }
}

