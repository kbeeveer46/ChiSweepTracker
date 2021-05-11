struct NewsModel: Decodable {
    
  var id: Int
  var body: String
  var date: String
  var subject: String
  
  enum CodingKeys: String, CodingKey {
    
    case id
    case body
    case date
    case subject
    
  }
    
}
