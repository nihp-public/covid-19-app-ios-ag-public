//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

protocol Key {
    var rawValue: String { get }
    func apply(_ visitor: Visitor)
}

protocol TypedKey: Key {
    associatedtype Element
}

protocol Visitor {
    func visit<Element: Decodable>(_ key: AppInfo.AttributeKey<Element>)
}

struct AppInfo: Decodable {

    enum DeviceCapabilities: String, Codable {
        case accelerometer
        case arkit
        case armv7
        case arm64
        case autoFocusCamera = "auto-focus-camera"
        case bluetoothLE = "bluetooth-le"
        case cameraFlash = "camera-flash"
        case frontFacingCamera = "front-facing-camera"
        case gamekit
        case gps
        case gyroscope
        case healthkit
        case locationServices = "location-services"
        case magnetometer
        case metal
        case microphone
        case nfc
        case opengles1 = "opengles-1"
        case opengles2 = "opengles-2"
        case opengles3 = "opengles-3"
        case peerToPeer = "peer-peer"
        case sms
        case stillCamera = "still-camera"
        case telephony
        case videoCamera = "video-camera"
        case wifi
    }

    enum BackgroundModes: String, Codable {
        case audio
        case location
        case voip
        case fetch
        case processing
        case remoteNotification = "remote-notification"
        case newsstandContent = "newsstand-content"
        case externalAccessory = "external-accessory"
        case bluetoothCentral = "bluetooth-central"
        case bluetoothPeripheral = "bluetooth-peripheral"
    }

    enum InterfaceOrientation: String, Codable, CaseIterable {
        case portrait = "UIInterfaceOrientationPortrait"
        case portraitUpsideDown = "UIInterfaceOrientationPortraitUpsideDown"
        case left = "UIInterfaceOrientationLandscapeLeft"
        case right = "UIInterfaceOrientationLandscapeRight"
    }

    enum InterfaceStyle: String, Codable, CaseIterable {
        case automatic = "Automatic"
        case light = "Light"
        case dark = "Dark"
    }

    enum DeviceFamily: Int, Codable {
        case iPhone = 1
        case iPad = 2

        var displayName: String {
            switch self {
            case .iPhone: return "iPhone"
            case .iPad: return "iPad"
            }
        }
    }

    struct PrimaryIcon: Decodable {
        private enum CodingKeys: String, CodingKey {
            case name = "CFBundleIconName"
            case files = "CFBundleIconFiles"
        }

        var name: String
        var files: [String]
    }

    struct Icons: Decodable {
        private enum CodingKeys: String, CodingKey {
            case primary = "CFBundlePrimaryIcon"
        }

        var primary: PrimaryIcon
    }

    struct AttributeKey<Element: Decodable>: TypedKey {

        var rawValue: String
        var keyPath: WritableKeyPath<AppInfo, Decoded<Element>?>

        init(_ key: KnownCodingKeys, keyPath: WritableKeyPath<AppInfo, Decoded<Element>?>) {
            rawValue = key.stringValue
            self.keyPath = keyPath
        }

        func apply(_ visitor: Visitor) {
            visitor.visit(self)
        }

    }

