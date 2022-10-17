import UIKit
import RxSwift

/**
 转换操作符
 toArray: 将序列转为数组序列
 map: 将可观察序列的每个元素应用转换函数，转换为一个新的序列，可转换类型
 flatMap: 将可观察序列发射的元素转换为可观察序列，并将两个可观察序列的发射合并为一个可观察序列
 flatMapLatest: 与flatMap不同的是，flatMapLatest会自动切换到最新的observable，取消上一个订阅
 materialize: 将序列产生的事件转换成元素，新的序列为事件序列
 dematerialize: 将事件序列转换为元素序列，是materialize的逆操作
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

// flatMap模拟网络请求
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
            let tmp = arr.map { $0+"0" }
            return Observable.from(tmp)
        }
        .subscribe(onNext: {
            print($0)
        })
}

example(of: "flatMap_1") {
    struct Student {
        var score: BehaviorSubject<Int>
    }
    
    let disposeBag = DisposeBag()
    
    let lucy = Student(score: BehaviorSubject(value: 80))
    let jack = Student(score: BehaviorSubject(value: 90))
    
    let student = PublishSubject<Student>()
    
    student
        .flatMap {
            $0.score
        }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
        
    student.onNext(lucy) // 80
    lucy.score.onNext(85) // 85
    student.onNext(jack) // 90
    lucy.score.onNext(95) // 95
    jack.score.onNext(100) // 100
    
    /**
     输出：
     80
     85
     90
     95
     100
     */

}

example(of: "flatMapLatest") {
    struct Student {
        var score: BehaviorSubject<Int>
    }
    
    let disposeBag = DisposeBag()
    
    let lucy = Student(score: BehaviorSubject(value: 80))
    let jack = Student(score: BehaviorSubject(value: 90))
    
    let student = PublishSubject<Student>()
    
    student
        .flatMapLatest {
            $0.score
        }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
        
    student.onNext(lucy) // 80
    lucy.score.onNext(85) // 85
    student.onNext(jack) // 90
    /*
     使用flatMapLatest后，这里更改lucy的分数不会有任何影响，
     因为flatMapLatest已经切换到jack的最新observable
     */
    lucy.score.onNext(95) // 95
    jack.score.onNext(100) // 100
    
    /**
     输出：
     80
     85
     90
     100
     */
}

example(of: "materialize and dematerialize") {
    enum MyError: Error {
        case anError
    }
    
    struct Student {
        var score: BehaviorSubject<Int>
    }
    
    let disposeBag = DisposeBag()
    
    let lucy = Student(score: BehaviorSubject(value: 80))
    let jack = Student(score: BehaviorSubject(value: 100))
    
    let student = BehaviorSubject(value: lucy)
    
    let studentScore = student
        .flatMapLatest {
            $0.score.materialize() // 将序列产生的事件转换成元素
        }
    
    studentScore
        .filter {
            guard $0.error == nil else {
                print($0.error!)
                return false
            }
            return true
        }
        .dematerialize()
        .subscribe(onNext: {
            print($0)
        }, onError: {
            print($0)
        })
    
    lucy.score.onNext(85) // 85
    lucy.score.onError(MyError.anError)
    lucy.score.onNext(90)
    student.onNext(jack)
}
