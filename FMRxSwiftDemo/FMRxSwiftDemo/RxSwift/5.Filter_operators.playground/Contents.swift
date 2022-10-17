import UIKit
import RxSwift

/**
 过滤操作符
 ignoreElements: 忽略所有next事件
 elementAt(at index): 忽略索引之外的全部事件，例如index=1，发出1，2，3，则只有所有为1的next(2)事件通过
 filter: 接收一个返回Bool值的闭包返回，通过条件为true的事件，忽略条件为false的事件
 skip(count): 跳过count个事件，例如，发出1，2，3，skip(1)，则next(1)事件被忽略，之后的事件通过
 skipWhile: 接收一个返回Bool值的闭包，跳过条件为false的事件，直到条件为ture，之后的事件全部通过
 skipUtil: 接收一个符合ObservableType协议参数source，忽略source发射next事件之前的所有事件，接收source.next之后所有事件
 take(count): 获取count个事件，count之后的事件忽略
 takeWhile: 接收一个返回Bool值的闭包，通过条件为ture的事件，忽略条件为ture之后的所有事件
 takeUtil: 接收一个符合ObservableType协议参数source，获取source发射next事件之前的所有事件，忽略source.next之后所有事件
 distinctUntilChanged: 忽略连续重复的事件
 distinctUntilChanged(comparer:): 自定义过滤条件
 */

public func example(of description: String, action: ()->Void) {
    print("\n--- Example of:", description, "---")
    action()
}

example(of: "ignoreElements") {
    let subject = PublishSubject<Int>()
    
    subject
        .ignoreElements()
        .subscribe(onNext: { e in
            print(e)
        }, onCompleted: {
            print("completed")
        })
    
    subject.onNext(1)
    subject.onNext(2)
    subject.onNext(3)
    subject.onCompleted()
}

example(of: "elementAt") {
    let subject = PublishSubject<Int>()
    
    subject
        .element(at: 1)
        .subscribe(onNext: { e in
            print(e)
        }, onCompleted: {
            print("completed")
        })
    
    subject.onNext(1)
    subject.onNext(2)
    subject.onNext(3)
    subject.onCompleted()

}

example(of: "filter") {
    Observable.of(1, 2, 3)
        .filter {
            return $0 % 2 == 0
        }
        .subscribe(onNext: {
            print($0)
        }, onCompleted: {
            print("completed")
        })
        .dispose()
}

example(of: "skip") {
    Observable.of(1, 2, 3)
        .skip(1)
        .subscribe(onNext: {
            print($0)
        }, onCompleted: {
            print("completed")
        })
        .dispose()
}

example(of: "skipWhile") {
    let disposeBag = DisposeBag()
    
    Observable.of(2, 2, 3, 4, 4)
        .skip(while: {
            return $0 % 2 == 0
        })
        .subscribe(onNext: {
            print($0)
        }, onCompleted: {
            print("completed")
        })
        .disposed(by: disposeBag)
}

// 上面都是过滤一些静态条件，skipUtil可过滤动态条件
example(of: "skipUtil") {
    let disposeBag = DisposeBag()

    let subject = PublishSubject<Int>()
    let trigger = PublishSubject<Int>()
    
    subject
        .skip(until: trigger)
        .subscribe(onNext: {
            print($0)
        }, onCompleted: {
            print("completed")
        })
        .disposed(by: disposeBag)
    
    subject.onNext(1)
    subject.onNext(2)
    trigger.onNext(3) // trigger发射next事件
    subject.onNext(4)
    
    subject.onCompleted()
}

example(of: "take") {
    Observable.of(1, 2, 3)
        .take(1)
        .subscribe(onNext: {
            print($0)
        }, onCompleted: {
            print("completed")
        })
        .dispose()
}

example(of: "takeWhile") {
    Observable.of(2, 2, 3, 4, 4)
        .enumerated() // 枚举元素，获取元素的索引和值
        .take(while: { (index, element) in
            return element % 2 == 0 && index < 2
        })
        .map { $0.element }
        .subscribe(onNext: {
            print($0)
        }, onCompleted: {
            print("completed")
        })
        .dispose()
}

example(of: "takeUtil") {
    let disposeBag = DisposeBag()

    let subject = PublishSubject<Int>()
    let trigger = PublishSubject<Int>()
    
    subject
        .take(until: trigger)
        .subscribe(onNext: {
            print($0)
        }, onCompleted: {
            print("completed")
        })
        .disposed(by: disposeBag)
    
    subject.onNext(1)
    subject.onNext(2)
    trigger.onNext(3) // trigger发射next事件
    subject.onNext(4)
    
    subject.onCompleted()
}

example(of: "distinctUntilChanged") {
    Observable.of(2, 2, 2, 3, 4, 4)
        .distinctUntilChanged()
        .subscribe(onNext: {
            print($0)
        }, onCompleted: {
            print("completed")
        })
        .dispose()
}

example(of: "distinctUntilChanged(:)") {
    Observable.of(2, 2, 3, 4, 5, 6, 8, 8)
        .distinctUntilChanged({ a, b in
//            return a == b // 这个条件与distinctUntilChanged一样，过滤连续重复的元素
            return a != b // 自定义条件，过滤下一个值不等于上一个值的所有元素，连续重复的元素通过
        })
        .subscribe(onNext: {
            print($0)
        }, onCompleted: {
            print("completed")
        })
        .dispose()
}