    // Documentation: https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/iPhoneOSKeys.html
    // Note that keys injected by Xcode (e.g. `DTCompiler`) are not documented.
    enum KnownCodingKeys: String, CodingKey {
        case bundleName = "CFBundleName"
        case version = "CFBundleShortVersionString"
        case bundleVersion = "CFBundleVersion"
        case minimumOSVersion = "MinimumOSVersion"
        case bundleIdentifier = "CFBundleIdentifier"
        case buildMachineOS = "BuildMachineOSBuild"
        case bundleDevelopmentRegion = "CFBundleDevelopmentRegion"
        case bundleDisplayName = "CFBundleDisplayName"
        case bundleExecutable = "CFBundleExecutable"
        case bundleInfoDictionaryVersion = "CFBundleInfoDictionaryVersion"
        case bundlePackageType = "CFBundlePackageType"
        case bundleSupportedPlatforms = "CFBundleSupportedPlatforms"
        case bundleIcons = "CFBundleIcons"
        case bundleIconsForIpad = "CFBundleIcons~ipad"
        case backgroundTaskIdentifiers = "BGTaskSchedulerPermittedIdentifiers"
        case deviceFamily = "UIDeviceFamily"
        case compiler = "DTCompiler"
        case platformBuild = "DTPlatformBuild"
        case platformName = "DTPlatformName"
        case platformVersion = "DTPlatformVersion"
        case sdkBuild = "DTSDKBuild"
        case sdkName = "DTSDKName"
        case xcode = "DTXcode"
        case xcodeBuild = "DTXcodeBuild"
        case appStoreToolsBuild = "DTAppStoreToolsBuild"
        case requiresIPhoneOS = "LSRequiresIPhoneOS"
        case launchStoryboardName = "UILaunchStoryboardName"
        case requiredDeviceCapabilities = "UIRequiredDeviceCapabilities"
        case requiredBackgroundModes = "UIBackgroundModes"
        case supportedInterfaceOrientations = "UISupportedInterfaceOrientations"
        case supportedInterfaceOrientationsForIpad = "UISupportedInterfaceOrientations~ipad"
        case supportedInterfaceStyles = "UIUserInterfaceStyle"
        case bluetoothAlwaysUsageDescription = "NSBluetoothAlwaysUsageDescription"
        case bluetoothPeripheralUsageDescription = "NSBluetoothPeripheralUsageDescription"
        case cameraUsageDescription = "NSCameraUsageDescription"
        case exposureNotificationAPIVersion = "ENAPIVersion"
        case exposureNotificationDeveloperRegion = "ENDeveloperRegion"
        case appUsesNonExemptEncryption = "ITSAppUsesNonExemptEncryption"
    }

