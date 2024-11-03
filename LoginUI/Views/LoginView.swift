//
//  LoginView.swift
//  LoginUI
//
//  Created by Ali Tamoor on 01/11/2024.
//

import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    @State private var orientation =  UIDevice.current.orientation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        if isLoggedIn {
            ContentView()
        } else {
            ZStack {
                GeometryReader { geo in
                    VStack(alignment: .leading) {
                        HStack {
                            VStack(alignment: .leading)  {
                                HStack {
                                    
                                    Spacer()
                                }
                                
                                Text("Login into Learnify")
                                    .font(.title)
                                    .bold()
                                    .foregroundStyle(Color(.primaryApp))
                                
                                Text("Welcome to AnnonCard! Let's Fuel your passion for learning!")
                                    .font(.title3)
                                    .padding(.bottom,30)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(Color(.primaryApp).opacity(0.8))
                                
                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .padding(.leading)
                                    
                                    TextField("Benutzername", text: $username)
                                        .padding(.vertical)
                                }
                                .background(.white)
                                .cornerRadius(16)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray, lineWidth: 1)
                                }
                                .padding(.bottom,10)
                                
                                
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .padding(.leading)
                                    
                                    SecureField("Passwort", text: $password)
                                        .padding(.vertical)
                                }
                                .background(.white)
                                .cornerRadius(16)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray, lineWidth: 1)
                                }
                                .padding(.bottom,25)
                                
                                
                                Button(action: {
                                    if !username.isEmpty && !password.isEmpty {
                                        isLoggedIn = true
                                    }
                                }) {
                                    Text("Anmelden")
                                        .font(.title2)
                                        .bold()
                                        .padding()
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .background(Color(.primaryApp))
                                        .cornerRadius(16)
                                        .padding(.horizontal, 10)
                                }
                            }
                            .padding(.leading, 20)
                            .padding(.horizontal, 10)
                            .frame(width: orientation .isPortrait ? geo.size.width * 0.50 : geo.size.width * 0.40)
                            
                            
                            Image("BgLearn")
                                .resizable()
                                .scaledToFill()
                                .clipped()
                                .ignoresSafeArea()
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                //            .background(Color(UIColor.systemGray5))
                .background(Color(.secondaryApp))
                .onRotate { newOrientation in
                    orientation = newOrientation
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
