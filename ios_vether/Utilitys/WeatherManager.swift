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
            
        "&appid=89cf20101dbb351566d4bfd30eccc045"
        print(request)
        // подготовка менеджера запросов
        let manager = AFHTTPSessionManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.get(request, parameters: nil, success: { (URLSessionDataTask, object) in
            if let result = object {
                print(result)
            }
        }, failure: nil)
    }
}

/// Удобная структурка для городов
struct City {
    public let name: String
    public let weather: String
}
