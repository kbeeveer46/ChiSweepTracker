
public class Constants {
    
    // Database tables
    
    #if DEBUG
    let addressesDatabaseName = "addresses_dev"
    let schedulesDatabaseName = "schedules_dev"
    let updatesDatabaseName = "updates_dev"
    let divvysDatabaseName = "divvys_dev"
    let towedDatabaseName = "towed_vehicles_dev"
    let relocatedDatabaseName = "relocated_vehicles_dev"
    let newsDatabaseName = "news_dev"
    let infoDatabaseName = "info_dev"
    let notificationsDatabaseName = "notifications_dev"
    #else
    let addressesDatabaseName = "addresses"
    let schedulesDatabaseName = "schedules"
    let updatesDatabaseName = "updates"
    let divvysDatabaseName = "divvys"
    let towedDatabaseName = "towed_vehicles"
    let relocatedDatabaseName = "relocated_vehicles"
    let newsDatabaseName = "news"
    let infoDatabaseName = "info"
    let notificationsDatabaseName = "notifications"
    #endif
    
    // One Signal
    let OneSignalAppId = "2a6b2ed6-b4a7-4da0-8917-899cef558a0a"
    
    // Multiple addresses in-app purchase
    let multipleAddressIAPurchase = "com.kylebeverforden.chisweeptracker.savemultipleaddresses"
    
    // SODA
    let SODAToken = "dM3SUsRUNwyTWQGy83lvBv4X3"
    let SODADomain = "data.cityofchicago.org"
    
    // Strings
    let websiteURL = "https://chicagosweeptracker.info"
    
    let errorTitle = "Something went wrong..."
    let notFound = "Unable to find sweep schedule. Address must reside in Chicago."
    
    let finishedScheduleMessage = "Sweeping has ended for _currentYear_."
    let beginScheduleMessage = "Sweeping will begin on April 1st in _amount_ day(s)."
    let noInternetConnectionSearchMessage = "Unable to find sweep schedule. This may be caused by not having an internet connection or the Chicago API may be down for scheduled maintenance. Please try again in a few hours."
    
    // Colors
    let systemRed = "#ff3b30"
    let systemBlue = "#007aff"
    let divvy = "#3fb5e7"
    let background = "#f2f2f2"
}

