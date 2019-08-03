//
//  WeatherManager.swift
//  ios_vether
//
//  Created by Артём Семёнов on 14/07/2019.
//  Copyright © 2019 Артём Семёнов. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import AFNetworking

/// Объект, запрашивающий погоду для ближайших городов
class WeatherManager {
    /// Список городов
    var cityList: [City] = []
    var colBack: (() -> ())?

    /// Количество хранящихся городов
    public var count: Int {
        get {return self.cityList.count}
    }

    public subscript(index: Int) -> City? {
        get {
            if index < self.cityList.count {
                return self.cityList[index]
            } else {
                return nil
            }
        }
    }

    /// Основной конструктор класса
    /// - Parameter coor: Координаты точки
    /// - Parameter cnt: Количество запрашиваемых городов
    public init(center coor: CLLocationCoordinate2D, numberOfSity cnt: Int) {
        /// Формирование запроса
        guard let apiKeyUrl = Bundle.main.url(forResource: "WeatherMapKey", withExtension: "txt", subdirectory: "Keys") else {
            fatalError("Не удалось получить ключAPI")
        }
        var APIKey = try! String.init(contentsOf:  apiKeyUrl)
        APIKey.remove(at: APIKey.startIndex)
//        APIKey.remove(at: APIKey.endIndex)
        let request = "http://api.openweathermap.org/data/2.5/find?" +
        "lat=" + String(coor.latitude) +
        "&lon=" + String(coor.longitude) +
        "&cnt=" + String(cnt) +
        "&appid=" + APIKey
        // подготовка менеджера запросов
        let manager = AFHTTPSessionManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.get(request, parameters: nil, success: { (URLSessionDataTask, object) in
            if let result = object {
                // разбор сложной структуры
                if let dic = result as? [String: Any] {
                    if let listDic = dic[ParsKeys.list.rawValue] as? [[String: Any]] {
                        for item in listDic {
                            var numErr = 0
                            var coor = CLLocationCoordinate2D()
                            if let coorDic = item[ParsKeys.coord.rawValue] as? [String: Double] {
                                coor = CLLocationCoordinate2D(latitude: coorDic[ParsKeys.lat.rawValue]!, longitude: coorDic[ParsKeys.lon.rawValue]!)
                            } else {
                                NSLog("Не удалось извлечь координаты")
                                numErr += 1
                            }
                            var weather = String()
                            if let weatherDic = item[ParsKeys.weather.rawValue] as? [[String: Any]] {
                                weather = weatherDic[0][ParsKeys.description.rawValue]! as! String
                            } else {
                                NSLog("Не удалось извлечь описание")
                                numErr += 1
                            }
                            var press = 0.0, hum = 0.0
                            var temp: [ParsKeys: Double] = [:]
                            if let main = item[ParsKeys.main.rawValue] as? [String: Double] {
                                hum = main[ParsKeys.humidity.rawValue]!
                                press = main[ParsKeys.pressure.rawValue]!
                                temp[ParsKeys.temp] = main[ParsKeys.temp.rawValue]! - 273.15
                                temp[ParsKeys.temp_max] = main[ParsKeys.temp_max.rawValue]! - 273.15
                                temp[ParsKeys.temp_min] = main[ParsKeys.temp_min.rawValue]! - 273.15
                            } else {
                                NSLog("Не удалось извлечь основные показатели")
                                numErr += 1
                            }
                            var name = String()
                            if let nameString = item[ParsKeys.name.rawValue] as? String {
                                name = nameString
                            } else {
                                NSLog("Не удалось извлечь имя")
                                numErr += 1
                            }
                            var rain = String()
                            if let rainVal = item[ParsKeys.rain.rawValue] as? String {
                                rain = rainVal
                            }
                            var snow = String()
                            if let snowVal = item[ParsKeys.snow.rawValue] as? String {
                                snow = snowVal
                            }
                            var wind: [ParsKeys: Double] = [:]
                            if let windDic = item[ParsKeys.wind.rawValue] as? [String: Double] {
                                wind[ParsKeys.speed] = windDic[ParsKeys.speed.rawValue]!
                                wind[ParsKeys.deg] = windDic[ParsKeys.deg.rawValue]!
                            } else {
                                NSLog("Не удалось извлечь данные о ветре")
                                numErr += 1
                            }
                            if numErr == 0 {
                                self.cityList.append(.init(
                                    name: name,
                                                           rain: rain,
                                                           snow: snow,
                                                           temp: temp,
                                                           pressure: press,
                                                           weather: weather,
                                                           humidity: hum,wind: wind,
                                                           coor: coor
                                    ))
                            } else {
                                NSLog("При попытки обработать данные произошло %d ошибок", numErr)
                            }
                        }
                    } else {
                        NSLog("не удалось извлечь Список из первичного словаря")
                    }
                } else {
                    NSLog("Не удалось преобразовать данные в первичный словарь")
                }
            }
            self.colBack?()
        }, failure: nil)
    }
}

/// Удобная структурка для городов
struct City {
    public let name: String
    public let rain: String
    public let snow: String
    public let temp: [ParsKeys: Double]
    public let pressure: Double
    public let weather: String
    public let humidity: Double
    public let wind: [ParsKeys: Double]
    public let coor: CLLocationCoordinate2D
    public var pin: MKAnnotationView {
        get {
            let pin = MKPointAnnotation.init()
            pin.coordinate = self.coor
            pin.title = self.name
            pin.subtitle = self.weather + " " + String(self.temp[ParsKeys.temp]!)
            pin.isAccessibilityElement = true
            let pinView = MKAnnotationView.init()
            pinView.annotation = pin
            pinView.tintColor = .init(red: 0, green: 255, blue: 0, alpha: 255)
            pinView.isAccessibilityElement = true
            return pinView
        }
    }
    public var weatherMessage: String {
        get {
            var weatherMessage = self.weather + " " + String(self.temp[ParsKeys.temp]!) + "deg.\n"
            if !self.rain.isEmpty && !self.snow.isEmpty {
                weatherMessage += self.rain + " and " + self.snow + ".\n"
            } else if !self.rain.isEmpty {
                weatherMessage += self.rain + ".\n"
            } else if !self.snow.isEmpty {
                weatherMessage += self.snow + ".\n"
            }
            weatherMessage += "temp from" + String(self.temp[ParsKeys.temp_min]!) + " to " + String(self.temp[ParsKeys.temp_max]!) + ".\n"
            weatherMessage += "Wind spid " + String(self.wind[ParsKeys.speed]!) + "m/sec\n"
            weatherMessage += "humidity " + String(self.humidity) + ", pressure" + String(self.pressure) + ".\n"
            return weatherMessage
        }
    }
}

enum ParsKeys: String {
    case list = "list"
    case rain = "rain"
    case snow = "snow"
    case weather = "weather"
    case description = "description"
    case name = "name"
    case main = "main"
    case humidity = "humidity"
    case pressure = "pressure"
    case temp = "temp"
    case temp_max = "temp_max"
    case temp_min = "temp_min"
    case coord = "coord"
    case lat = "lat"
    case lon = "lon"
    case wind = "wind"
    case deg = "deg"
    case speed = "speed"
}
