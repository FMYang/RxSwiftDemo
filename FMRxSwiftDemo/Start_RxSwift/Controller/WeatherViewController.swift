//
//  WeatherViewController.swift
//  Start
//
//  Created by yfm on 2022/10/21.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class WeatherViewController: UIViewController {
    
    lazy var contentView: WeatherView = {
        let view = WeatherView()
        return view
    }()
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
                
        
        let textInput = self.contentView.searchNameField.rx.controlEvent(.editingDidEndOnExit)
            .map { [unowned self] _ in self.contentView.searchNameField.text }
            .filter { text in
                return (text ?? "").count > 0
            }

        let search = textInput.asObservable()
            .flatMap { text in
                // 请求数据
                ApiController.shared.currentWeather(for: text ?? "Error")
                    .catchAndReturn(ApiController.Weather.empty)
            }

        let running = Observable.from(
            [textInput.map { _ in return true },
             search
                .delay(.seconds(2), scheduler: MainScheduler.instance)
                .map { _ in return false }.asObservable()
            ])
            .merge()
            .startWith(true)
            .asDriver(onErrorJustReturn: false)
//
//        search
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] weather in
//                self?.contentView.tempLabel.text = "\(weather.temperature)° C"
//                self?.contentView.humidityLabel.text = "\(weather.humidity) %"
//                self?.contentView.cityNameLabel.text = weather.cityName
//                self?.contentView.iconLabel.text = weather.icon
//            })
//            .disposed(by: bag)
//
        running
            .skip(1)
            .drive(self.contentView.activityIndicator.rx.isAnimating)
            .disposed(by: bag)

        running
            .drive(self.contentView.tempLabel.rx.isHidden)
            .disposed(by: bag)
        running
            .drive(self.contentView.humidityLabel.rx.isHidden)
            .disposed(by: bag)
        running
            .drive(self.contentView.cityNameLabel.rx.isHidden)
            .disposed(by: bag)
        running
            .drive(self.contentView.iconLabel.rx.isHidden)
            .disposed(by: bag)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func makeUI() {
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
}
