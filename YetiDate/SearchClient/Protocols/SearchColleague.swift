import CoreLocation.CLLocation
import YelpAPI
//class protocol
public protocol SearchColleague: class {
  
  var category: YelpCategory { get }
  var selectedBusiness: YLPBusiness? { get }
  //to indicate that the user s location has been updated
  func update(userCoordinate: CLLocationCoordinate2D)
  // to indicate to the other colleagues that given colleague has selected a business
  func fellowColleague(_ colleague: SearchColleague, didSelect business: YLPBusiness)
  //to remove any selectedBusiness
  func reset()
  
}
