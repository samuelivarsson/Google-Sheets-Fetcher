//
//  Sheets_Widget.swift
//  Sheets-Widget
//
//  Created by Samuel Ivarsson on 2020-09-19.
//

import WidgetKit
import SwiftUI
import Intents

let deeplinkURL: String = "com.samuelivarsson.Sheets-Fetcher://"

let exValues: [String: Double] = ["Mat": 123, "Fika": 155, "Transport": 50, "Ovrigt": 40.6, "Matvaror": 500, "Saldo": 823.6]

let exValues2: [[Any]] = [["Utgifter: "], ["542,00 kr", "Veckohandling"],
                          ["13,00 kr", "Frukost"], ["15,00 kr", "Fika"],
                          ["0,00 kr", "Delade på Veckohandling"],
                          ["0,00 kr", "Delade på Frukost"],
                          ["0,00 kr", "Delade på fika"]]

struct Provider: TimelineProvider {
    
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
        let matvaror = values[7][0] as! Double
        
        return ["Saldo": saldo, "Mat": mat, "Fika": fika, "Transport": transport, "Ovrigt": ovrigt, "Matvaror": matvaror]
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), values: exValues)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), values: exValues)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        fetchData (range: "Oversikt!F26:F33") { result in
            switch result {
            case .success((let data, _)):
                defaults.set(data, forKey: "fetchData")
            case .failure(_):
                break
            }
            
            let values: [String: Double] = getValues()
            let currentDate = Date()
//            let hour = Calendar.current.component(.hour, from: currentDate)
            let entryDate = Calendar.current.date(byAdding: .second, value: 1, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, values: values)

//            var refreshDate = Calendar.current.date(byAdding: .hour, value: 3, to: currentDate)!
//            if  hour > 22 {
//                refreshDate = getTomorrowAt(hour: 9, minutes: 0)
//            } else if hour < 9 {
//                refreshDate = getTodayAt(hour: 9, minutes: 0)
//            }
            
            let timeline = Timeline(entries: [entry], policy: .never)
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    
    let values: [String: Double]
}

struct Sheets_WidgetEntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetFamily) var family

    var body: some View {
        if entry.values["Error"] != nil {
            ZStack(alignment: Alignment(horizontal: .center, vertical: .center), content: {
                if colorScheme == .dark {
                    Color(red: 44/255, green: 44/255, blue: 44/255).edgesIgnoringSafeArea(.all)
                }
                
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
            let width: CGFloat = (family == .systemMedium) ? 120 : 71
            let height: CGFloat = 100
            
            ZStack(alignment: Alignment(horizontal: .center, vertical: .center), content: {
                if colorScheme == .dark {
                    Color(red: 44/255, green: 44/255, blue: 44/255).edgesIgnoringSafeArea(.all)
                }
                
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
                        Text("Senast uppdaterad: ").font(.system(size: 9))
                        Text(Date(), style: .time).font(.system(size: 9))
                    }).offset(x: 0, y: 20)
                })
            }).widgetURL(URL(string: deeplinkURL))
        }
    }
}

struct Sheets_Widget: Widget {
    let kind: String = "Sheets_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            Sheets_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Saldon")
        .description("Visar hur mycket du kan spendera i varje kategori.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct Sheets_Widget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Sheets_WidgetEntryView(entry: SimpleEntry(date: Date(), values: exValues))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            Sheets_WidgetEntryView(entry: SimpleEntry(date: Date(), values: exValues))
            .environment(\.colorScheme, .dark)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}

struct Provider2: IntentTimelineProvider {
    
    let defaults = UserDefaults(suiteName: "group.com.samuelivarsson.Sheets-Fetcher")!
    
