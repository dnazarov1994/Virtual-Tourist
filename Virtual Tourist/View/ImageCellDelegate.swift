//
//  ImageCellDelegate.swift
//  Virtual Tourist
//
//  Created by Dzhavid Babakishiiev on 6/6/19.
//  Copyright © 2019 Dzhavid. All rights reserved.
//

import Foundation
import UIKit

protocol ImageCellDelegate: class {
    func didLoad(image: UIImage?, at number: Int)
}
