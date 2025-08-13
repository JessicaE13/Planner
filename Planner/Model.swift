//
//  Model.swift
//  Planner
//
//  Created by Jessica Estes on 8/11/25.
//

import Foundation
import SwiftUI

struct Framework {
    let name: String
    let description: String
    let imageName: String
}

struct ScheduleEvent: Identifiable {
    let id = UUID()
    var title: String
    var time: String
    var icon: String
    var color: String
    var isRepeating: Bool
    var date: Date
}
