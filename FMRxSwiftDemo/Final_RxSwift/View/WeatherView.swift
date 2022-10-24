//
//  WeatherView.swift
//  Wundercast_MVVM
//
//  Created by yfm on 2022/10/20.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class WeatherView: UIView {
    lazy var searchNameField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "City's Name",attributes: [.foregroundColor: UIColor.textGrey])
        textField.font = UIFont.boldSystemFont(ofSize: 32)
        textField.textAlignment = .center
        textField.returnKeyType = .search
        return textField
    }()
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ufoGreen
        return view
    }()
    
    lazy var tempLabel: UILabel = {
        let label = UILabel()
        label.text = "T"
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 24)
        return label
    }()
    
    lazy var humidityLabel: UILabel = {
        let label = UILabel()
        label.text = "H"
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = .black
        return label
    }()
    
    lazy var iconLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Flaticon", size: 220.0)
        label.text = "W"
        label.textAlignment = .center
        return label
    }()
    
    lazy var cityNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        label.text = "City"
        label.textAlignment = .center
        return label
    }()
    
    lazy var locationButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "place-location"), for: .normal)
        btn.setTitle("", for: .normal)
        return btn
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.color = .white
        return view
    }()
    
    let bag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .red
        makeUI()
        style()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeUI() {
        addSubview(searchNameField)
        searchNameField.addSubview(lineView)
        addSubview(tempLabel)
        addSubview(humidityLabel)
        addSubview(iconLabel)
        addSubview(cityNameLabel)
        addSubview(locationButton)
        addSubview(activityIndicator)
        
        searchNameField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(40)
            make.height.equalTo(60)
        }
        
        lineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-1)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        iconLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(311)
        }
        
        tempLabel.snp.makeConstraints { make in
            make.left.equalTo(iconLabel)
            make.bottom.equalTo(iconLabel.snp.top).offset(-8)
        }
        
        humidityLabel.snp.makeConstraints { make in
            make.right.equalTo(iconLabel.snp.right)
            make.bottom.equalTo(iconLabel.snp.top).offset(-8)
        }
        
        cityNameLabel.snp.makeConstraints { make in
            make.centerX.equalTo(iconLabel)
            make.width.equalTo(iconLabel)
            make.top.equalTo(iconLabel.snp.bottom).offset(8)
        }
        
        locationButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-50)
            make.width.height.equalTo(44)
            make.left.equalToSuperview().offset(20)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(40)
        }
    }
    
    private func style() {
        self.backgroundColor = UIColor.aztec
        searchNameField.textColor = UIColor.ufoGreen
        tempLabel.textColor = UIColor.cream
        humidityLabel.textColor = UIColor.cream
        iconLabel.textColor = UIColor.cream
        cityNameLabel.textColor = UIColor.cream
    }
}
