//
//  MapTab.swift
//  ios_vether
//
//  Created by Артём Семёнов on 11.07.2019.
//  Copyright © 2019 Артём Семёнов. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapTab: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    let mapView = MKMapView.init()

    var locationManager = CLLocationManager()
    var matchingItems: [MKMapItem] = []
    var currantLocation = CLLocation.init()
    let searchQueueName = "search queue"
    let searchQueue: DispatchQueue = {
        let searchQueue = DispatchQueue.init(label: "search queue")
        return searchQueue
    }()
    let  myGroup = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.mapView)
        let constr = [self.view.safeAreaLayoutGuide.topAnchor.constraint(equalToSystemSpacingBelow: self.mapView.topAnchor, multiplier: 1), self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: self.mapView.bottomAnchor, multiplier: 1), self.view.safeAreaLayoutGuide.leftAnchor.constraint(equalToSystemSpacingAfter: self.mapView.leftAnchor, multiplier: 1), self.view.safeAreaLayoutGuide.rightAnchor.constraint(equalToSystemSpacingAfter: self.mapView.rightAnchor, multiplier: 1)] // задаём размеры
        NSLayoutConstraint.activate(constr) // расчитываем констрейны
        if  CLLocationManager.locationServicesEnabled() {
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingHeading()
        }
        self.mapView.delegate = self
        self.mapView.mapType = .standard
        self.mapView.isZoomEnabled = true
        self.mapView.isScrollEnabled = true
        if let coor = self.locationManager.location?.coordinate {
            let regen = MKCoordinateRegion.init(center: coor, span: .init(latitudeDelta: 0.5, longitudeDelta: 0.5))
            mapView.setCenter(coor, animated: true)
            self.mapView.setRegion(regen, animated: true)
            let centerPin = MKPointAnnotation.init()
            centerPin.coordinate = coor
            centerPin.title = NSLocalizedString("Change localisation", comment: "")
            centerPin.isAccessibilityElement = true
            self.mapView.addAnnotation(centerPin)
            self.currantLocation = CLLocation.init(latitude: coor.latitude, longitude: coor.longitude)
            self.searchQueue.sync {
                self.searchTowns(location: self.currantLocation)
            }
            print("итого \(self.matchingItems.count)")
    }
    }

    func searchPostal(mark: CLPlacemark) {
            let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = "34"
        let region = MKCoordinateRegion.init(center: self.currantLocation.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
            searchRequest.region = region
        let localSearch = MKLocalSearch(request: searchRequest)
        localSearch.start { (response, error) in
            self.searchQueue.sync {
                self.myGroup.enter()
                guard error == nil else {
                    self.myGroup.leave()
                    return
                }
                let timeList = response!.mapItems
                for it in timeList {
                    if Double(it.placemark.coordinate.latitude) >= Double(self.currantLocation.coordinate.latitude) - 5 {
                        if Double(it.placemark.coordinate.latitude) <= Double(self.currantLocation.coordinate.latitude) + 5 {
                            if Double(it.placemark.coordinate.longitude) >= Double(self.currantLocation.coordinate.longitude) - 5 {
                                if Double(it.placemark.coordinate.longitude) <= Double(self.currantLocation.coordinate.longitude) + 5 {
                                    let semaphore = DispatchSemaphore(value: 1)
                                    var flag = 0
                                    DispatchQueue.global().async {
                                        semaphore.wait()
                                        
                                        for s in self.matchingItems {
                                            if let hs = s.placemark.postalCode {
                                                if let ts = it.placemark.postalCode {
                                                    if ts == hs {
                                                        print("\(ts)")
                                                        flag = 1
                                                    }
                                                } else {
                                                    flag = 1
                                                }
                                            } else {
                                                flag += 1
                                            }
                                        }
                                        
                                        if flag == 0 {
                                            self.matchingItems.append(it)
                                        }
                                        
                                        semaphore.signal()
                                        self.searchQueue.sync {self.searchPostal(mark: it.placemark)}
                                    }
                                }
                            }
                        }
                    }
                }
                print("в основном массиве \(self.matchingItems.count) элементов")
                self.myGroup.leave()
            }
        }
    }

    func searchTowns(location: CLLocation){
        let geocoder = CLGeocoder()
        var retMark: CLPlacemark?
        geocoder.reverseGeocodeLocation(self.currantLocation,
                                        completionHandler: { (placemarks, error) in self.searchQueue.async {
                                            if error == nil {
                                                retMark = placemarks?[0]
                                            }
                                            self.searchQueue.sync {
                                                self.searchPostal(mark: retMark!)
                                            }
                                        }
                                            print("итого \(self.matchingItems.count)")
        })
    }
}

