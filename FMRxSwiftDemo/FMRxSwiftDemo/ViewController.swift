//
//  ViewController.swift
//  FMRxSwiftDemo
//
//  Created by yfm on 2022/10/12.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.text = "-1"
        label.textAlignment = .center
        return label
    }()
    
    lazy var view1: View1 = {
        let view = View1()
        return view
    }()
    
    let disposeBag = DisposeBag()
    let viewModel = ViewModel()
    var i = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        
        let btn = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 40))
        btn.backgroundColor = .gray
        btn.setTitle("Click", for: .normal)
        view.addSubview(btn)
                
        btn.rx.tap.subscribe(onNext:  { [unowned self] in
            print("btn click")
            self.viewModel.str.accept("\(self.i)")
            self.i += 1
        }).disposed(by: disposeBag)
        
        viewModel.str.asObservable().bind(to: textLabel.rx.text).disposed(by: disposeBag)        
    }
    
    private func makeUI() {
        view.addSubview(textLabel)
        view.addSubview(view1)
        textLabel.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.center.equalTo(view)
        }
        
        view1.snp.makeConstraints { make in
            make.top.equalTo(textLabel).offset(10)
            make.left.right.equalTo(view)
            make.height.equalTo(100)
        }
    }
}

