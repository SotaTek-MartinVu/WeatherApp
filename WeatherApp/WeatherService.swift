//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Martin on 21/07/2022.
//

import UIKit

class WeatherService {
    var errorMessage = ""
    //Networking Code
    let decoder = JSONDecoder()
    
    fileprivate func updateResults<T: Decodable>(_ data: Data?, myStruct: T.Type) -> T? {
        decoder.dateDecodingStrategy = .iso8601
        guard let data = data else {
            return nil
        }
        do {
            let rawFeed = try decoder.decode(T.self, from: data)
            return rawFeed
        } catch let decodeError as NSError {
            errorMessage += "Decoder error: \(decodeError.localizedDescription)"
            print(errorMessage)
            return nil
        }
    }
    
    private func baseRequest(url: URL, completion: @escaping (Data?, ServiceError?) -> ()) {
        if !Reachability.isConnectedToNetwork() {
            completion(nil, .internetError)
            return
        }
        URLSession.shared.dataTask(with: url) {(data, response, error ) in
            if error != nil {
                completion(nil, .notFoundData)
            } else {
                completion(data, nil)
            }
            }.resume()
    }
}

extension WeatherService {
    func weatherData(locationStr: String, completion: @escaping (CurrentWeatherData?, ServiceError?) -> ()) {
        
        guard let url = API.locationForecast(locationStr) else { return }
        
        baseRequest(url: url) { data, error in
                if error != nil {
                    completion(nil, error)
                } else {
                    if let forecastWeatherData = self.updateResults(data, myStruct: CurrentWeatherData.self) {
                        completion(forecastWeatherData, nil)
                    } else {
                        completion(nil, .notFoundData)
                    }
                }
        }
    }
    func forecastWeatherData(locationStr: String,
                             completion: @escaping (ForecastWeatherData?, ServiceError?) -> ()) {
        guard let url = API.locationForecast5Days(locationStr) else { return }
        baseRequest(url: url) {(data, error ) in
            if error != nil {
                completion(nil, error)
            } else {
                if let forecastWeatherData = self.updateResults(data, myStruct: ForecastWeatherData.self) {
                    completion(forecastWeatherData, nil)
                } else {
                    completion(nil, .notFoundData)
                }
            }
        }
    }
}

struct ServiceError: Error {
    let message: String
    
    static var notFoundData: ServiceError {
        return ServiceError(message: "Not found Data")
    }
    
    static var internetError: ServiceError {
        return ServiceError(message: "Internet Connection Error")
    }
}

struct API {
    
    //Basic Weather URL
    static func locationForecast(_ locationName: String) -> URL?  {
        
        let apiKey = "5b65ddb2a047b887144cebe79436260f"
        let url = "https://api.openweathermap.org/data/2.5/weather?"
        let query = "q"
        let location = locationName
        
        let key = URLQueryItem(name: "APPID", value: apiKey)
        //MARK: URL EndPoints
        var baseURL = URLComponents(string: url)
        let searchString = URLQueryItem(name: query, value: location)
        
        baseURL?.queryItems?.append(searchString)
        baseURL?.queryItems?.append(key)
        return baseURL?.url
    }
    
    static func locationForecast5Days(_ locationName: String) -> URL?  {
        
        let apiKey = "5b65ddb2a047b887144cebe79436260f"
        let url = "https://api.openweathermap.org/data/2.5/forecast?"
        let query = "q"
        let location = locationName
        
        let key = URLQueryItem(name: "APPID", value: apiKey)
        //MARK: URL EndPoints
        var baseURL = URLComponents(string: url)
        let searchString = URLQueryItem(name: query, value: location)
        
        baseURL?.queryItems?.append(searchString)
        baseURL?.queryItems?.append(key)
        return baseURL?.url
    }
}
