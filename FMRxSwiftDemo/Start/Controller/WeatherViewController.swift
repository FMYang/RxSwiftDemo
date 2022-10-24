//
//  WeatherViewController.swift
//  Start
//
//  Created by yfm on 2022/10/21.
//

import UIKit
import SnapKit

class WeatherViewController: UIViewController {
    
    lazy var contentView: WeatherView = {
        let view = WeatherView()
        return view
    }()
    
    private var running: Bool? {
        didSet {
            if let value = running, value {
                self.contentView.activityIndicator.startAnimating()
                self.contentView.tempLabel.isHidden = true
                self.contentView.humidityLabel.isHidden = true
                self.contentView.cityNameLabel.isHidden = true
                self.contentView.iconLabel.isHidden = true
            } else {
                self.contentView.activityIndicator.stopAnimating()
                self.contentView.tempLabel.isHidden = false
                self.contentView.humidityLabel.isHidden = false
                self.contentView.cityNameLabel.isHidden = false
                self.contentView.iconLabel.isHidden = false
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
                
        self.contentView.searchNameField.delegate = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func fetchData(text: String) {
        self.running = true
        DispatchQueue.global(qos: .background).asyncAfter(deadline: DispatchTime.now() + 2, execute: {
            ApiController.shared.currentWeather(for: text, success: { [weak self] weather in
                DispatchQueue.main.async {
                    self?.contentView.tempLabel.text = "\(weather.temperature)° C"
                    self?.contentView.humidityLabel.text = "\(weather.humidity) %"
                    self?.contentView.cityNameLabel.text = weather.cityName
                    self?.contentView.iconLabel.text = weather.icon
                    self?.running = false
                }
            }, fail: { [weak self] err in
                DispatchQueue.main.async {
                    self?.running = false
                    print(err ?? "Unkonw Error")
                }
            })
        })
    }

    private func makeUI() {
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
}

extension WeatherViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if (textField.text ?? "").count > 0 {
            self.fetchData(text: textField.text ?? "")
        }
        return true
    }
}
