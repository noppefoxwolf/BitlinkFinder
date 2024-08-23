import SwiftUI
import CoreLocation

@Observable
final class BeaconManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    var detectedBeacons: [CLBeacon] = []
    
    var error: (any Error)? = nil

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        startMonitoringBeacons()
    }

    private func startMonitoringBeacons() {
        let identityConstraint = CLBeaconIdentityConstraint(
            uuid: UUID(uuidString: "41462998-6CEB-4511-9D46-1F7E27AA6572")!,
            major: 18,
            minor: 5
        )
        locationManager.startRangingBeacons(satisfying: identityConstraint)
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        detectedBeacons = beacons
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = error
    }
}

struct ContentView: View {
    @State
    var beaconManager = BeaconManager()

    var body: some View {
        NavigationView {
            List {
                ForEach(beaconManager.detectedBeacons, id: \.uuid) { beacon in
                    VStack(alignment: .leading) {
                        LabeledContent("UUID", value: beacon.uuid.uuidString)
                        LabeledContent("Major", value: "\(beacon.major)")
                        LabeledContent("Minor", value: "\(beacon.minor)")
                        
                        LabeledContent {
                            switch beacon.accuracy {
                            case kCLLocationAccuracyBestForNavigation:
                                Text("BestForNavigation")
                            case kCLLocationAccuracyBest:
                                Text("Best")
                            case kCLLocationAccuracyNearestTenMeters:
                                Text("NearestTenMeters")
                            case kCLLocationAccuracyHundredMeters:
                                Text("HundredMeters")
                            case kCLLocationAccuracyKilometer:
                                Text("Kilometer")
                            case kCLLocationAccuracyThreeKilometers:
                                Text("ThreeKilometers")
                            default:
                                Text("ThreeKilometers")
                            }
                        } label: {
                            Text("Accuracy")
                        }

                        LabeledContent {
                            switch beacon.proximity {
                            case .immediate:
                                Text("Immediate (数cm～数十cm)")
                            case .near:
                                Text("Near (数m)")
                            case .far:
                                Text("Far (数十m)")
                            case .unknown:
                                Text("Unknown")
                            @unknown default:
                                Text("Unknown(default)")
                            }
                        } label: {
                            Text("Proximity")
                        }

                        LabeledContent {
                            Text(beacon.timestamp.formatted(date: .omitted, time: .complete))
                        } label: {
                            Text("Timestamp")
                        }
                        
                        Text(beacon.rssi.formatted())

                    }
                }
                
                if let error = beaconManager.error {
                    Text(error.localizedDescription).foregroundStyle(.red)
                }
            }
            .navigationTitle("Detected Beacons")
        }
    }
}

#Preview {
    Text("aaa")
}
