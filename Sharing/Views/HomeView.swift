//
//  HomeView.swift
//  sharing
//
//  Created by ZHANGYU on 2022/11/28.
//

import SwiftUI

struct HomeView: View {
    @State var columnVisibility = NavigationSplitViewVisibility.automatic

    let playerViewModel = PlayerViewModel.shared

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            PreparePlayView()
        }
         detail: {
            PlayerView()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
