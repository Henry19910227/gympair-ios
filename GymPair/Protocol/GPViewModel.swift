//
//  GPViewModel.swift
//  GymPair
//
//  Created by 廖冠翰 on 2020/11/18.
//

import UIKit

protocol GPViewModel {
    associatedtype Input
    associatedtype Output
    func transform(input: Input) -> Output
}
