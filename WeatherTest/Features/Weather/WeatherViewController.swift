//
//  WeatherViewController.swift
//  WeatherTest
//
//  Created by liuguangde on 2021/2/27.
//

import UIKit
import CoreSpotlight
import MobileCoreServices

class WeatherViewController: UIViewController {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var forecastsStackView: UIStackView!
    @IBOutlet weak var forecastsViewWidthCtr: NSLayoutConstraint!
    
    let identifier = "WeatherIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = WeatherViewModel()
        viewModel?.startLocationService()
    }
    
    
    @IBAction func refreshTapped(_ sender: Any) {
        viewModel?.startLocationService()
    }
    
    //MARK: ViewModel
    var viewModel: WeatherViewModel? {
        didSet {
            setLocationLabel()
            viewModel?.iconText.observe {
                [unowned self] in
                self.iconLabel.text = $0
            }
            viewModel?.temperature.observe {
                [unowned self] in
                self.temperatureLabel.text = $0
            }
            setForcastView()
        }
    }
    
    
    //MARK: Private Functions
    private func setLocationLabel() {
        viewModel?.location.observe {
            [unowned self] in
            self.locationLabel.text = $0
            
            let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
            attributeSet.title = self.locationLabel.text
            
            let item = CSSearchableItem(uniqueIdentifier: self.identifier, domainIdentifier: "com.rushjet.SwiftWeather", attributeSet: attributeSet)
            CSSearchableIndex.default().indexSearchableItems([item]){error in
                if let error =  error {
                    print("Indexing error: \(error.localizedDescription)")
                } else {
                    print("Location item successfully indexed")
                }
            }
        }
    }
    
    private func setForcastView() {
        viewModel?.forecasts.observe {
            [unowned self] (forecastViewModels) in
            self.clearForecastViews()
            if forecastViewModels.count >= 0 {
                for (_, viewModel) in forecastViewModels.enumerated() {
                    let forecastView = ForecastView()
                    forecastView.loadViewModel(viewModel)
                    self.forecastsStackView.addArrangedSubview(forecastView)
                }
            }
            self.forecastsViewWidthCtr.constant = CGFloat(forecastViewModels.count * 100)
        }
    }
    
    private func clearForecastViews() {
        let svs = self.forecastsStackView.subviews
        if svs.count > 0 {
            for (_, v) in svs.enumerated() {
                v.removeFromSuperview()
            }
        }
    }
    
}
