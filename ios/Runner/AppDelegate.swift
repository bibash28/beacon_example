import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate  {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let beaconMethodChannel = FlutterMethodChannel(name: "beaconMethod",
                                                       binaryMessenger: controller.binaryMessenger)
        
        let beaconEventChannel = FlutterEventChannel(name: "beaconEvent", binaryMessenger: controller.binaryMessenger)
        
        beaconMethodChannel.setMethodCallHandler({(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch call.method {
            case "startBeacon":
                BeaconChannelHandler.shared.startBeacon(result: result)
            case "pair":
                BeaconChannelHandler.shared.pair(call: call, result: result)
            case "removePeers":
                BeaconChannelHandler.shared.removePeers(result: result)
            case "respondExample":
                BeaconChannelHandler.shared.respondExample(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        })
        
        
        beaconEventChannel.setStreamHandler(BeaconChannelHandler.shared)
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
