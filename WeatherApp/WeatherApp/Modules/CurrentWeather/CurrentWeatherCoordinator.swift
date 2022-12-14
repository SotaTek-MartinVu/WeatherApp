//
//  CurrentWeatherCoordinator.swift
//  WeatherApp
//
//  Created by Martin on 26/07/2022.
//

import UIKit

class CurrentWeatherCoordinator: Coordinator {
    private weak var window: UIWindow?
    private var navController: UINavigationController
    private var currentCoordinator: Coordinator?
    
    init( window: UIWindow?,
          navController: UINavigationController) {
        self.window = window
        self.navController = navController
    }
    
    func start(data: Any? = nil) {
        let currentWeatherView = CurrentWeatherViewController(nibName: "CurrentWeatherViewController", bundle: nil)
        let currentWeatherModel = CurrentWeatherModel()
        let presenter = CurrentWeatherPresenter(model: currentWeatherModel, view: currentWeatherView, coordinator: self)
        currentWeatherView.set(presenter: presenter)
        navController.setViewControllers([currentWeatherView], animated: true)
        window?.rootViewController = self.navController
        window?.makeKeyAndVisible()
    }
    
    func navigateToInputForecast(cityName: String) {
        let foreCastWeatherCoordinator = ForeCastWeatherCoordinator(parent: self, navController: navController)
        foreCastWeatherCoordinator.start(data: cityName)
    }
}
