//
//  GPNavigator.swift
//  GymPair
//
//  Created by 廖冠翰 on 2020/11/18.
//

import UIKit

protocol CKAppNavigator {
    init(window: UIWindow)
}

protocol CKMainNavigator {
    func toMain()
}

protocol CKRootNavigator {
    func toRoot()
}

protocol GPNavigator {}
