//
//  PreparePlayView.swift
//  sharing
//
//  Created by ZHANGYU on 2022/11/28.
//

import SwiftUI

struct ShareSheetView: UIViewControllerRepresentable {
    typealias Callback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    let excludedActivityTypes: [UIActivity.ActivityType]? = nil
    let callback: Callback? = nil
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = callback
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // nothing to do here
    }
}

struct PreparePlayView: View {
    @State var sheetOpen = false
    @State var formValues = FormValues()
    @State var activitySheetOpen = false

    @StateObject var playerViewModel = PlayerViewModel.shared

    var body: some View {
        List {
            ForEach(self.playerViewModel.playList) { movie in
                if UIDevice.current.userInterfaceIdiom == .pad {
                    Button(movie.title) {
                        playerViewModel.prepareToPlay(movie)
                    }
                    .onLongPressGesture{
                        activitySheetOpen = true
                    }
                } else {
                    NavigationLink(movie.title) {
                        PlayerView()
                            .onAppear {
                                playerViewModel.prepareToPlay(movie)
                            }
                    }
                }
            }
            .onDelete(perform: playerViewModel.removeMovieFromList)
        }
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(action: {
                    self.sheetOpen = true
                }) {
                    Label("New", systemImage: "plus").labelStyle(.titleAndIcon)
                }
            }
        }
        .sheet(isPresented: self.$sheetOpen, onDismiss: { formValues.clear() }) {
            NavigationStack {
                Form {
                    Section(header: Text("Movie Information")) {
                        TextField("Url", text: $formValues.url)
                        TextField("Title", text: $formValues.title)
                        TextField("Subtitle", text: $formValues.subtitle)
                    }
                    .autocorrectionDisabled(true)
                    #if os(iOS)
                        .textInputAutocapitalization(.never)
                    #endif
                    Button(action: {
                        playerViewModel.addMovieToList(
                            url: formValues.url,
                            title: formValues.title,
                            subtitle: formValues.subtitle
                        )
                        sheetOpen = false
                    }) {
                        Label("Add To List", systemImage: "plus.circle.fill")
                    }
                }
                .navigationTitle("New Movie")
                .onDisappear {
                    formValues.clear()
                }
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
            }
        }
//        .sheet(isPresented: $activitySheetOpen) {
//            ShareSheetView(activityItems: ["Hello World"])
//        }
    }

    struct FormValues {
        var url = ""
        var title = ""
        var subtitle = ""

        mutating func clear() {
            url = ""
            title = ""
            subtitle = ""
        }
    }
}

struct CreatePlayerModal_Previews: PreviewProvider {
    static var previews: some View {
        PreparePlayView()
    }
}
