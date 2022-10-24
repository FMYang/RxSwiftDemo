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
import CoreLocation

class WeatherViewController: UIViewController {
    
    lazy var contentView: WeatherView = {
        let view = WeatherView()
        return view
    }()
    
    let bag = DisposeBag()
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
        
        let currentLocation = locationManager.rx.didUpdateLocations
            .map { locations in
                return locations[0]
            }
        
        let geoInput = contentView.locationButton.rx.tap.asObservable().do(onNext: {
                self.locationManager.requestWhenInUseAuthorization()
                self.locationManager.startUpdatingLocation()
            })
        
        let geoLocation = geoInput.flatMap {
            return currentLocation.take(1)
        }
        
        let geoSearch = geoLocation.flatMap { location in
            return ApiController.shared.currentWeather(at: location.coordinate)
                .catchAndReturn(ApiController.Weather.empty)
        }

        let searchInput = contentView.searchNameField.rx.controlEvent(.editingDidEndOnExit)
            .asObservable()
            .map { [unowned self] _ in self.contentView.searchNameField.text }
            .filter { ($0 ?? "").count > 0 }
        
        let textSearch = searchInput
            .flatMap { text in
                return ApiController.shared.currentWeather(for: text ?? "Error")
                    .catchAndReturn(ApiController.Weather.empty)
            }
        
        let search = Observable.from([geoSearch, textSearch])
            .merge()
            .asDriver(onErrorJustReturn: ApiController.Weather.empty)
        
        let running = Observable.from([
            searchInput.map { _ in true },
            geoInput.map { _ in true },
            search.map { _ in false }.asObservable()
        ])
            .merge()
            .startWith(true)
            .asDriver(onErrorJustReturn: false)
        
        running
            .skip(1)
            .drive(contentView.activityIndicator.rx.isAnimating)
            .disposed(by: bag)
        
        running
            .drive(contentView.tempLabel.rx.isHidden)
            .disposed(by: bag)
        
        running
            .drive(contentView.iconLabel.rx.isHidden)
            .disposed(by: bag)
        
        running
            .drive(contentView.humidityLabel.rx.isHidden)
            .disposed(by: bag)
        
        running
            .drive(contentView.cityNameLabel.rx.isHidden)
            .disposed(by: bag)
        
        search.map { "\($0.temperature)° C" }
            .drive(contentView.tempLabel.rx.text)
            .disposed(by: bag)
        
        search.map { "\($0.humidity) %" }
            .drive(contentView.humidityLabel.rx.text)
            .disposed(by: bag)
        
        search.map { $0.icon }
            .drive(contentView.iconLabel.rx.text)
            .disposed(by: bag)
        
        search.map { $0.cityName }
            .drive(contentView.cityNameLabel.rx.text)
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
