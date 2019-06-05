//
//  ShowError.swift
//  Virtual Tourist
//
//  Created by Dzhavid Babakishiiev on 6/2/19.
//  Copyright © 2019 Dzhavid. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func show(error:Error) {
        let alert = UIAlertController(title: "ERROR", message: error.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
}
