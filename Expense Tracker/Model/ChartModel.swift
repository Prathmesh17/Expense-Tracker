//
//  ChartModel.swift
//  Expense Tracker
//
//  Created by Prathmesh Parteki on 23/09/24.
//

import SwiftUI

struct ChartGroup : Identifiable {
    let id : UUID = .init()
    var date : Date
    var categories : [ChartCategory]
    var totalIncome : Double
    var totalExpense : Double
}

struct ChartCategory : Identifiable {
    let id: UUID = .init()
    var totalValue : Double
    var category : Category
}
