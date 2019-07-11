//
//  ViewController.swift
//  ios_vether
//
//  Created by Артём Семёнов on 11.07.2019.
//  Copyright © 2019 Артём Семёнов. All rights reserved.
//

import UIKit

class ViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let map = UINavigationController.init()
        map.addChild(MapTab.init())
        self.setViewControllers([map, ListTab.init()], animated: true)
        // Do any additional setup after loading the view, typically from a nib.
    }


}

