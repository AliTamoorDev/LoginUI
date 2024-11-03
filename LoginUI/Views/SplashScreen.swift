//
//  LoginView.swift
//  LoginUI
//
//  Created by Ali Tamoor on 01/11/2024.
//

import SwiftUI
import AVFoundation

struct SplashScreen: View {
    
    @State private var scale = 0.7
    @State var audioPlayer: AVAudioPlayer?
    @Binding var isActive: Bool
    
    var body: some View {
        VStack {
            VStack {
                Image("learn")
                    .resizable()
                    .frame(width: 180, height: 180)
                
                Text("AnnonCard")
//                    .font(Font.custom("Jersey10-Regular", size: 60))
                    .font(.system(size: 80, weight: .bold))
                    .foregroundStyle(Color.primaryApp)
                
                Text("Learn, Grow")
//                    .font(Font.custom("Jersey10-Regular", size: 60))
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(Color.primaryApp)
            }
            .scaleEffect(scale)
            .onAppear{
                withAnimation(.easeIn(duration: 0.7)) {
                    self.scale = 0.9
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color.secondaryApp
                .ignoresSafeArea(.all)
        }
        .onAppear {
            playStartUpMusic()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    audioPlayer?.stop()
                    self.isActive = true
                }
            }
        }
    }
    
    
    func playStartUpMusic() {
        guard let path = Bundle.main.path(forResource: "intro", ofType: "mp3") else {
            print("Audio file not found")
            return
        }
        do {
            audioPlayer?.stop()
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer?.play()
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
}

#Preview {
    SplashScreen(isActive: .constant(false))
}