    func getValues(configuration: ConfigurationIntent) -> [[Any]] {
        guard let jsonUtgifter = try? JSONSerialization.jsonObject(with: defaults.data(forKey: "fetchData2") ?? Data(), options: []) as? [String: Any] else {
            return [["Error", 1]]
        }
        guard let jsonInkomster = try? JSONSerialization.jsonObject(with: defaults.data(forKey: "fetchData3") ?? Data(), options: []) as? [String: Any] else {
            return [["Error", 2]]
        }
        guard let jsonSaldon = try? JSONSerialization.jsonObject(with: defaults.data(forKey: "fetchData4") ?? Data(), options: []) as? [String: Any] else {
            return [["Error", 2]]
        }
        guard let utgifter = jsonUtgifter["values"] as? [[Any]] else {
            return [["Error", 3]]
        }
        guard let inkomster = jsonInkomster["values"] as? [[Any]] else {
            return [["Error", 4]]
        }
        guard let saldon = jsonSaldon["values"] as? [[Any]] else {
            return [["Error", 4]]
        }
        
        var values: [[Any]] = []
        
        var title = ""
        switch configuration.Typ {
        case .saldon:
            title = "Saldon: "
        case .utgifter:
            title = "Utgifter: "
        case .inkomster:
            title = "Inkomster: "
        default:
            title = "Error?"
        }
        
        values.append([title])
        
        let j = (utgifter.count < 3) ? 0 : utgifter.count-3
        for i in j...utgifter.count-1 {
            let value = utgifter[i][0] as! Double
            let val = String(format: "%.2f", value).replacingOccurrences(of: ".", with: ",") + " kr"
            let key = utgifter[i][1] as! String
            
            values.append([val, key])
        }
        while values.count < 4 {
            values.append(["", ""])
        }
        
        let j2 = (inkomster.count < 3) ? 0 : inkomster.count-3
        for i in j2...inkomster.count-1 {
            let value = inkomster[i][0] as! Double
            let val = String(format: "%.2f", value).replacingOccurrences(of: ".", with: ",") + " kr"
            let key = inkomster[i][1] as! String
            
            values.append([val, key])
        }
        while values.count < 7 {
            values.append(["", ""])
        }
        for i in 0...2 {
            var a = i
            var b1 = 1
            let b2 = 0
            if i == 2 {
                a = saldon.count-1
                b1 = saldon[a].count-1
            }
            let value = saldon[a][b1] as! Double
            let val = String(format: "%.2f", value).replacingOccurrences(of: ".", with: ",") + " kr"
            let key = (i != 2) ? saldon[a][b2] as! String : "Använt sparkonto: "
            
            values.append([val, key])
        }
        print(saldon)
        print(values)
        
        return values
    }
    
    func placeholder(in context: Context) -> SimpleEntry2 {
        SimpleEntry2(date: Date(), values: exValues2)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry2) -> ()) {
        let entry = SimpleEntry2(date: Date(), values: exValues2)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var range: String = ""
        var key: String = ""
        var both: Bool = false
        switch configuration.Typ {
        case .saldon:
            range = "Oversikt!D18:K28"
            key = "fetchData4"
        case .utgifter:
            range = "Transaktioner!C5:D"
            key = "fetchData2"
        case .inkomster:
            range = "Transaktioner!H5:I"
            key = "fetchData3"
        default:
            range = "Transaktioner!C5:D"
            key = "fetchData2"
            both = true
        }
        fetchData (range: range) { result in
            switch result {
            case .success((let data, _)):
                defaults.set(data, forKey: key)
            case .failure(_):
                break
            }
            
            if both {
                fetchData(range: "Transaktioner!H5:I") { result in
                    switch result {
                    case .success((let data, _)):
                        defaults.set(data, forKey: "fetchData3")
                    case .failure(_):
                        break
                    }
                    
                    let values: [[Any]] = getValues(configuration: configuration)
                    
                    let currentDate = Date()
//                    let hour = Calendar.current.component(.hour, from: currentDate)
                    let entryDate = Calendar.current.date(byAdding: .second, value: 1, to: currentDate)!
                    let entry = SimpleEntry2(date: entryDate, values: values)

//                    var refreshDate = Calendar.current.date(byAdding: .hour, value: 3, to: currentDate)!
//                    if  hour > 22 {
//                        refreshDate = getTomorrowAt(hour: 9, minutes: 0)
//                    } else if hour < 9 {
//                        refreshDate = getTodayAt(hour: 9, minutes: 0)
//                    }
                    
                    let timeline = Timeline(entries: [entry], policy: .never)
                    completion(timeline)
                }
            } else {
                let values: [[Any]] = getValues(configuration: configuration)
                
                let currentDate = Date()
//                let hour = Calendar.current.component(.hour, from: currentDate)
                let entryDate = Calendar.current.date(byAdding: .second, value: 1, to: currentDate)!
                let entry = SimpleEntry2(date: entryDate, values: values)

//                var refreshDate = Calendar.current.date(byAdding: .hour, value: 3, to: currentDate)!
//                if  hour > 22 {
//                    refreshDate = getTomorrowAt(hour: 9, minutes: 0)
//                } else if hour < 9 {
//                    refreshDate = getTodayAt(hour: 9, minutes: 0)
//                }
                
                let timeline = Timeline(entries: [entry], policy: .never)
                completion(timeline)
            }
        }
    }
}

