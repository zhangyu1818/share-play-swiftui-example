//
//  PlayerViewModel.swift
//  sharing
//
//  Created by ZHANGYU on 2022/11/29.
//

import AVKit
import Combine
import Foundation
import GroupActivities

struct Movie: Hashable, Codable, Identifiable {
    var id = UUID()

    var url: URL
    var title: String
    var subtitle: String?
}

struct MovieWatchingActivity: GroupActivity {
    let movie: Movie

    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.type = .watchTogether
        metadata.fallbackURL = movie.url
        metadata.title = movie.title
        metadata.subtitle = movie.subtitle
        return metadata
    }
}

class PlayerViewModel: ObservableObject {
    static let shared = PlayerViewModel()

    @Published var groupSession: GroupSession<MovieWatchingActivity>? {
        didSet {
            guard let groupSession = groupSession else { return }
            player.playbackCoordinator.coordinateWithSession(groupSession)
        }
    }

    @Published private(set) var currentMovie: Movie? {
        didSet {
            guard let currentMovie = currentMovie else { return }
            let currentItem = AVPlayerItem(url: currentMovie.url)
            player.replaceCurrentItem(with: currentItem)
        }
    }

    @Published private(set) var playList: [Movie] {
        didSet {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(playList)
                UserDefaults.standard.set(data, forKey: "PlayList")

            } catch {
                print("Unable to Encode Array of PlayList (\(error))")
            }
        }
    }

    private var subscriptions = Set<AnyCancellable>()

    let player = AVPlayer()

    init() {
        let defaultMovie = Movie(url: URL(string: "https://bitmovin-a.akamaihd.net/content/dataset/multi-codec/hevc/stream_fmp4.m3u8")!, title: "HLS HEVC")
        do {
            let data = UserDefaults.standard.data(forKey: "PlayList")
            if let data = data {
                let decoder = JSONDecoder()
                playList = try decoder.decode([Movie].self, from: data)
            } else {
                playList = [defaultMovie]
            }

        } catch {
            print("Unable to Decode PlayList (\(error))")
            playList = [defaultMovie]
        }

        Task {
            for await groupSession in MovieWatchingActivity.sessions() {
                DispatchQueue.main.async {
                    self.groupSession = groupSession
                }

                subscriptions.removeAll()

                groupSession
                    .$state
                    .receive(on: RunLoop.main)
                    .sink { [weak self] state in
                        if case .invalidated = state {
                            self?.groupSession = nil
                            self?.subscriptions.removeAll()
                        }
                    }
                    .store(in: &subscriptions)

                groupSession.join()

                groupSession
                    .$activity
                    .receive(on: RunLoop.main)
                    .sink { [weak self] activity in
                        self?.currentMovie = activity.movie
                    }
                    .store(in: &subscriptions)
            }
        }
    }

    func prepareToPlay(_ movie: Movie) {
        if currentMovie == movie {
            return
        }

        if let groupSession = groupSession {
            if groupSession.activity.movie != movie {
                groupSession.activity = MovieWatchingActivity(movie: movie)
            }
        } else {
            Task {
                let activity = MovieWatchingActivity(movie: movie)

                switch await activity.prepareForActivation() {
                case .activationDisabled:

                    DispatchQueue.main.async {
                        self.currentMovie = movie
                    }

                case .activationPreferred:
                    do {
                        _ = try await activity.activate()
                    } catch {
                        print("Unable to activate the activity: \(error)")
                    }

                case .cancelled:
                    break

                default: ()
                }
            }
        }
    }

    func addMovieToList(url: String, title: String, subtitle: String) {
        guard let url = URL(string: url) else {
            return
        }
        let newMovie = Movie(url: url, title: title, subtitle: subtitle.isEmpty ? nil : subtitle)

        playList.append(newMovie)
    }

    func removeMovieFromList(at offset: IndexSet) {
        playList.remove(atOffsets: offset)
    }
}
