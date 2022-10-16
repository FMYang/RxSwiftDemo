import UIKit
import RxSwift

/**
 转换操作符
 toArray: 将序列转为数组序列
 map: 将序列的每个元素应用转换函数，转换为一个新的序列，可转换类型
 
 */

public func example(of description: String, action: ()->Void) {
    print("\n--- Example of:", description, "---")
    action()
}

func delay(second: Double, block: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + second) {
        block()
    }
}

example(of: "toArray") {
    Observable.of("1", "2")
        .toArray() // 字符串序列转为字符串数组序列
        .subscribe(onSuccess: {
            print($0)
        }, onFailure: { err in
            print(err)
        })
        .dispose()
    
    // 注意：toArray()返回的是single对象，single只产生一个元素，否则错误
}

example(of: "map") {
    Observable.of("1", "2")
        .map { return Int($0) ?? 0 } // 字符串序列转为整形序列
        .subscribe(onNext: {
            print($0)
        })
        .dispose()
}

// flatMap发送未来的observable，网络请求
example(of: "flatMap") {
//    let disposeBag = DisposeBag()
//
//    let observale = Observable.of("1", "2")
//        .flatMap { (str) -> Observable<String> in
//            return Observable.create { observer -> Disposable in
//                delay(second: 1) {
//                    observer.onNext(str + "1")
//                    observer.onCompleted()
//                }
//                return Disposables.create()
//            }
//        }
//        .subscribe(onNext: {
//            print($0)
//        })
//
//    delay(second: 2) {
//        observale.dispose()
//    }
}

example(of: "flatMap_array") {
    struct MM {
        var url: String
    }
    let m1 = MM(url: "url1")
    let m2 = MM(url: "url2")
    
    Observable.of(["1", "2"])
        .flatMap { (arr) -> Observable<String> in
            let tmp = arr.map { $0+"000" }
            return Observable.from(tmp)
        }
        .subscribe(onNext: {
            print($0)
        })
}
