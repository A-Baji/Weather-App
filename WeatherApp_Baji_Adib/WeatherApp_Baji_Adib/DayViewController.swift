//
//  DayViewController.swift
//  WeatherApp_Baji_Adib
//
//  Created by user203369 on 10/26/21.
//

import UIKit
import Foundation
import MapKit
import CoreLocation

class DayViewController: UIViewController {
    
    var weatherInfo: WeatherInfo?
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var url: URL?
    
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var hourlyTable: UICollectionView!
    @IBOutlet weak var setLocationButton: UIButton!
    
    // MARK: - Current Info
    @IBOutlet weak var dateAndTime: UILabel!
    @IBOutlet weak var currTemp: UILabel!
    @IBOutlet weak var currIcon: UIImageView!
    @IBOutlet weak var currDesc: UILabel!
    @IBOutlet weak var currMinMax: UILabel!
    @IBOutlet weak var currFeelsLike: UILabel!
    @IBOutlet weak var currUvi: UILabel!
    @IBOutlet weak var currSunrise: UILabel!
    @IBOutlet weak var currSunset: UILabel!
    @IBOutlet weak var currHumidity: UILabel!
    @IBOutlet weak var currWindSpeed: UILabel!
    @IBOutlet weak var currClouds: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hourlyTable.delegate = self
        hourlyTable.dataSource = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            self.setLocationButton.isHidden = true
            
        case .notDetermined, .restricted, .denied:
            self.location.text = "Location Required"
            self.setLocationButton.isHidden = false
            
        default:
            break
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let weekTab = self.tabBarController?.children[1] as! WeekViewController
        weekTab.weatherInfo = self.weatherInfo
    }
    
    @IBAction func goToSettings(_ sender: Any) {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
         }
    }
    
    @IBAction func refreshInfo(_ sender: Any) {
        DispatchQueue.main.async {
            self.parseData(url: self.url!)
            self.dateAndTime.text = self.weatherInfo?.current.getDate()
        }
    }
    
    func UpdateCurrentInfo() {
        let current = weatherInfo?.current
        let currWeather = current!.weather[0]
        let today = weatherInfo?.daily[0]
        
        dateAndTime.text = current!.getDate()
        currTemp.text = "\(String(format:"%.0f", round(current!.temp)))°"
        setWeatherIcon(iconField: currIcon, id: currWeather.icon)
        currDesc.text = currWeather.description.capitalized
        currMinMax.text = "\(String(format:"%.0f", round(today!.temp.max)))°/ \(String(format:"%.0f", round(today!.temp.min)))°"
        currFeelsLike.text = "Feels like \(String(format:"%.0f", current!.feels_like))°"
        currUvi.text = current!.uvi.clean
        currSunrise.text = getTime(unix: current!.sunrise, format: "h:mm a")
        currSunset.text = getTime(unix: current!.sunset, format: "h:mm a")
        currHumidity.text = "\(String(describing: current!.humidity))%"
        currWindSpeed.text = "\(current!.wind_speed.clean) MPH"
        currClouds.text = "\(String(describing: current!.clouds))%"
    }
    
    func parseData(url: URL) {
        
        URLSession.shared.dataTask(with: url, completionHandler: {data, response, error in
            guard let data = data, error == nil else {
                print("JSON decode fail: \(String(describing: error))")
                
                return
            }

            do {
                self.weatherInfo = try JSONDecoder().decode(WeatherInfo.self, from: data)
            }
            catch {
                print("Response error: \(String(describing: error))")
            }
            
            guard self.weatherInfo != nil else {
                return
            }
            
            DispatchQueue.main.async {
                self.UpdateCurrentInfo()
                self.setCity()
                self.hourlyTable.reloadData()
            }
            
        }).resume()
    }
    
    func setWeatherIcon(iconField: UIImageView, id: String) {
        let iconURL = URL(string: "https://openweathermap.org/img/wn/\(id)@4x.png")!
        URLSession.shared.dataTask(with: iconURL, completionHandler: {(data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                iconField.image = UIImage(data: data!)
            }
        }).resume()
    }
    
    func getTime(unix: Int, format: String) -> String {
        let time = Date(timeIntervalSince1970: TimeInterval(unix))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = NSTimeZone() as TimeZone
        let localTime = dateFormatter.string(from: time)
        return localTime
    }
    
    func setCity() {
        let coreLoc = CLLocation(latitude: currentLocation!.coordinate.latitude, longitude: currentLocation!.coordinate.longitude)
        
        CLGeocoder().reverseGeocodeLocation(coreLoc) {(placemarks, error) in
            if error != nil {
                print(error!)
                return
            }
            
            if let place = placemarks?[0] {
                self.location.text = place.locality
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - Extensions

extension DayViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil  {
            currentLocation = locations.first
            self.locationManager.stopUpdatingLocation()
            
            let lat = currentLocation!.coordinate.latitude
            let lon = currentLocation!.coordinate.longitude
            
            self.url = URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=\(String(describing: lat))&lon=\(String(describing: lon))&units=imperial&exclude=minutely&appid=f1f09b77546d167440f5c0fe108dc16c")!
            
            parseData(url: self.url!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        // If location permission is denied, send to settings
        if (status == CLAuthorizationStatus.denied) {
            self.location.text = "Location Required"
            self.setLocationButton.isHidden = false
            
            let alertController = UIAlertController(title: "Notice", message: "Please go to Settings and turn on location permissions", preferredStyle: .alert)

            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
                 }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)

            alertController.addAction(cancelAction)
            alertController.addAction(settingsAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        else if (status == CLAuthorizationStatus.authorizedAlways || status == CLAuthorizationStatus.authorizedWhenInUse) {
            self.setLocationButton.isHidden = true
        }
    }
}

extension DayViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
        {
            return CGSize(width: 55, height: 140)
    }
}


extension DayViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 24
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hour_cell", for: indexPath)
        
        let time = cell.viewWithTag(1) as! UILabel
        let icon = cell.viewWithTag(2) as! UIImageView
        let temp = cell.viewWithTag(3) as! UILabel
        let rainChance = cell.viewWithTag(4) as! UILabel
        
        if weatherInfo == nil {
            return cell
        }
        
        let hour = weatherInfo?.hourly[indexPath.row]

        time.text = getTime(unix: hour!.dt, format: "h a")
        setWeatherIcon(iconField: icon, id: hour!.weather[0].icon)
        temp.text = "\(String(format:"%.0f", round(hour!.temp)))°"
        rainChance.text = "\(Int(Float(hour!.pop.clean)! * 100))%"

        return cell
    }
    
}

// Remove trailing zeroes
extension Double {
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
