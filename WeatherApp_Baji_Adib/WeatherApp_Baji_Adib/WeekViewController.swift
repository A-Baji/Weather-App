//
//  WeekViewController.swift
//  WeatherApp_Baji_Adib
//
//  Created by user203369 on 10/26/21.
//

import UIKit

class WeekViewController: UIViewController {
    
    var weatherInfo: WeatherInfo?
    var specificDay = DailyWeather()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "weeksToDay" {
            let specificDayView = segue.destination as! SpecificDayViewController
            specificDayView.specificDay = self.specificDay
        }
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
    
    func getDay(unix: Int) -> String {
        let time = Date(timeIntervalSince1970: TimeInterval(unix))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.timeZone = NSTimeZone() as TimeZone
        let localTime = dateFormatter.string(from: time)
        return localTime
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

extension WeekViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        specificDay = weatherInfo?.daily[indexPath.row] ?? DailyWeather()
        self.performSegue(withIdentifier: "weeksToDay", sender: self)
    }
}

extension WeekViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "day_cell", for: indexPath)
        
        let days = cell.viewWithTag(1) as! UILabel
        let rainChance = cell.viewWithTag(2) as! UILabel
        let icon = cell.viewWithTag(3) as! UIImageView
        let minMax = cell.viewWithTag(4) as! UILabel
        
        if weatherInfo == nil {
            return cell
        }
        
        let day = weatherInfo?.daily[indexPath.row]

        if indexPath.row == 0 {
            days.text = "Today"
        } else{
            days.text = getDay(unix: day!.dt)
        }
        rainChance.text = "\(Int(Float(day!.pop.clean)! * 100))%"
        setWeatherIcon(iconField: icon, id: day!.weather[0].icon)
        minMax.text = "\(String(format:"%.0f", round(day!.temp.max)))°/ \(String(format:"%.0f", round(day!.temp.min)))°"

        return cell
    }
}

