//
//  WeatherInfo.swift
//  WeatherApp_Baji_Adib
//
//  Created by user203369 on 10/28/21.
//

import Foundation

struct MainWeather: Codable {
    init() {
        id = 0
        main = ""
        description = ""
        icon = ""
    }

    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct CurrentWeather: Codable {
    init() {
        dt = 0
        sunrise = 0
        sunset = 0
        temp = 0.0
        feels_like = 0.0
        pressure = 0
        humidity = 0
        dew_point = 0.0
        uvi = 0.0
        clouds = 0
        visibility = 0
        wind_speed = 0.0
        wind_deg = 0
        wind_gust = 0.0
        rain = RainInfo()
        snow = SnowInfo()
        weather = [MainWeather]()
    }

    let dt: Int
    let sunrise: Int
    let sunset: Int
    let temp: Double
    let feels_like: Double
    let pressure: Int
    let humidity: Int
    let dew_point: Double
    let uvi: Double
    let clouds: Int
    let visibility: Int
    let wind_speed: Double
    let wind_deg: Int
    let wind_gust: Double?
    let rain: RainInfo?
    let snow: SnowInfo?
    let weather: [MainWeather]
    
    public func getDate() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self.dt))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMMM dd h:mm a"
        dateFormatter.timeZone = NSTimeZone() as TimeZone
        let localDate = dateFormatter.string(from: date)
        return localDate
    }
}

struct RainInfo:Codable {
    init() {
        last_hour = 0.0
    }
    let last_hour: Double?

    enum CodingKeys: String, CodingKey {
        case last_hour = "1h"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let theRain = try? values.decode(RainInfo.self, forKey: .last_hour) {
            self.last_hour = theRain.last_hour
        } else {
            self.last_hour = nil
        }
    }
}

struct SnowInfo:Codable {
    init() {
        last_hour = 0.0
    }
    let last_hour: Double?

    enum CodingKeys: String, CodingKey {
        case last_hour = "1h"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let theRain = try? values.decode(SnowInfo.self, forKey: .last_hour) {
            self.last_hour = theRain.last_hour
        } else {
            self.last_hour = nil
        }
    }
}

struct HourlyWeather: Codable {
    init() {
        dt = 0
        temp = 0.0
        feels_like = 0.0
        pressure = 0
        humidity = 0
        dew_point = 0.0
        uvi = 0.0
        clouds = 0
        visibility = 0
        wind_speed = 0.0
        wind_deg = 0
        wind_gust = 0.0
        weather = [MainWeather]()
        pop = 0.0
        rain = RainInfo()
        snow = SnowInfo()
    }

    let dt: Int
    let temp: Double
    let feels_like: Double
    let pressure: Int
    let humidity: Int
    let dew_point: Double
    let uvi: Double
    let clouds: Int
    let visibility: Int?
    let wind_speed: Double
    let wind_deg: Int
    let wind_gust: Double?
    let weather: [MainWeather]
    let pop: Double
    let rain: RainInfo?
    let snow: SnowInfo?
}

struct DailyTemp: Codable {
    init() {
        day = 0.0
        min = 0.0
        max = 0.0
        night = 0.0
        eve = 0.0
        morn = 0.0
    }

    let day: Double
    let min: Double
    let max: Double
    let night: Double
    let eve: Double
    let morn: Double
}

struct DailyFeelsLike: Codable {
    init() {
        day = 0.0
        night = 0.0
        eve = 0.0
        morn = 0.0
    }

    let day: Double
    let night: Double
    let eve: Double
    let morn: Double
}

struct DailyWeather: Codable {
    init() {
        dt = 0
        sunrise = 0
        sunset = 0
        moonrise = 0
        moonset = 0
        moon_phase = 0.0
        temp = DailyTemp()
        feels_like = DailyFeelsLike()
        pressure = 0
        humidity = 0
        dew_point = 0.0
        wind_speed = 0.0
        wind_deg = 0
        wind_gust = 0.0
        weather = [MainWeather]()
        clouds = 0
        visibility = 0
        pop = 0.0
        rain = 0.0
        snow = 0.0
        uvi = 0.0
    }

    let dt: Int
    let sunrise: Int
    let sunset: Int
    let moonrise: Int
    let moonset: Int
    let moon_phase: Double
    let temp: DailyTemp
    let feels_like: DailyFeelsLike
    let pressure: Int
    let humidity: Int
    let dew_point: Double
    let wind_speed: Double
    let wind_deg: Int
    let wind_gust: Double?
    let weather: [MainWeather]
    let clouds: Int
    let visibility: Int?
    let pop: Double
    let rain: Double?
    let snow: Double?
    let uvi: Double
    
    public func getDayOfWeek() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self.dt))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.timeZone = NSTimeZone() as TimeZone
        let localDate = dateFormatter.string(from: date)
        return localDate
    }
    
    public func getDate() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self.dt))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd"
        dateFormatter.timeZone = NSTimeZone() as TimeZone
        let localDate = dateFormatter.string(from: date)
        return localDate
    }
}

struct WeatherInfo: Codable {
    init() {
        lat = 0.0
        lon = 0.0
        timezone = ""
        timezone_offset = 0
        current = CurrentWeather()
        hourly = [HourlyWeather]()
        daily = [DailyWeather]()
    }

    let lat: Double
    let lon: Double
    let timezone: String
    let timezone_offset: Int
    let current: CurrentWeather
    let hourly: [HourlyWeather]
    let daily: [DailyWeather]

}
