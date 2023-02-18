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
        } else {
            let tempView = MPVolumeView(frame: .init(x: 0.0, y: 0.0, width: 44.0, height: 44.0))
            tempView.showsVolumeSlider = false
            _flutterRoutePickerView = tempView
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
