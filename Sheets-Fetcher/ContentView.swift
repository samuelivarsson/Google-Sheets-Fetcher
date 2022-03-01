//
//  ContentView.swift
//  Sheets-Fetcher
//
//  Created by Samuel Ivarsson on 2020-09-19.
//

import SwiftUI
import WidgetKit

let defaults = UserDefaults(suiteName: "group.com.samuelivarsson.Sheets-Fetcher")!

protocol OurErrorProtocol: LocalizedError {

    var title: String? { get }
    var code: Int { get }
}

struct CustomError: OurErrorProtocol {

    var title: String?
    var code: Int
    var errorDescription: String? { return _description }
    var failureReason: String? { return _description }

    private var _description: String

    init(title: String?, description: String, code: Int) {
        self.title = title ?? "Error"
        self._description = description
        self.code = code
    }
}

struct ContentView: View {
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .center), content: {
            Text("Hello, world!")
                .padding()
            
            Button("Update Widgets") {
                WidgetCenter.shared.reloadAllTimelines()
            }.offset(x: 0, y: 200)
        })
    }
}

func fetchData(range: String, completion: @escaping (Result<(Data, HTTPURLResponse?),Error>) -> Void) {
    
    let ssid = "19yYHNXllQwlkC26Gi_mBq9ULUHPDL1ZD3WAIjiHk_GU"
    let apikey = "AIzaSyCZvGAaM6xv6XL5EMltLF_D5doQzWNQjj0"
    let url = URL(string: "https://sheets.googleapis.com/v4/spreadsheets/\(ssid)/values/\(range)?key=\(apikey)&valueRenderOption=UNFORMATTED_VALUE")!

    URLSession.shared.dataTask(with: url) {(data, response, error) in
        
        // Check if Error took place
        if let error = error {
            print("Error took place \(error)")
            completion(.failure(error))
            return
        }
        
        // Read HTTP Response Status code
        guard let response = response as? HTTPURLResponse else {
            let error1 = CustomError(title: nil, description: "Couldn't unwrap response", code: 70)
            completion(.failure(error1))
            return
        }
        print("Response HTTP Status code: \(response.statusCode)")
        
        if let data = data, let dataString = String(data: data, encoding: .utf8) {
            print("Response data string:\n \(dataString)")
            completion(.success((data, response)))
        } else {
            let error1 = CustomError(title: nil, description: "Couldn't unwrap data", code: 71)
            completion(.failure(error1))
        }
    }.resume()
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
