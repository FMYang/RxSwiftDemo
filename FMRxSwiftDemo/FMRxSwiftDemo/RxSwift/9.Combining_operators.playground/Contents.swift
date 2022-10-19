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
 merge: 将多个observable合并成一个，有一个observable发射错误，合并的observable发送错误并立即终止
 combineLatest: 将多个observable中最新的元素通过一个函数组合起来，然后将结果发出来。
 zip: 将多个observable（最多不超过8个）的元素通过一个函数组合起来，严格按照索引数进行组合。
      组合出来的observable的元素数量等于元素数量最少的那一个
 withLatestFrom: 将两个observable中最新的元素通过一个函数组合起来，然后将这个组合的结果发出来。
                 当第一个observable发出一个元素时，就立即取敌个observable中最新的元素，通过一个组合函数
                 将两个最新的元素组合后发送出去。
 amb: 订阅两个observable，等待它们中的任何一个发出元素，然后取消订阅另一个。只订阅两个序列中，最先发出元素那个。
 switchLatest: 切换到指定序列订阅，取消上一个订阅，只保留最新订阅的序列
 reduce: 将第一个元素应用一个函数，然后，将结果作为参数填入第二个元素的应用中。直到遍历完完全部的元素后发出结果。
 scan: 将第一个元素应用一个函数，将结果作为第一个元素发出。直到遍历完。
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

example(of: "merge") {
    enum MyError: Error {
        case anError
    }
    
    let subject1 = PublishSubject<String>()
    let subject2 = PublishSubject<String>()
        
    Observable.merge(subject1, subject2)
        .subscribe(onNext: {
            print($0)
        }, onError: {
            print($0)
        })
    
    subject1.onNext("1")
    subject2.onNext("A")
    subject1.onError(MyError.anError)
    subject1.onNext("2")
    subject2.onNext("b")
}

example(of: "combineLatest") {
    enum MyError: Error {
        case anError
    }
    
    let subject1 = PublishSubject<String>()
    let subject2 = PublishSubject<String>()
        
    Observable.combineLatest(subject1.asObservable(),
                             subject2.asObservable(),
                             resultSelector: {
            $0 + $1
        })
        .subscribe(onNext: {
            print($0)
        }, onError: {
            print($0)
        })
    
    subject1.onNext("1")
    subject2.onNext("A")
    subject2.onNext("C")
    subject1.onNext("2")
    subject2.onNext("b")
}

example(of: "zip") {
    let observable1 = Observable.of(1, 2, 3)
    let observable2 = Observable.of(4, 5, 6, 7)
    
    // zip类方法，zip没有实例方法
    Observable.zip([observable1, observable2], resultSelector: { arr in
            arr[0] + arr[1]
        })
        .subscribe(onNext: {
            print($0)
        })
        .dispose()
}

example(of: "withLatestFrom") {
    // eg1:
    let button = PublishSubject<Void>()
    let textfield = PublishSubject<String>()
    
    let observable = button.withLatestFrom(textfield)
    observable.subscribe(onNext: {
        print($0)
    })
    
    textfield.onNext("1")
    textfield.onNext("2")
    textfield.onNext("3")
    textfield.onNext("4")
    button.onNext(())
    button.onNext(())
    
    // button触发textfield发出最新值
    
    // eg2:
    let subject1 = PublishSubject<String>()
    let subject2 = PublishSubject<String>()
    
    subject1.withLatestFrom(subject2, resultSelector: {
            $0 + $1
        })
        .subscribe(onNext: {
            print($0)
        })
    
    subject1.onNext("1")
    subject1.onNext("2")
    subject2.onNext("A")
    subject2.onNext("B")
    subject1.onNext("3")
}

example(of: "amb") {
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    let observable = left.amb(right)
    observable.subscribe(onNext: {
        print($0)
    })
    
    left.onNext("1") // left先发出元素，取消right的订阅
    right.onNext("A")
    left.onNext("2")
    left.onNext("3")
    right.onNext("B")
}

example(of: "switchLatest") {
    let one = PublishSubject<String>()
    let two = PublishSubject<String>()
    let three = PublishSubject<String>()
    
    let source = PublishSubject<Observable<String>>()
    source.switchLatest()
        .subscribe(onNext: {
            print($0)
        })
    
    source.onNext(one)
    one.onNext("1")
    two.onNext("2")
    
    source.onNext(two)
    two.onNext("22")
    one.onNext("11")
    
    source.onNext(three)
    two.onNext("222")
    one.onNext("111")
    three.onNext("333")
    
    source.onNext(one)
    one.onNext("1111")
}

example(of: "reduce") {
    let source = Observable.of(1, 3, 5, 7, 9)
    let observable = source.reduce(0, accumulator: { a, b in
        return a+b
    })
    observable.subscribe(onNext: {
        print($0)
    })
}

example(of: "scan") {
    let source = Observable.of(1, 3, 5, 7, 9)
    let observable = source.scan(0, accumulator: { a, b in
        return a+b
    })
    observable.subscribe(onNext: {
        print($0)
    })
}

example(of: "shareReplay") {
    let source = PublishSubject<Int>()
    
    let observable1 = source.asObserver().share(replay: 3)
    
    source.onNext(1)
    
    observable1
        .subscribe(onNext: {
            print("111")
            print($0)
        })
    
    source.onNext(2)
    
    source.onNext(3)
    
    observable1
        .subscribe(onNext: {
            print("222")
            print($0)
        })
    
    source.onNext(4)
}
