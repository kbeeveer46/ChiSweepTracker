import Intents

class GetNextSweepDayIntentHandler: NSObject, GetNextSweepDayIntentHandling {
    
    
    func handle(intent: GetNextSweepDayIntent, completion: @escaping (GetNextSweepDayIntentResponse) -> Void) {
        
        let sweepDay = "750 N Dearborn Chicago - 11/22/2021"
        completion(GetNextSweepDayIntentResponse.success(result: sweepDay))
        
    }
    

}
