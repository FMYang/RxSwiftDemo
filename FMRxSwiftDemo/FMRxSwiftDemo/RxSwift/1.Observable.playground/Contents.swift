import UIKit
import RxSwift

/**
 observable: 可观察序列
 observable是一个符合ObservableType协议的类
 
 observable的创建方法，有如下类方法（扩展添加的）：
 just: 创建单个元素的observable序列，元素发射后终止（completed）
 of: 创建observable序列，参数可以是基本数据、数组
 from: 创建observable序列，参数只支持数组，数组元素一个一个发出，对数组降维
 empty: 创建一个空的observable序列，只发射completed事件
 never: 创建一个不发射任何事件并且永不终止的observable序列，可表示无限无限持续的时间
 range: 创建生成一系列值的observable序列
 create: 创建一个序列最灵活的方法，比较常用
 
 just、of、from等自动发射completed事件，create需要手动调用completed发射事件，否则不发射completed事件
 */

public func example(of description: String, action: ()->Void) {
    print("\n--- Example of:", description, "---")
    action()
}

example(of: "subscribe") {
    let disposeBag = DisposeBag()

    let observable = Observable.just(1)
    observable
        .subscribe { event in
            // event
            if let element = event.element {
                print(element)
            }
        }
        .disposed(by: disposeBag)
    
    /**
     Event是个枚举
     @frozen public enum Event<Element> {
         case next(Element)
         case error(Swift.Error)
         case completed
     }
     */
}

example(of: "just") {
    let disposeBag = DisposeBag()
    // Observable与observr是通过subscribe方法关联起来的
    
    // 可观察者Observable，知道内部观察者(observr)是谁，一旦可观察者的值发送变化，
    // 就调用观察者observer的onNext方法将新的值传递给外部观察者（subscribe闭包）
    let observable = Observable.just(1)

    // subscribe()闭包观察Observable的变化
    observable.subscribe(onNext: { e in
        print(e)
    }, onError: { _ in
        print("error")
    }, onCompleted: {
        print("completed")
    })
    .disposed(by: disposeBag)
}

example(of: "of") {
    let disposeBag = DisposeBag()

    let observable = Observable.of(1, 2, 3)

    observable
        .filter({ value in
            return value % 2 != 0
        })
        .subscribe(onNext: { e in
            print(e)
        }, onCompleted: {
            print("completed")
        })
        .disposed(by: disposeBag)
}

example(of: "from") {
    Observable.from([1, 2, 3])
        .subscribe(onNext: {
            print($0)
        })
    
    /*
     from的两种用法
     from返回数组，会将数组的每个元素分开发出，可对数组降维。
     想返回数组又不想降维，可使用from返回可选值，直接返回可选值，或者使用of操作符
    */
    
    var arr: [Int]? = [1, 2, 3]
    Observable.from(optional: arr)
        .subscribe(onNext: {
            print($0)
        })
}

example(of: "empty") {
    let disposeBag = DisposeBag()

    let observable = Observable<Void>.empty()
    observable
        .subscribe(onNext: { e in
            print(e)
        }, onError: { error in
            print("error")
        }, onCompleted: {
            print("completed")
        }, onDisposed: {
            print("disposed")
        })
        .disposed(by: disposeBag)
}

example(of: "never") {
    let disposeBag = DisposeBag()

    let observable = Observable<Void>.never()
    observable
        .subscribe(onNext: { e in
            print(e)
        }, onError: { error in
            print("error")
        }, onCompleted: {
            print("completed")
        }, onDisposed: {
            print("disposed")
        })
        .disposed(by: disposeBag)
}

example(of: "range") {
    let disposeBag = DisposeBag()

    let observable = Observable.range(start: 1, count: 10)
    observable
        .subscribe { event in
            // event
            if let element = event.element {
                print(element)
            }
        }
        .disposed(by: disposeBag)
}

example(of: "create") {
    let disposeBag = DisposeBag()

    let observable = Observable.create { observer in
        observer.onNext("A")
        observer.onNext("B")
        observer.onNext("C")
        observer.onCompleted() // 终止序列
        return Disposables.create()
    }
    observable
        .subscribe { event in
            // event
            if let element = event.element {
                print(element)
            }
        }
        .disposed(by: disposeBag)
    
    // 注意：如果没有调用onCompleted事件，也没有加入disposeBag，这里会产生内存泄漏
}
