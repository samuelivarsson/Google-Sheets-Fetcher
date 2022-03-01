//
//  WakeIntent.swift
//  WakeOnLAN
//
//  Created by Samuel Ivarsson on 2020-10-31.
//

import Foundation
import Intents

class WakeOnLANIntentHandler: NSObject, WakeOnLANIntentHandling {
    func resolveBroadcastAddress(for intent: WakeOnLANIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        guard let string = intent.broadcastAddress else {
            completion(INStringResolutionResult.confirmationRequired(with: "Broadcast address was nil"))
            return
        }
        completion(INStringResolutionResult.success(with: string))
    }
    
    func resolveMacAddress(for intent: WakeOnLANIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        guard let string = intent.macAddress else {
            completion(INStringResolutionResult.confirmationRequired(with: "Broadcast address was nil"))
            return
        }
        completion(INStringResolutionResult.success(with: string))
    }
    
    func handle(intent: WakeOnLANIntent, completion: @escaping (WakeOnLANIntentResponse) -> Void) {
        guard let mac = intent.macAddress else {
            completion(WakeOnLANIntentResponse.failure(error: "Mac address was nil."))
            return
        }
        guard let broad = intent.macAddress else {
            completion(WakeOnLANIntentResponse.failure(error: "Broadcast address was nil."))
            return
        }
        let device = Awake.Device(MAC: mac, BroadcastAddr: broad)
        if let error = Awake.target(device: device) as? Awake.WakeError {
            switch error {
            case .SendMagicPacketFailed:
                completion(WakeOnLANIntentResponse.failure(error: "Sending the magic packet failed. \n" + error.localizedDescription))
            case .SetSocketOptionsFailed:
                completion(WakeOnLANIntentResponse.failure(error: "Setting the socket options failed. \n" + error.localizedDescription))
            case .SocketSetupFailed:
                completion(WakeOnLANIntentResponse.failure(error: "Socket setup failed. \n" + error.localizedDescription))
            }
            
            return
        }
        completion(WakeOnLANIntentResponse.success(result: "The magic packet was sent!"))
    }
}
