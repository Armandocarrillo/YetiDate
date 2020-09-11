import YelpAPI

public protocol SearchColleagueMediating: class {
  //has selected a business
  func searchColleague(_ searchColleague: SearchColleague, didSelect business: YLPBusiness)
  //has created new view models
  func searchColleague(_ searchColleague: SearchColleague, didCreate viewModels: Set<BusinessMapViewModel>)
  //has encountered a network error
  func searchColleague(_ searchColleague: SearchColleague, searchFailed error: Error?)
  
  
}
