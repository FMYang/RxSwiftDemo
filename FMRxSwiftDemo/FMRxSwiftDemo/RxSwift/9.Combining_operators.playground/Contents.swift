import UIKit
import RxSwift

/**
 组合操作符：
 startWith: 设置序列的初始值，先发射初始值，然后发送原序列的值
 concat: 将多个observable按顺序串联起来，前一个元素发射完毕后，后一个才开始发射元素。
         任何时候发出错误，串联的observable依次发出错误并终止。
         注意：concat连接的observable的类型必须相同，否则编译器会报错
 concatMap: 将源observable的每一个元素应用一个转换方法，转换成一个新的observable，
            按顺序发出，前一个发射完成后，后一个才开始放射
 zip:
 */

public func example(of description: String, action: ()->Void) {
    print("\n--- Example of:", description, "---")
    action()
}

example(of: "startWith") {
    Observable.of(2, 3, 4)
        .startWith(1) // 初始值1
        .subscribe(onNext: {
            print($0)
        })
        .dispose()
    
    // 输出 1，2，3，4（先发出初始值1，然后发出原序列的值2，3，4）
}

example(of: "concat") {
    let observable1 = Observable.of(1, 2, 3)
    let observable2 = Observable.of(4, 5, 6)
    
    // concat实例方法
    observable1.concat(observable2)
        .subscribe(onNext: {
            print($0)
        })
        .dispose()
    
    // concat类方法
//    Observable.concat([observable1, observable2])
//        .subscribe(onNext: {
//            print($0)
//        })
//        .dispose()
}

example(of: "zip") {
    let observable1 = Observable.of(1, 2, 3)
    let observable2 = Observable.of(4, 5, 6, 7)
    
    // zip类方法，zip没有实例方法
    Observable.zip([observable1, observable2])
        .subscribe(onNext: {
            print($0)
        })
        .dispose()
}

example(of: "concatMap") {
    let sequences = [
        "key1": Observable.of("1", "2", "3"),
        "key2": Observable.of("A", "B", "C")
    ]
        
    let observable = Observable.of("key1", "key2")
        .concatMap { key in
            sequences[key] ?? .empty()
        }
        .subscribe(onNext: {
            print($0)
        })
}
