//
//  FilterModel.swift
//  Edible

import Foundation

class FilterModel {
    var isActive: Bool
    var minimumRating: Int?
    var maximumDistance: Int?
    
    init?(isActive: Bool = false, minimumRating: Int? = nil, maximumDistance: Int? = nil) {
        self.isActive = isActive
        self.minimumRating = minimumRating
        self.maximumDistance = maximumDistance
    }
}
