//
//  Screen.swift
//  GatheredKit
//
//  Created by Joseph Duffy on 04/02/2017.
//  Copyright © 2017 Joseph Duffy. All rights reserved.
//

import UIKit

/**
 A wrapper around `UIScreen`
 */
open class Screen: AutomaticallyUpdatingDataSource, ManuallyUpdatableDataSource {

    private enum State {
        case notMonitoring
        case monitoring(brightnessChangeObeserver: NSObjectProtocol)
    }

    /// A boolean indicating if the data source is available on the current device
    public static var isAvailable = true

    /// A user-friendly name for the data source
    public static var displayName = "Screen"

    /// A boolean indicating if the screen is monitoring for brightness changes
    public var isMonitoring: Bool {
        switch state {
        case .notMonitoring:
            return false
        case .monitoring(_):
            return true
        }
    }

    /// A delegate that will receive messages about the screen's data changing
    public weak var delegate: DataSourceDelegate?

    /// The `ScreenBackingData` this `Screen` represents
    public let screen: ScreenBackingData

    /**
     An array of the information about the screen, in the following order:
     
      - Screen Resolution (reported)
      - Screen Resolution (native)
      - Screen Resolution (reported)
      - Screen Resolution (native)
      - Brightness
    */
    public var data: [DataSourceData] {
        return [
            reportedScreenResolution,
            nativeScreenResolution,
            reportedScreenScale,
            nativeScreenScale,
            brightness,
        ]
    }

    /// The screen resolution reported by the system. This is measured in points. The `formattedValue`
    /// property will contain the value formatted in the following way: "\(width) x \(height)"
    public private(set) var reportedScreenResolution: TypedDataSourceData<CGSize>

    /// The native resolution of the screen. This is measured in pixels. The `formattedValue`
    /// property will contain the value formatted in the following way: "\(width) x \(height)"
    public private(set) var nativeScreenResolution: TypedDataSourceData<CGSize>

    /// The natural scale factor associated with the screen
    public private(set) var reportedScreenScale: TypedDataSourceData<CGFloat>

    /// The native scale factor for the physical screen
    public private(set) var nativeScreenScale: TypedDataSourceData<CGFloat>

    /// The brightness level of the screen. The value of this property will be a number between
    /// 0.0 and 1.0, inclusive. The value is represented as a percentage by default
    public private(set) var brightness: TypedDataSourceData<CGFloat>

    private var state: State = .notMonitoring

    /**
     Create a new instance of `Screen` for the given `UIScreen` instance
     
     - parameter screen: The `UIScreen` to get data from
    */
    public required init(screen: ScreenBackingData = UIScreen.main) {
        self.screen = screen
        reportedScreenResolution = TypedDataSourceData(displayName: "Screen Resolution (reported)", unit: Point())
        nativeScreenResolution = TypedDataSourceData(displayName: "Screen Resolution (native)", unit: Pixel())
        reportedScreenScale = TypedDataSourceData(displayName: "Screen Resolution (reported)")
        nativeScreenScale = TypedDataSourceData(displayName: "Screen Resolution (native)")
        brightness = TypedDataSourceData(displayName: "Brightness", unit: Percent())
    }

    deinit {
        stopMonitoring()
    }

    /**
     Start automatically monitoring changes to the data source. This will start delegate methods being called
     when new data is available
     */
    public func startMonitoring() {
        guard !isMonitoring else { return }

        let brightnessChangeObeserver = NotificationCenter.default.addObserver(forName: .UIScreenBrightnessDidChange, object: screen, queue: .main) { [weak self] _ in
            guard let `self` = self else { return }

            self.brightness.value = self.screen.brightness
            self.notifyListenersDataUpdated()
        }

        state = .monitoring(brightnessChangeObeserver: brightnessChangeObeserver)

        refreshData()
        notifyListenersDataUpdated()
    }

    /**
     Stop performing automatic date refreshes
     */
    public func stopMonitoring() {
        guard case .monitoring(let brightnessChangeObeserver) = state else { return }

        NotificationCenter.default.removeObserver(brightnessChangeObeserver)

        state = .notMonitoring
    }

    /**
     Update and return the information about the screen
     
     - returns: The new data
     */
    @discardableResult
    public func refreshData() -> [DataSourceData] {
        let resolution = screen.bounds.size
        let nativeResolution = screen.nativeBounds.size

        reportedScreenResolution.value = resolution
        reportedScreenResolution.formattedValue = formattedString(for: resolution)

        nativeScreenResolution.value = nativeResolution
        nativeScreenResolution.formattedValue = formattedString(for: nativeResolution)

        reportedScreenScale.value = screen.scale

        nativeScreenScale.value = screen.nativeScale

        brightness.value = screen.brightness

        return data
    }

    /**
     Generates and returns a human-friendly string that represents the given size. String will be in the format:
     
     "\(width) x \(height)"
     
     Numeric values (width and height) will be formatted using a `NumberFormatter`
     
     - parameter size: The size to be formatted
     
     - returns: The formatted string
    */
    internal func formattedString(for size: CGSize) -> String {
        let formatter = NumberFormatter()
        let widthString = formatter.string(from: size.width as NSNumber) ?? "\(size.width)"
        let heightString = formatter.string(from: size.height as NSNumber) ?? "\(size.height)"

        return "\(widthString) x \(heightString)"
    }

}

/**
 The backing data for the `Screen` data source. `UIScreen` conforms to this without any changes
 */
public protocol ScreenBackingData {

    /// Bounds of entire screen in points
    var bounds: CGRect { get }

    /// The natural scale factor associated with the screen.
    var scale: CGFloat { get }

    /// Native bounds of the physical screen in pixels
    var nativeBounds: CGRect { get }

    /// Native scale factor of the physical screen
    var nativeScale: CGFloat { get }

    /// 0 ... 1.0, where 1.0 is maximum brightness
    var brightness: CGFloat { get }

}

extension UIScreen: ScreenBackingData {}
