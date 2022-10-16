//
//  NameSpace.swift
//  FMRxSwiftDemo
//
//  Created by yfm on 2022/10/15.
//

import UIKit

struct NameSpace<Base> {
    let base: Base
    init(base: Base) {
        self.base = base
    }
}

protocol NameSpaceProtocol {
    associatedtype T
    var zy: T { get }
}

extension NameSpaceProtocol {
    var zy: NameSpace<Self> {
        return NameSpace<Self>(base: self)
    }
}

extension NSObject: NameSpaceProtocol {}

extension NameSpace where Base: UIButton {
    func hello() {
        print("Hello")
    }
}