struct SimpleEntry2: TimelineEntry {
    var date: Date
    let values: [[Any]]
}

func getValues(title: String, values: [[Any]]) -> [[Any]] {
    var newValues: [[Any]] = values
    
    if title == "Saldon: " {
        for i in 1...3 {
            newValues[i][0] = newValues[i+6][0]
            newValues[i][1] = newValues[i+6][1]
        }
        return newValues
    }
    
    if title != "Utgifter: " {
        for i in 1...3 {
            newValues[i][0] = newValues[i+3][0]
            newValues[i][1] = newValues[i+3][1]
        }
    }
    
    return newValues
}

struct Sheets_WidgetEntryView2 : View {
    var entry: Provider2.Entry
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetFamily) var family

    var body: some View {
        if entry.values[0][0] as! String == "Error" {
            ZStack(alignment: Alignment(horizontal: .center, vertical: .center), content: {
                if colorScheme == .dark {
                    Color(red: 44/255, green: 44/255, blue: 44/255).edgesIgnoringSafeArea(.all)
                }
                
                Text("Couldn't fetch values, no internet connection?").multilineTextAlignment(.center)
            })
        } else {
            switch family {
            case .systemSmall:
                let title = entry.values[0][0] as! String
                let values = getValues(title: title, values: entry.values)
                let key1 = values[1][1] as! String
                let val1 = values[1][0] as! String
                let key2 = values[2][1] as! String
                let val2 = values[2][0] as! String
                let key3 = values[3][1] as! String
                let val3 = values[3][0] as! String
                
                let titleSize = Font.caption
                let textSize = Font.caption2
                let numberSize = Font.caption2
                ZStack(alignment: Alignment(horizontal: .center, vertical: .center), content: {
                    if colorScheme == .dark {
                        Color(red: 44/255, green: 44/255, blue: 44/255).edgesIgnoringSafeArea(.all)
                    }

                    VStack(alignment: .center, spacing: nil, content: {
                        VStack(alignment: .center, spacing: 5, content: {
                            Text(title).font(titleSize).bold()
                            VStack(alignment: .center, spacing: 1, content: {
                                Text(key1).font(textSize).bold().lineLimit(1).allowsTightening(true).minimumScaleFactor(0.5)
                                Text(val1).font(numberSize)
                            })
                            VStack(alignment: .center, spacing: 1, content: {
                                Text(key2).font(textSize).bold().lineLimit(1).allowsTightening(true).minimumScaleFactor(0.5)
                                Text(val2).font(numberSize)
                            })
                            VStack(alignment: .center, spacing: 1, content: {
                                Text(key3).font(textSize).bold().lineLimit(1).allowsTightening(true).minimumScaleFactor(0.5)
                                Text(val3).font(numberSize)
                            })
                        }).frame(maxWidth: .infinity)
                        HStack(alignment: .center, spacing: 0, content: {
                            Text("Senast uppdaterad: ").font(.system(size: 9))
                            Text(Date(), style: .time).font(.system(size: 9))
                        }).offset(x: 0, y: 5)
                    }).padding()
                }).widgetURL(URL(string: deeplinkURL))
            default:
                let key1 = entry.values[1][1] as! String
                let val1 = entry.values[1][0] as! String
                let key2 = entry.values[2][1] as! String
                let val2 = entry.values[2][0] as! String
                let key3 = entry.values[3][1] as! String
                let val3 = entry.values[3][0] as! String
                let key4 = entry.values[4][1] as! String
                let val4 = entry.values[4][0] as! String
                let key5 = entry.values[5][1] as! String
                let val5 = entry.values[5][0] as! String
                let key6 = entry.values[6][1] as! String
                let val6 = entry.values[6][0] as! String
                
                let titleSize = Font.caption
                let textSize = Font.caption2
                let numberSize = Font.caption2
                ZStack(alignment: Alignment(horizontal: .center, vertical: .center), content: {
                    if colorScheme == .dark {
                        Color(red: 44/255, green: 44/255, blue: 44/255).edgesIgnoringSafeArea(.all)
                    }

                    VStack(alignment: .center, spacing: nil, content: {
                        HStack(alignment: .center, spacing: 0, content: {
                            VStack(alignment: .center, spacing: 5, content: {
                                Text("Utgifter: ").font(titleSize).bold()
                                VStack(alignment: .center, spacing: 1, content: {
                                    Text(key1).font(textSize).bold().lineLimit(1).allowsTightening(true).minimumScaleFactor(0.5)
                                    Text(val1).font(numberSize)
                                })
                                VStack(alignment: .center, spacing: 1, content: {
                                    Text(key2).font(textSize).bold().lineLimit(1).allowsTightening(true).minimumScaleFactor(0.5)
                                    Text(val2).font(numberSize)
                                })
                                VStack(alignment: .center, spacing: 1, content: {
                                    Text(key3).font(textSize).bold().lineLimit(1).allowsTightening(true).minimumScaleFactor(0.5)
                                    Text(val3).font(numberSize)
                                })
                            }).frame(maxWidth: .infinity)
                            VStack(alignment: .center, spacing: 5, content: {
                                Text("Inkomster: ").font(titleSize).bold()
                                VStack(alignment: .center, spacing: 1, content: {
                                    Text(key4).font(textSize).bold().lineLimit(1).allowsTightening(true).minimumScaleFactor(0.5)
                                    Text(val4).font(numberSize)
                                })
                                VStack(alignment: .center, spacing: 1, content: {
                                    Text(key5).font(textSize).bold().lineLimit(1).allowsTightening(true).minimumScaleFactor(0.5)
                                    Text(val5).font(numberSize)
                                })
                                VStack(alignment: .center, spacing: 1, content: {
                                    Text(key6).font(textSize).bold().lineLimit(1).allowsTightening(true).minimumScaleFactor(0.5)
                                    Text(val6).font(numberSize)
                                })
                            }).frame(maxWidth: .infinity)
                        })
                        HStack(alignment: .center, spacing: 0, content: {
                            Text("Senast uppdaterad: ").font(.system(size: 9))
                            Text(Date(), style: .time).font(.system(size: 9))
                        }).offset(x: 0, y: 5)
                    }).padding()
                }).widgetURL(URL(string: deeplinkURL))
            }
        }
    }
}

