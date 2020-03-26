//
//  MapViewController.swift
//  juggernaut
//
//  Created by Helal Chowdhury on 10/11/19.
//  Copyright © 2019 Helal. All rights reserved.
//

import UIKit
import FlyoverKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in}
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        mapView.delegate = self
        userLocationSetup()
        self.mapSetup()
        
    }
    //    ALERTS AND NOTIFICATIONS
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showNotification(title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.badge = 1
        content.sound = .default
        let request = UNNotificationRequest(identifier: "notif", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    @IBAction func buttonClicked(_ sender: Any) {
        let title = "There is a Clinique Store near you!"
        let message = "Reycle any products you have with you"
        showAlert(title: title, message: message)
    }
    
    
    func mapSetup() {
        self.mapView.mapType = .hybridFlyover
        self.mapView.showsBuildings = true
        self.mapView.isZoomEnabled = true
        self.mapView.isScrollEnabled = true
        
        let camera = FlyoverCamera(mapView: self.mapView, configuration: FlyoverCamera.Configuration(duration: 3.0, altitude: 30500, pitch: 45.0, headingStep: 40.0))
        camera.start(flyover: FlyoverAwesomePlace.newYork)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(200), execute:{
            camera.stop()
        })
    }
    
    func userLocationSetup(){
        locationManager.requestAlwaysAuthorization() //we can ask this later
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 100
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType.hybrid
        }
        
    func zoomIn(_ coordinate: CLLocationCoordinate2D){
        let zoomRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(zoomRegion, animated: true)
        }
    
    func addAnnotations(){
        
        
       let timesSqaureAnnotation = MKPointAnnotation()
       timesSqaureAnnotation.title = "Clinique - 42nd St"
       timesSqaureAnnotation.coordinate = CLLocationCoordinate2D(latitude: 40.6602, longitude: -73.9985)
        
       
       let empireStateAnnotation = MKPointAnnotation()
       empireStateAnnotation.title = "Clinique - 8th Ave"
       empireStateAnnotation.coordinate = CLLocationCoordinate2D(latitude: 40.7484, longitude: -73.9857)
        
        
       let brooklynBridge = MKPointAnnotation()
       brooklynBridge.title = "Clinique - Brooklyn Bridge"
       brooklynBridge.coordinate = CLLocationCoordinate2D(latitude: 40.7061, longitude: -73.9969)

       
       let prospectPark = MKPointAnnotation()
       prospectPark.title = "Clinique - Bath Ave"
       prospectPark.coordinate = CLLocationCoordinate2D(latitude: 40.6602, longitude: -73.9690)
        

       let jersey = MKPointAnnotation()
       jersey.title = "Clinique - Hoboken"
       jersey.coordinate = CLLocationCoordinate2D(latitude: 40.7178, longitude: -74.0431)
        
        let curr = MKPointAnnotation()
        curr.coordinate = CLLocationCoordinate2D(latitude: 40.7508, longitude: -73.9387)
        
        var geofenceList = [CLCircularRegion]()
        let locations = [timesSqaureAnnotation.coordinate, empireStateAnnotation.coordinate, brooklynBridge.coordinate, prospectPark.coordinate, jersey.coordinate]
        for coor in locations{
            geofenceList.append(CLCircularRegion(center: coor, radius: 800, identifier: "geofence"))
        }
        for fence in geofenceList {
            let circle = MKCircle(center: fence.center, radius: fence.radius)
            circle.title = fence.identifier
            mapView.addOverlay(circle)
        }
       
       mapView.addAnnotation(timesSqaureAnnotation)
       mapView.addAnnotation(empireStateAnnotation)
       mapView.addAnnotation(brooklynBridge)
       mapView.addAnnotation(prospectPark)
       mapView.addAnnotation(jersey)
           
//           let col = MKPointAnnotation()
//           col.title = "Mental Health Discussion"
//           col.coordinate = CLLocationCoordinate2D(latitude: 48.7806, longitude: 2.2376)
//
//           let col2 = MKPointAnnotation()
//           col2.title = "Mental Health Discussion"
//           col2.coordinate = CLLocationCoordinate2D(latitude: 48.8606, longitude: 2.3476)
//
//           let col3 = MKPointAnnotation()
//           col3.title = "Mental Health Discussion"
//           col3.coordinate = CLLocationCoordinate2D(latitude: 48.9030, longitude: 2.3599)
//
//
//           mapView.addAnnotation(col3)
//           mapView.addAnnotation(col2)
//           mapView.addAnnotation(col)
           
           
    }
    
    func showRoute() {
           let sourceLocation = currentCoordinate ?? CLLocationCoordinate2D(latitude: 40.6742, longitude: -73.8418)
           let destinationLocation = CLLocationCoordinate2D(latitude: 40.7484, longitude: -73.9857)

           let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation)
           let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation)

           let directionRequest = MKDirections.Request()
           directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
           directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
           directionRequest.transportType = .automobile

           let directions = MKDirections(request: directionRequest)
           directions.calculate {(response, error) in
               guard let directionResponse = response else {
                   if let error = error{
                       print("There was an error getting directions==\(error.localizedDescription)")
                   }
                   return
               }
               let route = directionResponse.routes[0]
               self.mapView.addOverlay(route.polyline, level: .aboveRoads)

               let rect = route.polyline.boundingMapRect
               self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
           }

           self.mapView.delegate = self
       }
    
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
//        let renderer = MKPolylineRenderer(overlay: overlay)
//        renderer.strokeColor = UIColor.blue
//        renderer.lineWidth = 4.0
//        return renderer
//    }
    
    
    
    

}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      guard let circleOverlay = overlay as? MKCircle else { return MKOverlayRenderer()}
      let circleRenderer = MKCircleRenderer(circle: circleOverlay)
      circleRenderer.strokeColor = .blue
      circleRenderer.fillColor = .blue
      circleRenderer.alpha = 0.3
      return circleRenderer
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        else{
            let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            
            pin.canShowCallout = true
            pin.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return pin
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        showRoute()
//        let annView = view.annotation
//
//        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController else {
//            print("detals vc not founds")
//            return
//        }
//
//
//
//        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
  
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locationManager.stopUpdatingLocation()
        
        self.mapView.showsUserLocation = true
        guard let latestLocation = locations.first else { return }
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: latestLocation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        if currentCoordinate == nil{
//            zoomIn(latestLocation.coordinate)
            addAnnotations()
        }
        
        currentCoordinate = latestLocation.coordinate
        
    }
}

