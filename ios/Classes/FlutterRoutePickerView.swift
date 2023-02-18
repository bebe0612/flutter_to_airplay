//
//  FlutterRoutePickerView.swift
//  flutter_to_airplay
//
//  Created by Junaid Rehmat on 22/08/2020.
//

import Foundation
import AVKit
import MediaPlayer
import Flutter

class FlutterRoutePickerView: NSObject, FlutterPlatformView {
    private var _flutterRoutePickerView : UIView;
    private var _delegate: AVRoutePickerViewDelegate?
    
    init(
        messenger: FlutterBinaryMessenger,
        viewId: Int64,
        arguments: Dictionary<String, Any>
    ) {
        if #available(iOS 11.0, *) {
            let tempView = AVRoutePickerView(frame: .init(x: 0.0, y: 0.0, width: 44.0, height: 44.0))
            if let tintColor = arguments["tintColor"] {
                let color = tintColor as! Dictionary<String, Any>
                tempView.tintColor = FlutterRoutePickerView.mapToColor(color)
            }
            if let tintColor = arguments["activeTintColor"] {
                let color = tintColor as! Dictionary<String, Any>
                tempView.activeTintColor = FlutterRoutePickerView.mapToColor(color)
            }
            if let tintColor = arguments["backgroundColor"] {
                let color = tintColor as! Dictionary<String, Any>
                tempView.backgroundColor = FlutterRoutePickerView.mapToColor(color)
            }
            
            if #available(iOS 13.0, *) {
                tempView.prioritizesVideoDevices = arguments["prioritizesVideoDevices"] as! Bool
            }
            
            _delegate = FlutterRoutePickerDelegate(viewId: viewId, messenger: messenger)
            tempView.delegate = _delegate
            
            _flutterRoutePickerView = tempView
            
            super.init()

            NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange), name: AVAudioSession.routeChangeNotification, object: nil)

        } else {
            let tempView = MPVolumeView(frame: .init(x: 0.0, y: 0.0, width: 44.0, height: 44.0))
            tempView.showsVolumeSlider = false
            _flutterRoutePickerView = tempView
            
            super.init()
        }
    }
    
    func view() -> UIView {
        return _flutterRoutePickerView
    }
    
    static func mapToColor(_ map: Dictionary<String, Any>) -> UIColor {
        return  UIColor.init(red: map["red"] as! CGFloat,
                             green: map["green"] as! CGFloat,
                             blue: map["blue"] as! CGFloat,
                             alpha: map["alpha"] as! CGFloat)
    }
    
    @objc func handleRouteChange(notification: Notification) {
        isAirplaying()
        guard let userInfo = notification.userInfo else {
            return
        }
            
        if let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt, let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) {
            
            
            switch reason {
            case .newDeviceAvailable:
                print("newDeviceAvailable")
                break
            case .oldDeviceUnavailable:
                print("oldDeviceUnavailable")
                break
            case .routeConfigurationChange:
                print("routeConfigurationChange")
                break
            case .unknown:
                if let previousRoute = userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                    print("previous route outputs: \(previousRoute.outputs)")
                }
                break
            default:
                break
            }
        }
    }
}

class FlutterRoutePickerDelegate : NSObject, AVRoutePickerViewDelegate {
    let _methodChannel: FlutterMethodChannel

    init(viewId: Int64, messenger: FlutterBinaryMessenger) {
        _methodChannel = FlutterMethodChannel(name: "flutter_to_airplay#\(viewId)", binaryMessenger: messenger)
    }

    func routePickerViewWillBeginPresentingRoutes(_ routePickerView: AVRoutePickerView) {
        _methodChannel.invokeMethod("onShowPickerView", arguments: nil)
    }

    func routePickerViewDidEndPresentingRoutes(_ routePickerView: AVRoutePickerView) {
        _methodChannel.invokeMethod("onClosePickerView", arguments: nil)
    }
}

func isAirplaying() -> Bool {
    let nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
    
    let route = AVAudioSession.sharedInstance().currentRoute

    for output in route.outputs where output.portType == AVAudioSession.Port.airPlay {
        return false
    }
    
    return true
}
