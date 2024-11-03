//
//  ContentView.swift
//  LoginUI
//
//  Created by Ali Tamoor on 26/10/2024.
//

import SwiftUI

struct EntryView: View {
    
    @State private var isActive = false

    var body: some View {
        ZStack {
            if isActive {
                LoginView()
            } else {
                SplashScreen(isActive: $isActive)
            }
        }
    }
}

#Preview {
    EntryView()
}
