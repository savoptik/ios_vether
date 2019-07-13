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
            self.currantLocation = CLLocation.init(coordinate: coor, altitude: self.locationManager.location!.altitude, horizontalAccuracy: self.locationManager.location!.horizontalAccuracy, verticalAccuracy: self.locationManager.location!.verticalAccuracy, timestamp: self.locationManager.location!.timestamp)
            self.searchTown()
    }
    }

    func searchTown() {
        let startH = Double(self.currantLocation.coordinate.latitude) - 1
        let lasth = (self.currantLocation.coordinate.latitude) + 1
        let startV = Double(self.currantLocation.coordinate.longitude) - 1
        let lastV = Double(self.currantLocation.coordinate.longitude) + 1
        var towns: [CLPlacemark] = []
        var locations: [CLLocation] = []
        for i in stride(from: startV, to: lastV, by: 0.01) {
            for j in stride(from: startH, to: lasth, by: 0.01) {
                locations.append(CLLocation.init(latitude: i, longitude: j))
            }
        }
        let geocoder = CLGeocoder.init()
        let mark = geocoder.reverseGeocodeLocation(locations,
                                                   completionHandler: { (placemarks, error) in
                                                    if error == nil {
                                                        if !towns.contains(placemarks![0]) {
                                                            towns.append(placemarks![0])
                                                        }
                                                    }
        })
        print("Найдено \(towns.count) адресов")
    }

    func coordinateToMapItom() -> CLPlacemark? {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(self.currantLocation,
                                        completionHandler: { (placemarks, error) in
                                            if error == nil {
                                                retMark = placemarks?[0]
                                                print("Текущий город \(retMark?.administrativeArea!)")
                                            }
        })
        self.searchTown()
        return retMark
    }
}

