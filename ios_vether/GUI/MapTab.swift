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
            self.coordinateToMapItom()
    }
    }

    func searchTown() {
            let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "город"
        request.region = MKCoordinateRegion.init(center: self.currantLocation.coordinate, span: .init(latitudeDelta: 0.5, longitudeDelta: 0.5))
            let search = MKLocalSearch(request: request)
        search.start(completionHandler: { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
        })
        print("Количество найденных городов \(self.matchingItems.count)")
    }

    func coordinateToMapItom() -> CLPlacemark? {
        let geocoder = CLGeocoder()
        var retMark: CLPlacemark?
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

