//
//  Osanyin__Herbal_Remedy_App.swift
//  Osanyin (Herbal Remedy)
//
//  Created by  Yomi Ajayi on 7/28/25.
//

import SwiftUI

@main
struct Osanyin__Herbal_Remedy_App: App {
    let coreDataManager = CoreDataManager.shared
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, coreDataManager.context)
                .preferredColorScheme(darkModeEnabled ? .dark : .light)
        }
    }
}
