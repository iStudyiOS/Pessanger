//
//  ProfileModel.swift
//  Pessanger
//
//  Created by 강민성 on 2021/05/16.
//

import Foundation

struct Section {
    let title: String
    let options: [Option]
}

struct Option {
    let title: String
    let handler: () -> Void
}