struct Sheets_Widget2: Widget {
    let kind: String = "Sheets_Widget2"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider2()) { entry in
            Sheets_WidgetEntryView2(entry: entry)
        }
        .configurationDisplayName("Transaktioner")
        .description("Visar dina senaste transaktioner.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct Sheets_Widget_Previews2: PreviewProvider {
    static var previews: some View {
        Group {
            // Small white
            Sheets_WidgetEntryView2(entry: SimpleEntry2(date: Date(), values: exValues2))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            // Small dark
            Sheets_WidgetEntryView2(entry: SimpleEntry2(date: Date(), values: exValues2))
            .environment(\.colorScheme, .dark)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}

@main
struct SheetsWidgets: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        Sheets_Widget()
        Sheets_Widget2()
    }
}

func getTomorrowAt(hour: Int, minutes: Int) -> Date {
    let today = Date()
    let morrow = Calendar.current.date(byAdding: .day,
                                       value: 1,
                                       to: today)
    return Calendar.current.date(bySettingHour: hour,
                                 minute: minutes,
                                 second: 0,
                                 of: morrow!)!

}

func getTodayAt(hour: Int, minutes: Int) -> Date {
    let today = Date()
    return Calendar.current.date(bySettingHour: hour,
                                 minute: minutes,
                                 second: 0,
                                 of: today)!

}
