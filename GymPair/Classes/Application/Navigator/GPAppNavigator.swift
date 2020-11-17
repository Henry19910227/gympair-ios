//
//  GPAppNavigator.swift
//  GymPair
//
//  Created by 廖冠翰 on 2020/11/18.
//

import UIKit

class GPAppNavigator: CKAppNavigator {
    var storyboard: UIStoryboard?
    var navigationController: UINavigationController?
    var window: UIWindow
    @discardableResult required init(window: UIWindow) {
        self.window = window
        toLogin()
    }
    
    private func toLogin() {
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
        let loginNav = UINavigationController()
        window.rootViewController = loginNav
        GPLoginNavigator(window, loginNav, loginStoryboard).toRoot()
    }
}
