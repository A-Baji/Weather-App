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
    var setLocation = false
    
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
}

extension WeekViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if setLocation == true {
            specificDay = weatherInfo?.daily[indexPath.row] ?? DailyWeather()
            self.performSegue(withIdentifier: "weeksToDay", sender: self)
        }
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
            days.text = getTime(unix: day!.dt, format: "EEEE")
        }
        rainChance.text = "\(Int(Float(day!.pop.clean)! * 100))%"
        setWeatherIcon(iconField: icon, id: day!.weather[0].icon)
        minMax.text = "\(day!.temp.max.toCelsius)°/ \(day!.temp.min.toCelsius)°"

        return cell
    }
}

