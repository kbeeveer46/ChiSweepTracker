import UIKit

//class UserSessionManager
//{
//    // MARK:- Properties
//
//    public static var shared = UserSessionManager()
//
//    var favoriteAddresses: [ScheduleModel]
//    {
//        get
//        {
//            guard let data = UserDefaults.standard.data(forKey: "places") else { return [] }
//            return (try? JSONDecoder().decode([ScheduleModel].self, from: data)) ?? []
//        }
//        set
//        {
//            guard let data = try? JSONEncoder().encode(newValue) else { return }
//            UserDefaults.standard.set(data, forKey: "places")
//        }
//    }
//
//    // MARK:- Init
//
//    private init(){}
//}
