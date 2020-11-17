//
//  GPLoginNavigator.swift
//  GymPair
//
//  Created by 廖冠翰 on 2020/11/18.
//

import UIKit

class GPLoginNavigator {
    weak var storyboard: UIStoryboard?
    weak var navigationController: UINavigationController?
    weak var window: UIWindow?
    
    init(_ window: UIWindow?, _ navigationController: UINavigationController?, _ storyboard: UIStoryboard?) {
        self.navigationController = navigationController
        self.storyboard = storyboard
        self.window = window
    }
}

extension GPLoginNavigator: CKRootNavigator {
    func toRoot() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "GPLoginViewController") as! GPLoginViewController
        navigationController?.pushViewController(vc, animated: true)
    }
}
