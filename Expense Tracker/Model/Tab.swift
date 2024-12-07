//
//  Tab.swift
//  Expense Tracker
//
//  Created by Prathmesh Parteki on 21/09/24.
//

import SwiftUI

enum Tab: String {
    case recents = "Recents"
    case search = "Search"
    case graphs = "Graphs"
    case settings = "Settings"
    
    @ViewBuilder
    var tabContent : some View {
        switch self {
        case .recents:
            Image(systemName: "calendar")
            Text(self.rawValue)
        case .search:
            Image(systemName: "magnifyingglass")
            Text(self.rawValue)
        case .graphs:
            Image(systemName: "chart.bar.xaxis")
            Text(self.rawValue)
        case .settings:
            Image(systemName: "gearshape")
            Text(self.rawValue)
        }
    }
}
