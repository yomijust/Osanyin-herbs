//
//  ContentView.swift
//  Osanyin (Herbal Remedy)
//
//  Created by  Yomi Ajayi on 7/28/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedContinent: Continent?
    @State private var selectedCategory: HerbCategory?
    
    var body: some View {
        HeroView(selectedContinent: $selectedContinent, selectedCategory: $selectedCategory)
    }
}

#Preview {
    ContentView()
}
