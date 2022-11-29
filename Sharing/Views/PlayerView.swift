//
//  PlayerView.swift
//  sharing
//
//  Created by ZHANGYU on 2022/11/28.
//

import AVKit
import SwiftUI

struct PlayerView: View {
    @StateObject var playerViewModel = PlayerViewModel.shared

    var body: some View {
        if playerViewModel.currentMovie == nil {
            Text("Select or Add one movie")
                .foregroundColor(.secondary)
        }
        else {
            VideoPlayer(player: playerViewModel.player)
                .ignoresSafeArea()
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView()
    }
}
