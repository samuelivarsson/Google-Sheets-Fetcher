//
//  UpdateWidgetIntentHandler.swift
//  Sheets-Fetcher
//
//  Created by Samuel Ivarsson on 2020-09-20.
//

import SwiftUI
import Foundation
import Intents
import WidgetKit

class UpdateWidgetIntentHandler: NSObject, UpdateWidgetIntentHandling {
    
    let defaults = UserDefaults(suiteName: "group.com.samuelivarsson.Sheets-Fetcher")!
    
    func handle(intent: UpdateWidgetIntent, completion: @escaping (UpdateWidgetIntentResponse) -> Void) {
        WidgetCenter.shared.reloadAllTimelines()
        completion(UpdateWidgetIntentResponse.success(result: "Widget was updated!"))
    }
}
