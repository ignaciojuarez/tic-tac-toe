//
//  ContentView.swift
//  tic-tac-toe
//
//  Created by Ignacio Juarez on 7/18/23.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                SpriteView(scene: GameScene(size: proxy.size))
            }
            .ignoresSafeArea()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
