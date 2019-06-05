//
//  SystemError.swift
//  Virtual Tourist
//
//  Created by Dzhavid Babakishiiev on 6/2/19.
//  Copyright © 2019 Dzhavid. All rights reserved.
//

import Foundation

enum SystemError: Error {
    case defaultError
    
    var localizedDescription: String {
        switch self {
        case .defaultError:
            return "Something went wrong. Please try again later."
        }
    }
    
}
