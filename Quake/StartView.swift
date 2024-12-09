//
//  ContentView.swift
//  Quake
//
//  Created by Reid Allenstein on 10/14/24.
//

import SwiftUI
import Foundation

struct StartView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Quake")
        }
        .padding()
    }
}

#Preview {
    StartView()
}
