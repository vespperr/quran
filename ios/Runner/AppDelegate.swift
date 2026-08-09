import Flutter
import UIKit
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    guard let controller = (window?.rootViewController as? FlutterViewController) ?? (UIApplication.shared.windows.first?.rootViewController as? FlutterViewController) else {
      NSLog("=== APPDELEGATE ERROR: FlutterViewController not found ===")
      return result
    }

    let widgetChannel = FlutterMethodChannel(
      name: "com.dya.azadalkrd/prayer_widget",
      binaryMessenger: controller.binaryMessenger
    )
    widgetChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "updateWidgetData" {
        guard let args = call.arguments as? [String: Any] else {
          result(false)
          return
        }
        let city = args["widgetCity"] as? String ?? ""
        let times = args["displayTimes"] as? String ?? ""
        let fajr = args["fajr"] as? String ?? ""
        let dhuhr = args["dhuhr"] as? String ?? ""
        let asr = args["asr"] as? String ?? ""
        let maghrib = args["maghrib"] as? String ?? ""
        let isha = args["isha"] as? String ?? ""
        let nextPrayer = args["nextPrayer"] as? String ?? ""

        NSLog("=== APPDELEGATE WIDGET SYNC RECEIVED ===")
        NSLog("city: %@", city)
        NSLog("displayTimes: %@", times)
        NSLog("fajr: %@", fajr)
        NSLog("dhuhr: %@", dhuhr)
        NSLog("asr: %@", asr)
        NSLog("maghrib: %@", maghrib)
        NSLog("isha: %@", isha)
        NSLog("nextPrayer: %@", nextPrayer)
        
        let defaults = UserDefaults(suiteName: "group.com.dya.azadalkrd") ?? UserDefaults.standard
        if !city.isEmpty { defaults.set(city, forKey: "widget_city") }
        if !times.isEmpty { defaults.set(times, forKey: "display_times") }
        if !fajr.isEmpty { defaults.set(fajr, forKey: "fajr") }
        if !dhuhr.isEmpty { defaults.set(dhuhr, forKey: "dhuhr") }
        if !asr.isEmpty { defaults.set(asr, forKey: "asr") }
        if !maghrib.isEmpty { defaults.set(maghrib, forKey: "maghrib") }
        if !isha.isEmpty { defaults.set(isha, forKey: "isha") }
        if !nextPrayer.isEmpty { defaults.set(nextPrayer, forKey: "next_prayer") }
        let lastUpdated = Date().timeIntervalSince1970
        defaults.set(lastUpdated, forKey: "last_updated")

        let jsonDict: [String: Any] = [
          "city": city,
          "displayTimes": times,
          "fajr": fajr,
          "dhuhr": dhuhr,
          "asr": asr,
          "maghrib": maghrib,
          "isha": isha,
          "nextPrayer": nextPrayer,
          "lastUpdated": lastUpdated
        ]
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict),
           let jsonString = String(data: jsonData, encoding: .utf8) {
          defaults.set(jsonString, forKey: "widget_prayer_data_v1")
        }
        defaults.synchronize()
        
        if #available(iOS 14.0, *) {
          WidgetCenter.shared.reloadAllTimelines()
          WidgetCenter.shared.reloadTimelines(ofKind: "PrayerWidget")
        }
        result(true)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    return result
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
