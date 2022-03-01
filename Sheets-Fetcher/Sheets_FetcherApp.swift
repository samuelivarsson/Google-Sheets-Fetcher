//
//  Sheets_FetcherApp.swift
//  Sheets-Fetcher
//
//  Created by Samuel Ivarsson on 2020-09-19.
//

import SwiftUI
import WidgetKit

@main
struct Sheets_FetcherApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView().onOpenURL { url in
                if url.scheme == "com.samuelivarsson.Sheets-Fetcher" || url.scheme == "sheets-fetcher" {
                    WidgetCenter.shared.reloadAllTimelines()
                    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
//                    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                        exit(0)
//                    }
                }
            }
        }
    }
}
