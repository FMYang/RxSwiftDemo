//
//  ViewModel.swift
//  FMRxSwiftDemo
//
//  Created by yfm on 2022/10/12.
//

import UIKit
import RxSwift
import RxCocoa

class ViewModel: NSObject {
//    var str: Driver<String>?
    var str = BehaviorRelay(value: "")
}
