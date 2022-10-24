//
//  WeatherViewController.swift
//  Wundercast_MVVM
//
//  Created by yfm on 2022/10/20.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import CoreLocation

class WeatherViewController: UIViewController {
    lazy var contentView: WeatherView = {
        let view = WeatherView()
        return view
    }()
    
    let viewModel = WeatherViewModel()
    let locationManager = CLLocationManager()
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()

        bindViewModel()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func bindViewModel() {
        let searchInput = contentView.searchNameField.rx.controlEvent(.editingDidEndOnExit)
            .asObservable()
            .map { _ in
                return self.contentView.searchNameField.text ?? ""
            }
            .filter { $0.count > 0 }
        
        let currentLocation = locationManager.rx.didUpdateLocations
            .map { locations in
                return locations[0]
            }
        
        let geoInput = contentView.locationButton.rx.tap.asObservable().do(onNext: {
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
        })
                
        let geoLocation = geoInput
            .flatMap {
                return currentLocation.take(1)
            }

        let input = WeatherViewModel.Input(textInput: searchInput,
                                           geoInput: geoInput,
                                           geoLocation: geoLocation)
        
        let output = viewModel.transform(input: input)
        
        output.weather.map { "\($0.temperature)° C" }
            .drive(contentView.tempLabel.rx.text)
            .disposed(by: bag)
        
        output.weather.map { "\($0.humidity) %" }
            .drive(contentView.humidityLabel.rx.text)
            .disposed(by: bag)
        
        output.weather.map { $0.cityName }
            .drive(contentView.cityNameLabel.rx.text)
            .disposed(by: bag)
        
        output.weather.map { $0.icon }
            .drive(contentView.iconLabel.rx.text)
            .disposed(by: bag)
        
        output.running
            .skip(1)
            .drive(contentView.activityIndicator.rx.isAnimating)
            .disposed(by: bag)
        
        output.running
            .drive(contentView.tempLabel.rx.isHidden)
            .disposed(by: bag)
        
        output.running
            .drive(contentView.humidityLabel.rx.isHidden)
            .disposed(by: bag)
        
        output.running
            .drive(contentView.iconLabel.rx.isHidden)
            .disposed(by: bag)
        
        output.running
            .drive(contentView.cityNameLabel.rx.isHidden)
            .disposed(by: bag)
    }
    
    private func makeUI() {
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
}
