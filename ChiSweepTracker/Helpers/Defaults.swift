import Foundation

let defaults = UserDefaults.standard

public class Defaults {
    
    // Shared
    
    func deviceUUID() -> String { return defaults.string(forKey: "deviceUUID") ?? ""}
    func latestAppVersion() -> Int { return defaults.integer(forKey: "latestAppVersion")}
    func latestDatasetVersion() -> Int {return defaults.integer(forKey: "latestDatasetVersion")}
    func userDatasetVersion() -> Int {return defaults.integer(forKey: "userDatasetVersion")}
    func enableMultipleAddresses() -> Bool {return defaults.bool(forKey: "enableMultipleAddresses")}
    func gettingValuesFromDatabase() -> Bool {return defaults.bool(forKey: "gettingValuesFromDatabase")}
    
    func defaultAddress() -> String {return defaults.string(forKey: "defaultAddress") ?? ""}
    func defaultLongitude() -> Double {return defaults.double(forKey: "defaultLongitude")}
    func defaultLatitude() -> Double {return defaults.double(forKey: "defaultLatitude")}
    func defaultCoordinatesArray() -> [[NSArray]] {return defaults.object(forKey: "defaultCoordinatesArray") as! [[NSArray]]}
    func selectedAnnotationLongitude() -> Double {return defaults.double(forKey: "selectedAnnotationLongitude")}
    func selectedAnnotationLatitude() -> Double {return defaults.double(forKey: "selectedAnnotationLatitude")}
    
    // Schedule
    
    func dates() -> String {return defaults.string(forKey: "datesTitle") ?? ""}
    func monthNumberTitle() -> String {return defaults.string(forKey: "monthNumberTitle") ?? ""}
    func monthNameTitle() -> String {return defaults.string(forKey: "monthNameTitle") ?? ""}
    func coordinatesTitle() -> String {return defaults.string(forKey: "coordinatesTitle") ?? ""}
    func sectionTitle() -> String {return defaults.string(forKey: "sectionTitle") ?? ""}
    func wardTitle() -> String {return defaults.string(forKey: "wardTitle") ?? ""}
    func geomTitle() -> String {return defaults.string(forKey: "geomTitle") ?? ""}
    func scheduleDataset() -> String {return defaults.string(forKey: "scheduleDataset") ?? ""}
    func wardDataset() -> String {return defaults.string(forKey: "wardDataset") ?? ""}
    
    // Divvy
    
    func divvyDataset() -> String {return defaults.string(forKey: "divvyDataset") ?? ""}
    func divvyIdTitle() -> String {return defaults.string(forKey: "divvyIdTitle") ?? ""}
    func divvyDocksInServiceTitle() -> String {return defaults.string(forKey: "divvyDocksInServiceTitle") ?? ""}
    func divvyLatitudeTitle() -> String {return defaults.string(forKey: "divvyLatitudeTitle") ?? ""}
    func divvyLongitudeTitle() -> String {return defaults.string(forKey: "divvyLongitudeTitle") ?? ""}
    func divvyStationNameTitle() -> String {return defaults.string(forKey: "divvyStationNameTitle") ?? ""}
    func divvyStatusTitle() -> String {return defaults.string(forKey: "divvyStatusTitle") ?? ""}
    
    func divvyJSONUrl() -> String {return defaults.string(forKey: "divvyJSONUrl") ?? ""}
    func divvyJSONBikesAvailableTitle() -> String {return defaults.string(forKey: "divvyJSONBikesAvailableTitle") ?? ""}
    func divvyJSONEBikesAvailableTitle() -> String {return defaults.string(forKey: "divvyJSONEBikesAvailableTitle") ?? ""}
    func divvyJSONDocksAvailableTitle() -> String {return defaults.string(forKey: "divvyJSONDocksAvailableTitle") ?? ""}
    func divvyJSONDataTitle() -> String {return defaults.string(forKey: "divvyJSONDataTitle") ?? ""}
    func divvyJSONStationsTitle() -> String {return defaults.string(forKey: "divvyJSONStationsTitle") ?? ""}
    func divvyJSONIdTitle() -> String {return defaults.string(forKey: "divvyJSONIdTitle") ?? ""}
    func divvyJSONLastUpdatedTitle() -> String {return defaults.string(forKey: "divvyJSONLastUpdatedTitle") ?? ""}
    
