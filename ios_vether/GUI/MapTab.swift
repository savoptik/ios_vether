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
    var currentPlaceMark: CLPlacemark?
    var weathers: [City] = []

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
        self.mapView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.touch(sender:))))
        if let coor = self.locationManager.location?.coordinate {
            self.toPlacePins(coor: coor)
        } else {
            self.toPlacePins(coor: .init(latitude: 47.3, longitude: 39.74))
        }
    }

    func searchTowns(location: CLLocation){
        let geocoder = CLGeocoder()
        var retMark: CLPlacemark?
        geocoder.reverseGeocodeLocation(self.currantLocation,
                                        completionHandler: { (placemarks, error) in
                                            if error == nil {
                                                self.currentPlaceMark = placemarks?[0]
                                            }
        })
    }

    func toPlacePins(coor: CLLocationCoordinate2D) {
        let regen = MKCoordinateRegion.init(center: coor, span: .init(latitudeDelta: 0.5, longitudeDelta: 0.5))
        mapView.setCenter(coor, animated: true)
        self.mapView.setRegion(regen, animated: true)
        let centerPin = MKPointAnnotation.init()
        centerPin.coordinate = coor
        centerPin.title = NSLocalizedString("Change localisation", comment: "")
        centerPin.isAccessibilityElement = true
        self.mapView.addAnnotation(centerPin)
        self.currantLocation = CLLocation.init(latitude: coor.latitude, longitude: coor.longitude)
/*        let sityAdnWeather = WeatherManager.init(center: coor, numberOfSity: 20)
        sityAdnWeather.colBack = {
            self.weathers = sityAdnWeather.cityList
            for it in sityAdnWeather.cityList {
                self.mapView.addAnnotation(it.pin.annotation!)            }
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.weatherList = sityAdnWeather.cityList
        } */
        }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let textView: String = {
            var str = String()
            for it in self.weathers {
                if (it.coor.latitude == view.annotation!.coordinate.latitude) && (it.coor.longitude == view.annotation!.coordinate.longitude) {
                    str = it.weatherMessage
                }
            }
            return str
        }()
        let popUp = UIAlertController.init(title: "Weather ditales", message: textView, preferredStyle: .alert)
        popUp.addAction(.init(title: "Close", style: .destructive, handler: nil))
        present(popUp, animated: true)
    }

    @objc func touch(sender: UITapGestureRecognizer) {
        let point = sender.location(in: self.mapView)
    let x = point.x
    let y = point.y
        print("касание \(x) \(y)")
    }
}

