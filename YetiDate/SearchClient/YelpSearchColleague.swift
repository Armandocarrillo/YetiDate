import CoreLocation
import YelpAPI

public class YelpSearchColleague {
  
  public let category: YelpCategory
  public private(set) var selectedBusiness: YLPBusiness?
  //To search around the user s location
  private var colleagueCoordinate: CLLocationCoordinate2D?
  private unowned let mediator: SearchColleagueMediating
  private var userCoordinate: CLLocationCoordinate2D?
  private let yelpClient: YLPClient
  //to limiting search resultsñ
  private static let defaultQueryLimit = UInt(20)
  private static let defaultQuerySort = YLPSortType.bestMatched
  private var queryLimit = defaultQueryLimit
  private var querySort = defaultQuerySort
  
  public init(category: YelpCategory, mediator: SearchColleagueMediating) {
    self.category = category
    self.mediator = mediator
    self.yelpClient = YLPClient(apiKey: YelpAPIKey)
  }

}

//MARK: - SearchColleague
  
extension YelpSearchColleague: SearchColleague {


  

    public func fellowColleague(_ colleague: SearchColleague, didSelect business: YLPBusiness) {
      colleagueCoordinate = CLLocationCoordinate2D(business.location.coordinate)
      queryLimit /= 2
      querySort = .distance
      performSearch()
    }
    public func update(userCoordinate: CLLocationCoordinate2D) {
      self.userCoordinate = userCoordinate
      performSearch()
    }
    
    public func reset(){
      colleagueCoordinate = nil
      queryLimit = YelpSearchColleague.defaultQueryLimit
      querySort = YelpSearchColleague.defaultQuerySort
      selectedBusiness = nil
      performSearch()
      
    }
    
    private func performSearch(){
     //to validate selectedBussines is nil
      guard selectedBusiness == nil,
        let coordinate = colleagueCoordinate ?? userCoordinate else { return }
      
      let yelpCoordinate = YLPCoordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
      
      let query = YLPQuery(coordinate: yelpCoordinate)
      query.categoryFilter = [category.rawValue]
      query.limit = queryLimit
      query.sort = querySort
      
      yelpClient.search(with: query) {
        [weak self] (search, error) in
        guard let self = self else { return }
        guard let search = search else {
          self.mediator.searchColleague(self, searchFailed: error)
          return
        }
        
        var set: Set<BusinessMapViewModel> = []
        for business in search.businesses {
          guard let coordinate = business.location.coordinate else { continue }
          let viewModel = BusinessMapViewModel(business: business, coordinate: coordinate, primaryCategory: self.category, onSelect: { [weak self] business in
            guard let self = self else { return }
            self.selectedBusiness = business
            self.mediator.searchColleague(self, didSelect: business)
          })
          set.insert(viewModel)
        }
        
        DispatchQueue.main.async {
          self.mediator.searchColleague(self, didCreate: set)
        }
      }
      
      
      
      
    }
  }

  

