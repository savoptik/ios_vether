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
        map.title = NSLocalizedString("map", comment: "")
        map.addChild(MapTab.init())
        let list = ListTab.init()
        let listNavigation = UINavigationController.init()
        listNavigation.title = NSLocalizedString("list", comment: "")
        listNavigation.addChild(list)
        self.setViewControllers([map, listNavigation], animated: true)
        // Do any additional setup after loading the view, typically from a nib.
    }


}

