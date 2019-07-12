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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.mapView)
        let constr = [self.view.safeAreaLayoutGuide.topAnchor.constraint(equalToSystemSpacingBelow: self.mapView.topAnchor, multiplier: 1), self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: self.mapView.bottomAnchor, multiplier: 1), self.view.safeAreaLayoutGuide.leftAnchor.constraint(equalToSystemSpacingAfter: self.mapView.leftAnchor, multiplier: 1), self.view.safeAreaLayoutGuide.rightAnchor.constraint(equalToSystemSpacingAfter: self.mapView.rightAnchor, multiplier: 1)] // задаём размеры
        NSLayoutConstraint.activate(constr) // расчитываем констрейны
        print("test 1")
        if  CLLocationManager.locationServicesEnabled() {
            print("test 2")
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingHeading()
            print("test 3")
        }
        self.mapView.delegate = self
        self.mapView.mapType = .standard
        self.mapView.isZoomEnabled = true
        self.mapView.isScrollEnabled = true
        print("\(self.mapView.userLocation.isUpdating)")
        if let coor = self.locationManager.location?.coordinate {
            print("test 4")
            let regen = MKCoordinateRegion.init(center: coor, span: .init(latitudeDelta: 0.5, longitudeDelta: 0.5))
            mapView.setCenter(coor, animated: true)
            self.mapView.setRegion(regen, animated: true)
            let centerPin = MKPointAnnotation.init()
            centerPin.coordinate = coor
            centerPin.title = NSLocalizedString("Change localisation", comment: "")
            centerPin.isAccessibilityElement = true
            self.mapView.addAnnotation(centerPin)
                let geocoder = CLGeocoder()
                geocoder.reverseGeocodeLocation(self.locationManager.location!,
                                                completionHandler: { (placemarks, error) in
                                                    if error == nil {
                                                        let firstLocation = placemarks?[0]
                                                        print("\(firstLocation)")
                                                    }
                })
            self.searchTown()
            for it in self.matchingItems {
                print("\(it.name!)")
            }
            print("\(self.matchingItems.count)")
    }
    }

    func searchTown() {
        print("test 5")
            let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "city"
        request.region = self.mapView.region
            let search = MKLocalSearch(request: request)
        search.start(completionHandler: { response, _ in
            guard let response = response else {
                return
            }
            print("test 6")
            self.matchingItems = response.mapItems
        })
    }
    
}
