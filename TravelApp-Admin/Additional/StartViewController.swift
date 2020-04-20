//
//  StartViewController.swift
//  TravelApp-Admin
//
//  Created by Антон Иванов on 4/18/20.
//  Copyright © 2020 companyName. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    @IBOutlet weak var downloadProgLbl: UILabel!
    @IBOutlet weak var uploadProgLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func doSomeAction(_ sender: UIButton) {
        PlaceManager.shared.getDPImages(with: self)
    }

}
