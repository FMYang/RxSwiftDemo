import UIKit
import RxSwift

/**
 主题subject，即是观察者也是可观察序列
 
 subject的4种主题类型：
 - PublishSubject
 - BehaviorSubject
 - ReplaySubject
 - Variable(废弃)，BehaviorRelay替代
 
 区别就是对订阅者的影响
 publishSubject: 开始为空，仅向订阅者发出最新的元素
 BehaviorSubject: 初始值开始，重复发出初始值或最新的元素给新的订阅者
 ReplaySubject: 使用缓冲区初始化，重复发送缓冲区的元素给新的订阅者
 
 publishSubject收到终止事件completed、error后，它不在发出next事件，可是会重复发出停止事件给新的订阅者
 BehaviorSubject收到停止事件后，
 */


public func example(of description: String, action: ()->Void) {
    print("\n--- Example of:", description, "---")
    action()
}

example(of: "PublishSubject") {
    let subject = PublishSubject<Int>()
    
    // 订阅之前，发射事件
    subject.onNext(1)
    
    // 订阅
    let subscript1 = subject
        .subscribe(onNext: { e in
            print("1 - \(e)")
        }, onCompleted: {
            print("completed")
        })
    
    // 订阅之后，发射事件
    subject.onNext(2)
    
    let subscript2 = subject
        .subscribe(onNext: { e in
            print("2 - \(e)")
        }, onCompleted: {
            print("completed")
        })
    
    // 订阅之后，发射事件
    subject.onNext(3)
}

example(of: "BehaviorSubject") {
    let subject = BehaviorSubject(value: 1)
    
    // 订阅
    let subscript1 = subject
        .subscribe(onNext: { e in
            print("1 - \(e)")
        }, onCompleted: {
            print("completed")
        })
    
    // 订阅之后，发射事件
    subject.onNext(2)
        
    let subscript2 = subject
        .subscribe(onNext: { e in
            print("2 - \(e)")
        }, onCompleted: {
            print("completed")
        })
    
    subject.onNext(3)
}

example(of: "ReplaySubject") {
    let subject = ReplaySubject<Int>.create(bufferSize: 2)
    
    subject.onNext(1)
    
    // 订阅
    let subscript1 = subject
        .subscribe(onNext: { e in
            print("1 - \(e)")
        }, onCompleted: {
            print("completed")
        })
    
    // 订阅之后，发射事件
    subject.onNext(2)
        
    let subscript2 = subject
        .subscribe(onNext: { e in
            print("2 - \(e)")
        }, onCompleted: {
            print("completed")
        })
    
    subject.onNext(3)
}