    struct Attributes {
        static let bundleName = AttributeKey(.bundleName, keyPath: \.bundleName)
        static let version = AttributeKey(.version, keyPath: \.version)
        static let bundleVersion = AttributeKey(.bundleVersion, keyPath: \.bundleVersion)
        static let minimumOSVersion = AttributeKey(.minimumOSVersion, keyPath: \.minimumOSVersion)
        static let bundleIdentifier = AttributeKey(.bundleIdentifier, keyPath: \.bundleIdentifier)
        static let buildMachineOS = AttributeKey(.buildMachineOS, keyPath: \.buildMachineOS)
        static let bundleDevelopmentRegion = AttributeKey(.bundleDevelopmentRegion, keyPath: \.bundleDevelopmentRegion)
        static let bundleDisplayName = AttributeKey(.bundleDisplayName, keyPath: \.bundleDisplayName)
        static let bundleExecutable = AttributeKey(.bundleExecutable, keyPath: \.bundleExecutable)
        static let bundleInfoDictionaryVersion = AttributeKey(.bundleInfoDictionaryVersion, keyPath: \.bundleInfoDictionaryVersion)
        static let bundlePackageType = AttributeKey(.bundlePackageType, keyPath: \.bundlePackageType)
        static let bundleSupportedPlatforms = AttributeKey(.bundleSupportedPlatforms, keyPath: \.bundleSupportedPlatforms)
        static let bundleIcons = AttributeKey(.bundleIcons, keyPath: \.bundleIcons)
        static let bundleIconsForIpad = AttributeKey(.bundleIconsForIpad, keyPath: \.bundleIconsForIpad)
        static let backgroundTaskIdentifiers = AttributeKey(.backgroundTaskIdentifiers, keyPath: \.backgroundTaskIdentifiers)
        static let deviceFamily = AttributeKey(.deviceFamily, keyPath: \.deviceFamily)
        static let compiler = AttributeKey(.compiler, keyPath: \.compiler)
        static let platformBuild = AttributeKey(.platformBuild, keyPath: \.platformBuild)
        static let platformName = AttributeKey(.platformName, keyPath: \.platformName)
        static let platformVersion = AttributeKey(.platformVersion, keyPath: \.platformVersion)
        static let sdkBuild = AttributeKey(.sdkBuild, keyPath: \.sdkBuild)
        static let sdkName = AttributeKey(.sdkName, keyPath: \.sdkName)
        static let xcode = AttributeKey(.xcode, keyPath: \.xcode)
        static let xcodeBuild = AttributeKey(.xcodeBuild, keyPath: \.xcodeBuild)
        static let appStoreToolsBuild = AttributeKey(.appStoreToolsBuild, keyPath: \.appStoreToolsBuild)
        static let requiresIPhoneOS = AttributeKey(.requiresIPhoneOS, keyPath: \.requiresIPhoneOS)
        static let launchStoryboardName = AttributeKey(.launchStoryboardName, keyPath: \.launchStoryboardName)
        static let requiredBackgroundModes = AttributeKey(.requiredBackgroundModes, keyPath: \.requiredBackgroundModes)
        static let requiredDeviceCapabilities = AttributeKey(.requiredDeviceCapabilities, keyPath: \.requiredDeviceCapabilities)
        static let supportedInterfaceOrientations = AttributeKey(.supportedInterfaceOrientations, keyPath: \.supportedInterfaceOrientations)
        static let supportedInterfaceOrientationsForIpad = AttributeKey(.supportedInterfaceOrientationsForIpad, keyPath: \.supportedInterfaceOrientationsForIpad)
        static let supportedInterfaceStyles = AttributeKey(.supportedInterfaceStyles, keyPath: \.supportedInterfaceStyles)
        static let bluetoothAlwaysUsageDescription = AttributeKey(.bluetoothAlwaysUsageDescription, keyPath: \.bluetoothAlwaysUsageDescription)
        static let bluetoothPeripheralUsageDescription = AttributeKey(.bluetoothPeripheralUsageDescription, keyPath: \.bluetoothPeripheralUsageDescription)
        static let cameraUsageDescription = AttributeKey(.cameraUsageDescription, keyPath: \.cameraUsageDescription)
        static let exposureNotificationAPIVersion = AttributeKey(.exposureNotificationAPIVersion, keyPath: \.exposureNotificationAPIVersion)
        static let exposureNotificationDeveloperRegion = AttributeKey(.exposureNotificationDeveloperRegion, keyPath: \.exposureNotificationDeveloperRegion)
        static let appUsesNonExemptEncryption = AttributeKey(.appUsesNonExemptEncryption, keyPath: \.appUsesNonExemptEncryption)

        static let allCases: [Key] = [
            bundleName,
            version,
            bundleVersion,
            minimumOSVersion,
            bundleIdentifier,
            buildMachineOS,
            bundleDevelopmentRegion,
            bundleDisplayName,
            bundleExecutable,
            bundleInfoDictionaryVersion,
            bundlePackageType,
            bundleSupportedPlatforms,
            bundleIcons,
            bundleIconsForIpad,
            backgroundTaskIdentifiers,
            deviceFamily,
            compiler,
            platformBuild,
            platformName,
            platformVersion,
            sdkBuild,
            sdkName,
            xcode,
            xcodeBuild,
            appStoreToolsBuild,
            requiresIPhoneOS,
            launchStoryboardName,
            requiredDeviceCapabilities,
            requiredBackgroundModes,
            supportedInterfaceOrientations,
            supportedInterfaceOrientationsForIpad,
            supportedInterfaceStyles,
            bluetoothAlwaysUsageDescription,
            bluetoothPeripheralUsageDescription,
            cameraUsageDescription,
            exposureNotificationAPIVersion,
            exposureNotificationDeveloperRegion,
            appUsesNonExemptEncryption,
        ]

        fileprivate static let knownKeyRawValues = Set(allCases.map { $0.rawValue })
    }

    private struct PropertyListKey: CodingKey, Hashable {
        var stringValue: String

        init(_ key: Key) {
            stringValue = key.rawValue
        }

        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        init?(intValue: Int) {
            nil
        }

        var intValue: Int? {
            nil
        }

    }

    struct ParseError {
        var key: String
        var error: String
    }

