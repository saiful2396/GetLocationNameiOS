//
//  ViewController.swift
//  GetLocationName
//
//  Created by Saiful Islam on 18/5/23.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager: CLLocationManager!
    
    var lat = 0.0
    var long = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation//kCLLocationAccuracyThreeKilometers//kCLLocationAccuracyHundredMeters //kCLLocationAccuracyKilometer//kCLLocationAccuracyBest//kCLLocationAccuracyNearestTenMeters
        
        checkLocationPermission()
    }

    func checkLocationPermission(){
        switch locationManager.authorizationStatus{
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            showAlert(withTitle: "Error", message: "Location access restricted!")
        case .denied:
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) {
                UIAlertAction in
            }
            
            let settingsAction = UIAlertAction(title: "Settings", style: UIAlertAction.Style.default) {
                UIAlertAction in
                
                let settingsUrl = NSURL(string: UIApplication.openSettingsURLString)
                if let url = settingsUrl {
                    UIApplication.shared.open(url as URL)
                }
            }
            
            showAlert(withTitle: "Error", message: "Please allow us to determine the user location to get a better experience.", andActions: [settingsAction, cancelAction])
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            showAlert(withTitle: "Error", message: "Something went wrong!")
        }
    }
    
    func getAddress(fromLocation location:CLLocation){
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location){
            (placemarks, error) in
            if let error = error {
                self.showAlert(withTitle: "Error", message: error.localizedDescription)
            }
            
            else if let placemarks = placemarks
            {
                self.showAlert(withTitle: "\nYour Current Location", message: "Location Address: \(placemarks[0].name!), \(placemarks[0].administrativeArea!)\n\nlatitude: \(self.lat)\nlatitude:\(self.long)")
                
                for placeMark in placemarks{
                    let address = [
                        placeMark.name as Any,
                        placeMark.subAdministrativeArea as Any,
                        placeMark.subThoroughfare as Any,
                        placeMark.subLocality as Any,
                        placeMark.region as Any,
                        placeMark.country as Any,
                        placeMark.administrativeArea as Any,
                        placeMark.locality as Any,
                        placeMark.postalCode as Any,
                        placeMark.areasOfInterest as Any,
                        placeMark.inlandWater as Any,
                        placeMark.isoCountryCode as Any,
                        placeMark.location as Any,
                        placeMark.ocean as Any
                    ].compactMap({$0 as? String}).joined(separator: ", ")
                    print(address)
                }
            }
        }
    }
    
    func showAlert(withTitle title: String?, message: String?, andActions actions:[UIAlertAction] = [UIAlertAction(title: "Ok", style: .default, handler: nil)])
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach({alert.addAction($0)})
        present(alert, animated: true, completion: nil)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showAlert(withTitle: "Error", message: error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else
        {
            return
        }
        
        lat = locValue.latitude
        long = locValue.longitude
        
        if let location = locations.last{
            locationManager.stopUpdatingLocation()
            getAddress(fromLocation: location)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationPermission()
    }
    
}

