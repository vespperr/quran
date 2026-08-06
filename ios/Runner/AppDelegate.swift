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

    if let controller = window?.rootViewController as? FlutterViewController {
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
          
          let defaults = UserDefaults(suiteName: "group.com.dya.azadalkrd") ?? UserDefaults.standard
          defaults.set(city, forKey: "widget_city")
          defaults.set(times, forKey: "display_times")
          defaults.synchronize()
          
          if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
          }
          result(true)
        } else {
          result(FlutterMethodNotImplemented)
        }
      })
    }

    return result
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