    // Towed vehicles
    
    func towedDataset() -> String {return defaults.string(forKey: "towedDataset") ?? ""}
    func towedColorTitle() -> String {return defaults.string(forKey: "towedColorTitle") ?? ""}
    func towedInventoryNumberTitle() -> String {return defaults.string(forKey: "towedInventoryNumberTitle") ?? ""}
    func towedMakeTitle() -> String {return defaults.string(forKey: "towedMakeTitle") ?? ""}
    func towedModelTitle() -> String {return defaults.string(forKey: "towedModelTitle") ?? ""}
    func towedPlateTitle() -> String {return defaults.string(forKey: "towedPlateTitle") ?? ""}
    func towedStateTitle() -> String {return defaults.string(forKey: "towedStateTitle") ?? ""}
    func towedStyleTitle() -> String {return defaults.string(forKey: "towedStyleTitle") ?? ""}
    func towedDateTitle() -> String {return defaults.string(forKey: "towedDateTitle") ?? ""}
    func towedToAddressTitle() -> String {return defaults.string(forKey: "towedToAddressTitle") ?? ""}
    func towedToPhoneTitle() -> String {return defaults.string(forKey: "towedToPhoneTitle") ?? ""}
    
    // Relocated vehicles
    
    func relocatedDataset() -> String {return defaults.string(forKey: "relocatedDataset") ?? ""}
    func relocatedColorTitle() -> String {return defaults.string(forKey: "relocatedColorTitle") ?? ""}
    func relocatedMakeTitle() -> String {return defaults.string(forKey: "relocatedMakeTitle") ?? ""}
    func relocatedPlateTitle() -> String {return defaults.string(forKey: "relocatedPlateTitle") ?? ""}
    func relocatedDateTitle() -> String {return defaults.string(forKey: "relocatedDateTitle") ?? ""}
    func relocatedFromLatitudeTitle() -> String {return defaults.string(forKey: "relocatedFromLatitudeTitle") ?? ""}
    func relocatedFromLongitudeTitle() -> String {return defaults.string(forKey: "relocatedFromLongitudeTitle") ?? ""}
    func relocatedFromAddressNumberTitle() -> String {return defaults.string(forKey: "relocatedFromAddressNumberTitle") ?? ""}
    func relocatedFromDirectionTitle() -> String {return defaults.string(forKey: "relocatedFromDirectionTitle") ?? ""}
    func relocatedFromStreetTitle() -> String {return defaults.string(forKey: "relocatedFromStreetTitle") ?? ""}
    func relocatedReasonTitle() -> String {return defaults.string(forKey: "relocatedReasonTitle") ?? ""}
    func relocatedToAddressNumberTitle() -> String {return defaults.string(forKey: "relocatedToAddressNumberTitle") ?? ""}
    func relocatedToDirectionTitle() -> String {return defaults.string(forKey: "relocatedToDirectionTitle") ?? ""}
    func relocatedToStreetTitle() -> String {return defaults.string(forKey: "relocatedToStreetTitle") ?? ""}
    func relocatedStateTitle() -> String {return defaults.string(forKey: "relocatedStateTitle") ?? ""}
    
    // Favorites
    
    func favoriteAddress() -> String {return defaults.string(forKey: "favoriteAddress") ?? ""}
    func showDivvyStations() -> Bool {return defaults.bool(forKey: "showDivvyStations")}
    func showTowedVehicles() -> Bool {return defaults.bool(forKey: "showTowedVehicles")}
    
    // Notifications
    
    func notificationWhen() -> String {return defaults.string(forKey: "notificationWhen") ?? ""}
    func notificationHour() -> Int {return defaults.integer(forKey: "notificationHour")}
    func notificationMinute() -> Int {return defaults.integer(forKey: "notificationMinute")}
    func notificationsToggled() -> Bool {return defaults.bool(forKey: "notificationsToggled")}
    func notificationsYear() -> Int {return defaults.integer(forKey: "notificationsYear")}
    func notificationOneSignalPlayerId() -> String {return defaults.string(forKey: "notificationOneSignalPlayerId") ?? ""}
    
    // Updates
    
    func updatesLastViewDate() -> String {return defaults.string(forKey: "updatesLastViewDate") ?? ""}
    
}
