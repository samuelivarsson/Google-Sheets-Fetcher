//
//  Sheets_Widget.swift
//  Sheets-Widget
//
//  Created by Samuel Ivarsson on 2020-09-19.
//

import WidgetKit
import SwiftUI
import Intents

let exValues: [String: Double] = ["Mat": 123, "Fika": 155, "Transport": 50, "Ovrigt": 40.6, "Matvaror": 500, "Saldo": 823.6]

struct Provider: IntentTimelineProvider {
    
    let defaults = UserDefaults(suiteName: "group.com.samuelivarsson.Sheets-Fetcher")!
    
    func getValues() -> [String: Double] {
        guard let json = try? JSONSerialization.jsonObject(with: defaults.data(forKey: "fetchData") ?? Data(), options: []) as? [String: Any] else {
            return ["Error": 1]
        }
        let values = json["values"] as! [[Any]]
        let saldo = values[0][0] as! Double
        let mat = values[2][0] as! Double
        let fika = values[3][0] as! Double
        let transport = values[4][0] as! Double
        let ovrigt = values[5][0] as! Double
        let matvaror = values[6][0] as! Double
        
        return ["Saldo": saldo, "Mat": mat, "Fika": fika, "Transport": transport, "Ovrigt": ovrigt, "Matvaror": matvaror]
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), values: exValues, configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), values: exValues, configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let hour = Calendar.current.component(.hour, from: Date())
        print(hour)
        fetchData { data, response in
            defaults.set(data, forKey: "fetchData")
            
            let values: [String: Double] = getValues()
            let currentDate = Date()
            let entry = SimpleEntry(date: currentDate, values: values, configuration: configuration)

            var refreshDate = Calendar.current.date(byAdding: .hour, value: 3, to: currentDate)!
            if  hour < 9 || hour > 22 {
                refreshDate = Date() // TODO
            }
            
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    
    let values: [String: Double]
    let configuration: ConfigurationIntent
}

struct Sheets_WidgetEntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if entry.values["Error"] != nil {
            ZStack(alignment: Alignment(horizontal: .center, vertical: .center), content: {
                colorScheme == .dark ?
                    (Color(red: 44/255, green: 44/255, blue: 44/255).edgesIgnoringSafeArea(.all)) :
                    (Color.white).edgesIgnoringSafeArea(.all)
                
                Text("Couldn't fetch values, no internet connection?").multilineTextAlignment(.center)
            })
        } else {
            let matVal = String(format: "%.2f", entry.values["Mat"]!).replacingOccurrences(of: ".", with: ",") + " kr"
            let fikaVal = String(format: "%.2f", entry.values["Fika"]!).replacingOccurrences(of: ".", with: ",") + " kr"
            let transpVal = String(format: "%.2f", entry.values["Transport"]!).replacingOccurrences(of: ".", with: ",") + " kr"
            let ovrigtVal = String(format: "%.2f", entry.values["Ovrigt"]!).replacingOccurrences(of: ".", with: ",") + " kr"
            let matvarVal = String(format: "%.2f", entry.values["Matvaror"]!).replacingOccurrences(of: ".", with: ",") + " kr"
            let saldoVal = String(format: "%.2f", entry.values["Saldo"]!).replacingOccurrences(of: ".", with: ",") + " kr"
            
            let textSize = Font.caption
            let numberSize = Font.caption2
            let width: CGFloat = 71
            let height: CGFloat = 100
            ZStack(alignment: Alignment(horizontal: .center, vertical: .center), content: {
                colorScheme == .dark ?
                    (Color(red: 44/255, green: 44/255, blue: 44/255).edgesIgnoringSafeArea(.all)) :
                    (Color.white).edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .center, spacing: nil, content: {
                    HStack(alignment: .center, spacing: 0, content: {
                        VStack(alignment: .center, spacing: 10, content: {
                            VStack(alignment: .center, spacing: 1, content: {
                                Text("Mat").font(textSize).bold()
                                Text(matVal).font(numberSize)
                            })
                            VStack(alignment: .center, spacing: 1, content: {
                                Text("Transport").font(textSize).bold()
                                Text(transpVal).font(numberSize)
                            })
                            VStack(alignment: .center, spacing: 1, content: {
                                Text("Matvaror").font(textSize).bold()
                                Text(matvarVal).font(numberSize)
                            })
                        }).frame(width: width, height: height, alignment: .center)
                        VStack(alignment: .center, spacing: 10, content: {
                            VStack(alignment: .center, spacing: 1, content: {
                                Text("Fika").font(textSize).bold()
                                Text(fikaVal).font(numberSize)
                            })
                            VStack(alignment: .center, spacing: 1, content: {
                                Text("Övrigt").font(textSize).bold()
                                Text(ovrigtVal).font(numberSize)
                            })
                            VStack(alignment: .center, spacing: 1, content: {
                                Text("Saldo").font(textSize).bold()
                                Text(saldoVal).font(numberSize)
                            })
                        }).frame(width: width, height: height, alignment: .center)
                    })
                    HStack(alignment: .center, spacing: 0, content: {
                        Text("Last updated: ").font(.system(size: 9))
                        Text(entry.date, style: .time).font(.system(size: 9))
                    }).offset(x: 0, y: 20)
                })
            })
        }
    }
}

@main
struct Sheets_Widget: Widget {
    let kind: String = "Sheets_Widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            Sheets_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall])
    }
}

struct Sheets_Widget_Previews: PreviewProvider {
    static var previews: some View {
        Sheets_WidgetEntryView(entry: SimpleEntry(date: Date(), values: exValues, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

struct Sheets_Widget_Dark_Previews: PreviewProvider {
    static var previews: some View {
        Sheets_WidgetEntryView(entry: SimpleEntry(date: Date(), values: exValues, configuration: ConfigurationIntent()))
            .environment(\.colorScheme, .dark)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
