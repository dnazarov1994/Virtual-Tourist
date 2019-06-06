//
//  PhotoResponse.swift
//  Virtual Tourist
//
//  Created by Dzhavid Babakishiiev on 5/7/19.
//  Copyright © 2019 Dzhavid. All rights reserved.
//

import Foundation

struct PhotoResponse: Codable {
    var stat: String
    var photos: PhotoPage
}

struct PhotoPage: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [Photo]
}
    
struct Photo: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
}


