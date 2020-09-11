

import YelpAPI
import CoreLocation

public class SearchClient: Mediator<SearchColleague> {

  // MARK: - Instance Properties
  public weak var delegate: SearchClientDelegate?

  // MARK: - Object Lifecycle
  public init(delegate: SearchClientDelegate) {
    self.delegate = delegate
    super.init()
    setupColleagues()
  }

  private func setupColleagues() {
    
    let restaurantColleague = YelpSearchColleague(category: .restaurants, mediator: self)
    addColleague(restaurantColleague)
    
    let barColleague = YelpSearchColleague(category: .bars, mediator: self)
    addColleague(barColleague)
    
    let movieColleague = YelpSearchColleague(category: .movieTheaters, mediator: self)
    addColleague(movieColleague)
   
  }

  // MARK: - Instance Methods
  public func update(userCoordinate: CLLocationCoordinate2D) {
   
    invokeColleagues() { colleague in colleague.update(userCoordinate: userCoordinate)}
  }

  public func reset() {
    invokeColleagues() { colleague in colleague.reset() }
  }
}

//MARK: - SearchColleagueMediating

extension SearchClient: SearchColleagueMediating {
  
  public func searchColleague(_ searchColleague: SearchColleague, didSelect business: YLPBusiness) {
    //notify the delegate that a business was selected
    delegate?.searchClient(self, didSelect: business, for: searchColleague.category)
    
    invokeColleagues(by: searchColleague) { colleague in colleague.fellowColleague(colleague, didSelect: business) }
    
    notifyDelegateIfAllBusinessesSelected()
    
  }
  
  private func notifyDelegateIfAllBusinessesSelected() {
    guard let delegate = delegate else { return }
    var categoryToBusiness: [YelpCategory : YLPBusiness] = [:]
    for colleague in colleagues {
      guard let business = colleague.selectedBusiness else { return }
      categoryToBusiness[colleague.category] = business
    }
    delegate.searchClient(self, didCompleteSelection: categoryToBusiness)
  }
  //the delegate is responsible for handling the error
  public func searchColleague(_ searchColleague: SearchColleague, didCreate viewModels: Set<BusinessMapViewModel>) {
    delegate?.searchClient(self, didCreate: viewModels, for: searchColleague.category)
  }
  
  public func searchColleague(_ searchColleague: SearchColleague, searchFailed error: Error?) {
    delegate?.searchClient(self, failedFor: searchColleague.category, error: error)
  }
  
}
