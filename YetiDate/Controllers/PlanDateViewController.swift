
import MapKit
import UIKit
import YelpAPI

public class PlanDateViewController: UIViewController {

  // MARK: - Instance Properties
  private let locationManager = CLLocationManager()
  private lazy var searchClient = SearchClient(delegate: self)

  private var selectedBusinessForCategory: [YelpCategory: YLPBusiness] = [:]
  private var viewModelsForCategory: [YelpCategory: Set<BusinessMapViewModel>] = [:]

  // MARK: - Outlets
  @IBOutlet weak var mapView: MKMapView!

  // MARK: - View Lifecycle
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    locationManager.requestWhenInUseAuthorization()
  }

  // MARK: - Actions
  @IBAction func resetPressed(_ sender: Any) {
    viewModelsForCategory = [:]
    mapView.removeAnnotations(mapView.annotations)
    searchClient.reset()
  }
}

// MARK: - MKMapViewDelegate
extension PlanDateViewController: MKMapViewDelegate {

  public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    centerMap(on: userLocation.coordinate)
    //the process for searching for nearby businesses.
    searchClient.update(userCoordinate: userLocation.coordinate)
  }

  private func centerMap(on coordinate: CLLocationCoordinate2D) {
    let regionRadius: CLLocationDistance = 3000
    let coordinateRegion = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
    mapView.setRegion(coordinateRegion, animated: true)
  }

  public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard let viewModel = annotation as? BusinessMapViewModel else { return nil }
    let identifier = "business"
    let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) ??
      MKAnnotationView(annotation: viewModel, reuseIdentifier: identifier)
    viewModel.configure(annotationView)
    return annotationView
  }
}

// MARK: - ReviewDateDetailsViewControllerDelegate
extension PlanDateViewController: ReviewDateDetailsViewControllerDelegate {

  public func reviewDateDetailsViewControllerDone(_ controller: ReviewDateDetailsViewController) {
    searchClient.reset()
    navigationController?.popViewController(animated: true)
  }
}

// MARK: - SearchClientDelegate
extension PlanDateViewController: SearchClientDelegate {

  public func searchClient(_ searchClient: SearchClient,
                           didSelect business: YLPBusiness,
                           for category: YelpCategory) {
    removeAnnotations(for: category)
    selectedBusinessForCategory[category] = business
  }

  public func searchClient(_ searchClient: SearchClient,
                           didCreate viewModels: Set<BusinessMapViewModel>,
                           for category: YelpCategory) {
    guard viewModels != viewModelsForCategory[category] else { return }
    viewModelsForCategory[category] = viewModels
    reloadMapView()
  }

  public func searchClient(_ searchClient: SearchClient,
                           didCompleteSelection categoryToBusiness: [YelpCategory: YLPBusiness]) {
    let viewController = ReviewDateDetailsViewController
      .instanceFromStoryboard(with: categoryToBusiness, delegate: self)
    navigationController?.pushViewController(viewController, animated: true)
  }

  public func searchClient(_ searchClient: SearchClient,
                           failedFor category: YelpCategory,
                           error: Error?) {
    print("Search failed for `\(category)` with error `\(String(describing: error))`")
  }

  private func removeAnnotations(for category: YelpCategory) {
    guard let annotations = viewModelsForCategory[category] else { return }
    viewModelsForCategory[category] = nil
    mapView.removeAnnotations(Array(annotations))
  }

  private func reloadMapView() {
    var viewModels = viewModelsForCategory.reduce([BusinessMapViewModel]()) { $0 + $1.value }
    viewModels = ContestedAnnotationTool.distributeOverlappingAnnotations(viewModels)
    mapView.removeAnnotations(mapView.annotations)
    mapView.addAnnotations(viewModels)
  }
}
