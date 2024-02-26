//
//  Models.swift
//  DirSizeTree
//
//  Created by 冰轩 on 2024/2/25.
//

import Foundation

struct PieChartData: Identifiable {
    var hint: String
    var percent: Double
    let id = UUID()
}

struct ProcessedChartData: Identifiable {
    var hint: String
    var startAngle: Double
    var endAngle: Double
    let id = UUID()
}
