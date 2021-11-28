//
//  SpecificDayViewController.swift
//  WeatherApp_Baji_Adib
//
//  Created by user203369 on 10/28/21.
//

import UIKit

class SpecificDayViewController: UIViewController {
    
    var specificDay = DailyWeather()
    
    // Main Info
    @IBOutlet weak var currDay: UILabel!
    @IBOutlet weak var currDate: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var dayTemp: UILabel!
    @IBOutlet weak var dayDesc: UILabel!
    @IBOutlet weak var dayMinMax: UILabel!
    @IBOutlet weak var dayFeelsLike: UILabel!
    
    // Temp Info
    @IBOutlet weak var mornTemp: UILabel!
    @IBOutlet weak var eveTemp: UILabel!
    @IBOutlet weak var nightTemp: UILabel!
    @IBOutlet weak var mornFeelsLike: UILabel!
    @IBOutlet weak var eveFeelsLike: UILabel!
    @IBOutlet weak var nightFeelsLike: UILabel!
    
    // Sun/Moon Info
    @IBOutlet weak var sunrise: UILabel!
    @IBOutlet weak var sunset: UILabel!
    @IBOutlet weak var moonrise: UILabel!
    @IBOutlet weak var moonset: UILabel!
    
    // Weather Info
    @IBOutlet weak var uvIndex: UILabel!
    @IBOutlet weak var pressure: UILabel!
    @IBOutlet weak var rainChance: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var windSpeed: UILabel!
    @IBOutlet weak var cloudiness: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set main
        currDay.text = specificDay.getDayOfWeek()
        currDate.text = specificDay.getDate()
        setWeatherIcon(iconField: weatherIcon, id: specificDay.weather[0].icon)
        dayTemp.text = "\(String(format:"%.0f", round(specificDay.temp.day)))°"
        dayDesc.text = specificDay.weather[0].description.capitalized
        dayMinMax.text = "\(String(format:"%.0f", round(specificDay.temp.max)))°/ \(String(format:"%.0f", round(specificDay.temp.min)))°"
        dayFeelsLike.text = "Feels like \(String(format:"%.0f", specificDay.feels_like.day))°"
        
        // Set temps
        mornTemp.text = "\(String(format:"%.0f", round(specificDay.temp.morn)))°"
        eveTemp.text = "\(String(format:"%.0f", round(specificDay.temp.eve)))°"
        nightTemp.text = "\(String(format:"%.0f", round(specificDay.temp.night)))°"
        mornFeelsLike.text = "\(String(format:"%.0f", round(specificDay.feels_like.morn)))°"
        eveFeelsLike.text = "\(String(format:"%.0f", round(specificDay.feels_like.eve)))°"
        nightFeelsLike.text = "\(String(format:"%.0f", round(specificDay.feels_like.night)))°"
        
        // Set sun/moon
        sunrise.text = getTime(unix: specificDay.sunrise, format: "h:mm a")
        sunset.text = getTime(unix: specificDay.sunset, format: "h:mm a")
        moonrise.text = getTime(unix: specificDay.moonrise, format: "h:mm a")
        moonset.text = getTime(unix: specificDay.moonset, format: "h:mm a")
        
        // Set weather
        uvIndex.text = specificDay.uvi.clean
        pressure.text = "\(specificDay.pressure) hPa"
        rainChance.text = "\(Int(Float(specificDay.pop.clean)! * 100))%"
        humidity.text = "\(specificDay.humidity)%"
        windSpeed.text = "\(specificDay.wind_speed.clean) MPH"
        cloudiness.text = "\(specificDay.clouds)%"
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
}
