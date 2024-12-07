//
//  ContentView.swift
//  Expense Tracker
//
//  Created by Prathmesh Parteki on 21/09/24.
//

import SwiftUI

struct ContentView: View {
    ///Intro Visibility status
    @AppStorage("isFirstTime") private var isFirstTime : Bool = true
    ///App Lock Properties
    @AppStorage("isAppLockEnabled") private var isAppLockEnabled : Bool = false
    @AppStorage("lockWhenAppGoesBackground") private var lockWhenAppGoesBackground : Bool = false
    ///Active Tab
    @State private var activeTab : Tab = .recents
    var body: some View {
        LockView(lockType: .biometric, lockPin: "", isEnabled: isAppLockEnabled,lockWhenAppGoesBackGround: lockWhenAppGoesBackground) {
            TabView(selection: $activeTab){
                Recents()
                    .tag(Tab.recents)
                    .tabItem { Tab.recents.tabContent }
                
                Search()
                    .tag(Tab.search)
                    .tabItem { Tab.search.tabContent }
                
                Graphs()
                    .tag(Tab.graphs)
                    .tabItem { Tab.graphs.tabContent }
                
                Settings()
                    .tag(Tab.settings)
                    .tabItem { Tab.settings.tabContent }
            }
            .tint(appTint)
            .sheet(isPresented: $isFirstTime, content: {
                IntroScreen()
                    .interactiveDismissDisabled()
            })
        }
        
    }
}

#Preview {
    ContentView()
}
