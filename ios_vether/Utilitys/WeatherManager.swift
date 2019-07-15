//
//  WeatherManager.swift
//  ios_vether
//
//  Created by Артём Семёнов on 14/07/2019.
//  Copyright © 2019 Артём Семёнов. All rights reserved.
//

import Foundation
import CoreLocation
import AFNetworking

/// Объект, запрашивающий погоду для ближайших городов
class WeatherManager {
    /// Список городов
    private var cityList: [City] = []

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
        let request = "http://api.openweathermap.org/data/2.5/find?" +
        "lat=" + String(coor.latitude) +
        "&lon=" + String(coor.longitude) +
        "&cnt=" + String(cnt) +
        "&appid=" + "89cf20101dbb351566d4bfd30eccc045"
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
        }, failure: nil)
    }
}

/// Удобная структурка для городов
struct City {
    public let name: String
    public let rain: String?
    public let snow: String?
    public let temp: [ParsKeys: Double]
    public let pressure: Double
    public let weather: String
    public let humidity: Double
    public let wind: [ParsKeys: Double]
    public let coor: CLLocationCoordinate2D
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
