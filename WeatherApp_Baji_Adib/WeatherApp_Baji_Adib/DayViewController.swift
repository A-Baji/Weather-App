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
    var coordinates = ("0", "0")
    var ogCoords = ("0", "0")
    var pickerData: [String] = [String]()
    var stateCoordsList: [Any] = [Any]()
    var currState = "Current Location"
    
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var hourlyTable: UICollectionView!
    @IBOutlet weak var setLocationButton: UIButton!
    @IBOutlet weak var unitToggleButton: UILabel!
    @IBOutlet weak var statePicker: UIPickerView!
    @IBOutlet weak var confirmStateButton: UIButton!
    @IBOutlet weak var cancelStateButton: UIButton!
    
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
        
        statePicker.delegate = self
        statePicker.dataSource = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        
        // Check location permissions
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            self.setLocationButton.isHidden = true
            
        case .notDetermined, .restricted, .denied:
            self.location.text = "Location Required"
            self.setLocationButton.isHidden = false
            
        default:
            break
        }
        
        // Get state list
        guard let path = Bundle.main.path(forResource: "USstates_avg_latLong", ofType: "json") else { return }
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            
            stateCoordsList = json as! [Any]
            if let states = json as? [Any] {
                for i in 0..<states.count {
                    if let currState = states[i] as? [String: Any]{
                        pickerData.append(currState["state"] as! String)
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        statePicker.isHidden = true
        confirmStateButton.isHidden = true
        cancelStateButton.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let weekTab = self.tabBarController?.children[1] as! WeekViewController
        weekTab.weatherInfo = self.weatherInfo
        
        if coordinates != ("0", "0") {
            weekTab.setLocation = true
        }
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
        if coordinates != ("0", "0") {
            self.parseData()
        }
    }
    
    @IBAction func confirmState(_ sender: Any) {
        statePicker.isHidden = true
        confirmStateButton.isHidden = true
        cancelStateButton.isHidden = true
        
        if self.currState == "Current Location" {
            if coordinates != ("0", "0") {
                coordinates = ogCoords
                parseData()
            }
        } else {
            for i in 0..<stateCoordsList.count {
                if let currState = stateCoordsList[i] as? [String: Any]{
                    if self.currState == currState["state"] as! String {
                        coordinates = (String(describing: currState["latitude"] as! Double), String(describing: currState["longitude"] as! Double))
                        parseData()
                        self.setLocationButton.isHidden = true
                    }
                }
            }
        }
    }
    
    @IBAction func cancelState(_ sender: Any) {
        statePicker.isHidden = true
        confirmStateButton.isHidden = true
        cancelStateButton.isHidden = true
    }
    
    @IBAction func changeLocation(_ sender: Any) {
        statePicker.isHidden = false
        confirmStateButton.isHidden = false
        cancelStateButton.isHidden = false
    }
    
    @IBAction func toggleTempUnit(_ sender: Any) {
        if coordinates != ("0", "0") {
            inCelsius = !inCelsius
            if unitToggleButton.text == "??F" {
                unitToggleButton.text = "??C"
            } else {
                unitToggleButton.text = "??F"
            }
            self.UpdateCurrentInfo()
            self.hourlyTable.reloadData()
        }
    }
    
    func UpdateCurrentInfo() {
        let current = weatherInfo?.current
        let currWeather = current!.weather[0]
        let today = weatherInfo?.daily[0]
        
        dateAndTime.text = current!.getDate()
        currTemp.text = "\(current!.temp.toCelsius)??"
        setWeatherIcon(iconField: currIcon, id: currWeather.icon)
        currDesc.text = currWeather.description.capitalized
        currMinMax.text = "\(today!.temp.max.toCelsius)??/ \(today!.temp.min.toCelsius)??"
        currFeelsLike.text = "Feels like \(current!.feels_like.toCelsius)??"
        currUvi.text = current!.uvi.clean
        currSunrise.text = getTime(unix: current!.sunrise, format: "h:mm a")
        currSunset.text = getTime(unix: current!.sunset, format: "h:mm a")
        currHumidity.text = "\(String(describing: current!.humidity))%"
        currWindSpeed.text = "\(current!.wind_speed.clean) MPH"
        currClouds.text = "\(String(describing: current!.clouds))%"
    }
    
    func parseData() {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=\(coordinates.0)&lon=\(coordinates.1)&units=imperial&exclude=minutely&appid=f1f09b77546d167440f5c0fe108dc16c")!
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
    
    func setCity() {
        let coreLoc = CLLocation(latitude: Double(coordinates.0)!, longitude: Double(coordinates.1)!)
        
        CLGeocoder().reverseGeocodeLocation(coreLoc) {(placemarks, error) in
            if error != nil {
                print(error!)
                return
            }
            
            if let place = placemarks?[0] {
                if self.currState == "Current Location" {
                    if place.locality != nil {
                        self.location.text = place.locality
                    } else if place.administrativeArea != nil {
                        self.location.text = place.administrativeArea
                    } else {
                        self.location.text = "Unknown"
                    }
                } else {
                    self.location.text = self.currState
                }
            }
        }
    }
}

// MARK: - Global Funcs

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

// MARK: - Extensions

extension DayViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil  {
            self.pickerData.insert("Current Location", at: 0)
            self.statePicker.reloadAllComponents()
            
            currentLocation = locations.first
            self.locationManager.stopUpdatingLocation()
            
            let lat = currentLocation!.coordinate.latitude
            let lon = currentLocation!.coordinate.longitude
            
            self.coordinates = (String(describing: lat), String(describing: lon))
            self.ogCoords = (String(describing: lat), String(describing: lon))
            
            parseData()
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
        temp.text = "\(hour!.temp.toCelsius)??"
        rainChance.text = "\(Int(Float(hour!.pop.clean)! * 100))%"

        return cell
    }
    
}

extension DayViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currState = pickerData[row]
    }
}

extension DayViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
}

var inCelsius = false
extension Double {
    // Remove trailing zeroes
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
    
    // Convert to celsius
    var toCelsius: String {
        return inCelsius ? String(format: "%.1f", (self-32) * 5/9) : String(format: "%.0f", self)
    }
}