    var bundleName: Decoded<String>?
    var version: Decoded<String>?
    var bundleVersion: Decoded<String>?
    var bundleDisplayName: Decoded<String>?
    var minimumOSVersion: Decoded<String>?
    var bundleIdentifier: Decoded<String>?
    var buildMachineOS: Decoded<String>?
    var bundleDevelopmentRegion: Decoded<String>?
    var bundleExecutable: Decoded<String>?
    var bundleInfoDictionaryVersion: Decoded<String>?
    var bundlePackageType: Decoded<String>?
    var bundleSupportedPlatforms: Decoded<Set<String>>?
    var bundleIcons: Decoded<Icons>?
    var bundleIconsForIpad: Decoded<Icons>?
    var backgroundTaskIdentifiers: Decoded<[String]>?
    var deviceFamily: Decoded<[DeviceFamily]>?
    var compiler: Decoded<String>?
    var platformBuild: Decoded<String>?
    var platformName: Decoded<String>?
    var platformVersion: Decoded<String>?
    var sdkBuild: Decoded<String>?
    var sdkName: Decoded<String>?
    var xcode: Decoded<String>?
    var xcodeBuild: Decoded<String>?
    var appStoreToolsBuild: Decoded<String>?
    var requiresIPhoneOS: Decoded<Bool>?
    var launchStoryboardName: Decoded<String>?
    var requiredDeviceCapabilities: Decoded<Set<DeviceCapabilities>>?
    var requiredBackgroundModes: Decoded<Set<BackgroundModes>>?
    var supportedInterfaceOrientations: Decoded<Set<InterfaceOrientation>>?
    var supportedInterfaceOrientationsForIpad: Decoded<Set<InterfaceOrientation>>?
    var supportedInterfaceStyles: Decoded<InterfaceStyle>?
    var bluetoothAlwaysUsageDescription: Decoded<String>?
    var bluetoothPeripheralUsageDescription: Decoded<String>?
    var cameraUsageDescription: Decoded<String>?
    var exposureNotificationAPIVersion: Decoded<String>?
    var exposureNotificationDeveloperRegion: Decoded<String>?
    var appUsesNonExemptEncryption: Decoded<Bool>?

    var unknownKeys: Set<String>

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PropertyListKey.self)

        class AttrVisitor: Visitor {
            var info: AppInfo!
            var container: KeyedDecodingContainer<PropertyListKey>!

            func visit<Element>(_ attribute: AppInfo.AttributeKey<Element>) where Element: Decodable {
                let key = PropertyListKey(attribute)
                info[keyPath: attribute.keyPath] = try! container.decodeIfPresent(Decoded<Element>.self, forKey: key)
                info.unknownKeys.remove(key.stringValue)
            }
        }

        unknownKeys = Set(container.allKeys.map { $0.stringValue })

        let visitor = AttrVisitor()
        visitor.container = container
        visitor.info = self
        Attributes.allCases.forEach { $0.apply(visitor) }

        self = visitor.info

    }

    func value<Element>(for key: KeyPath<AppInfo, Decoded<Element>?>) -> Element? {
        let value = self[keyPath: key]
        switch value {
        case .some(.some(let element)):
            return element
        default:
            return nil
        }
    }

    var parseErrors: [ParseError] {
        class AttrVisitor: Visitor {
            var info: AppInfo!
            var parseErrors: [ParseError] = []

            func visit<Element>(_ attribute: AppInfo.AttributeKey<Element>) where Element: Decodable {
                let value = info![keyPath: attribute.keyPath]
                switch value {
                case .some(.error(let error)):
                    let debugDescription = (error as NSError).userInfo[NSDebugDescriptionErrorKey] as? String
                    let errorMessage = debugDescription ?? error.localizedDescription
                    parseErrors.append(ParseError(key: attribute.rawValue, error: errorMessage))
                default:
                    break
                }
            }
        }

        let visitor = AttrVisitor()
        visitor.info = self
        Attributes.allCases.forEach { $0.apply(visitor) }
        return visitor.parseErrors
    }

}
