//
//  PlayerView.swift
//  sharing
//
//  Created by ZHANGYU on 2022/11/28.
//

import AVKit
import SwiftUI

struct UIKitAVPlayer: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let vc = AVPlayerViewController()
        vc.player = player
        vc.canStartPictureInPictureAutomaticallyFromInline = true
        vc.allowsPictureInPicturePlayback = true
        return vc
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }
}

struct PlayerView: View {
    @StateObject var playerViewModel = PlayerViewModel.shared

    var body: some View {
        if playerViewModel.currentMovie == nil {
            Text("Select or Add one movie")
                .foregroundColor(.secondary)
        }
        else {
            UIKitAVPlayer(player: playerViewModel.player)
                .ignoresSafeArea()
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView()
    }
}
