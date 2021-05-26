import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        switch intent {
        case is GetNextSweepDayIntent:
            return GetNextSweepDayIntentHandler()
        default:
            fatalError("No handler for this intent")
        }
    }
}
