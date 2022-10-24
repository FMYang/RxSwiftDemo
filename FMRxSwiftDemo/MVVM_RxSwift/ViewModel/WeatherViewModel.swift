//
//  WeatherViewModel.swift
//  Wundercast_MVVM
//
//  Created by yfm on 2022/10/20.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

class WeatherViewModel: NSObject {
    /// The api key to communicate with openweathermap.org
    /// Create you own on https://home.openweathermap.org/users/sign_up
    private let apiKey = "ac7e688ab325ca558430b1d61b6b145d"
    
    /// API base URL
    let baseURL = URL(string: "http://api.openweathermap.org/data/2.5")!
    
    struct Input {
        let textInput: Observable<String>
        let geoInput: Observable<Void>
        let geoLocation: Observable<CLLocation>
    }
    
    struct Output {
        let weather: Driver<Weather>
        let running: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        let textOutput = input.textInput
            .flatMap { [unowned self] text in
                return self.currentWeather(for: text)
                    .catchAndReturn(Weather.empty)
            }
        
        let geoOutput = input.geoLocation
            .flatMap { [unowned self] location in
                return self.currentWeather(at: location.coordinate)
                    .catchAndReturn(Weather.empty)
            }
        
        let searchOuput = Observable.from([textOutput, geoOutput])
            .merge()
            .asDriver(onErrorJustReturn: Weather.empty)
        
        let running = Observable.from([
                input.textInput.map { _ in true },
                input.geoInput.map { _ in true },
                searchOuput.map { _ in false}.asObservable()
            ])
            .merge()
            .startWith(true)
            .asDriver(onErrorJustReturn: false)
        
        return Output(weather: searchOuput, running: running)
    }
}

// MARK: - Api Calls
extension WeatherViewModel {
    func currentWeather(for city: String) -> Observable<Weather> {
        buildRequest(pathComponent: "weather", params: [("q", city)])
            .map { data in
                try JSONDecoder().decode(Weather.self, from: data)
            }
    }
    
    func currentWeather(at coordinate: CLLocationCoordinate2D) -> Observable<Weather> {
        buildRequest(pathComponent: "weather",
                     params: [("lat", "\(coordinate.latitude)"),
                              ("lon", "\(coordinate.longitude)")])
        .map { data in
            try JSONDecoder().decode(Weather.self, from: data)
        }
    }
    
    
    // MARK: - Private Methods
    
    /**
     * Private method to build a request with RxCocoa
     */
    private func buildRequest(method: String = "GET", pathComponent: String, params: [(String, String)]) -> Observable<Data> {
        let url = baseURL.appendingPathComponent(pathComponent)
        var request = URLRequest(url: url)
        let keyQueryItem = URLQueryItem(name: "appid", value: apiKey)
        let unitsQueryItem = URLQueryItem(name: "units", value: "metric")
        let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        if method == "GET" {
            var queryItems = params.map { URLQueryItem(name: $0.0, value: $0.1) }
            queryItems.append(keyQueryItem)
            queryItems.append(unitsQueryItem)
            urlComponents.queryItems = queryItems
        } else {
            urlComponents.queryItems = [keyQueryItem, unitsQueryItem]
            
            let jsonData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            request.httpBody = jsonData
        }
        
        request.url = urlComponents.url!
        request.httpMethod = method
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        
        return session.rx.data(request: request)
    }
}
