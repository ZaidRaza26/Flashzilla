//
//  SettingsView.swift
//  Flashzilla
//
//  Created by Zaid Raza on 06/01/2021.
//  Copyright © 2021 Zaid Raza. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var settingsEnabled: Bool
    
    var body: some View {
        NavigationView{
            VStack{
                Toggle(isOn: $settingsEnabled){
                    Text("If you turn this ON and get an answer wrong, your card will be back in the stack for you to try again.")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            }
            .navigationBarItems(trailing: Button("Done", action: dismiss))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}
