//
//  MapTab.swift
//  ios_vether
//
//  Created by Артём Семёнов on 11.07.2019.
//  Copyright © 2019 Артём Семёнов. All rights reserved.
//

import UIKit
import MapKit

class MapTab: UIViewController {
    let mapView = MKMapView.init()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.mapView)
        let constr = [self.view.safeAreaLayoutGuide.topAnchor.constraint(equalToSystemSpacingBelow: self.mapView.topAnchor, multiplier: 1), self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: self.mapView.bottomAnchor, multiplier: 1), self.view.safeAreaLayoutGuide.leftAnchor.constraint(equalToSystemSpacingAfter: self.mapView.leftAnchor, multiplier: 1), self.view.safeAreaLayoutGuide.rightAnchor.constraint(equalToSystemSpacingAfter: self.mapView.rightAnchor, multiplier: 1)] // задаём размеры
        NSLayoutConstraint.activate(constr) // расчитываем констрейны
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
