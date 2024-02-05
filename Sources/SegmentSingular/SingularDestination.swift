import Foundation
import Segment
import Singular

@objc(SEGSingularDestination)
public class ObjCSegmentBugsnag: NSObject, ObjCPlugin, ObjCPluginShim {
    public func instance() -> EventPlugin { return SingularDestination() }
}

fileprivate let SEGMENT_WRAPPER_NAME = "Segment"
fileprivate let SEGMENT_WRAPPER_VERSION = "main"
fileprivate let SEGMENT_REVENUE_KEY: String = "revenue"
fileprivate let SEGMENT_CURRENCY_KEY = "currency"
fileprivate let DEFAULT_CURRENCY = "USD"

public class SingularDestination: DestinationPlugin {
    public let timeline = Timeline()
    public let type = PluginType.destination
    public let key = "Singular"
    public var analytics: Analytics? = nil
                
    public init() { }

    public func update(settings: Settings, type: UpdateType) {
        // Skip if you have a singleton and don't want to keep updating via settings.
        guard type == .initial else {
            return
        }

        Singular.setWrapperName(SEGMENT_WRAPPER_NAME, andVersion: SEGMENT_WRAPPER_VERSION)

        guard let singularSettings: SingularSettings = settings.integrationSettings(forPlugin: self) else {
            return
        }

        guard let config = SingularConfig(apiKey: singularSettings.apiKey, andSecret: singularSettings.secret) else {
            return
        }

        config.skAdNetworkEnabled = singularSettings.skAdNetworkEnabled
        config.manualSkanConversionManagement = singularSettings.manualSkanConversionManagement
        // config.conversionValueUpdatedCallback = singularSettings.conversionValueUpdatedCallback
        config.waitForTrackingAuthorizationWithTimeoutInterval = singularSettings.waitForTrackingAuthorizationWithTimeoutInterval

        Singular.start(config)

    }

    
    public func identify(event: IdentifyEvent) -> IdentifyEvent? {
        
        if let userId = event.userId, 
            userId.isEmpty == false {
            Singular.setCustomUserId(userId)
        }

        return event

    }
    
    public func track(event: TrackEvent) -> TrackEvent? {

        guard let properties = event.properties?.dictionaryValue else {
            return event
        }

        if let revenue = properties[SEGMENT_REVENUE_KEY] as? Double {

            var currency = DEFAULT_CURRENCY
            if let currencyKey = properties[SEGMENT_CURRENCY_KEY] as? String {
                currency = currencyKey
            }

            Singular.customRevenue(event.event, currency: currency, amount: revenue)

        } else {
            Singular.event(event.event, withArgs: event.properties?.dictionaryValue)
        }

        return event

    }
    
    public func reset() {
        Singular.unsetCustomUserId()
    }
 
}

extension SingularDestination: VersionedPlugin {
    public static func version() -> String {
        return __destination_version
    }
}

private struct SingularSettings: Codable {
    let apiKey: String
    let secret: String
    let skAdNetworkEnabled: Bool
    let manualSkanConversionManagement: Bool
    let waitForTrackingAuthorizationWithTimeoutInterval: Int
}

