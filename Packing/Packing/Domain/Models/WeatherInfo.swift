//
//  WeatherInfo.swift
//  Packing
//
//  Created by 이융의 on 4/22/25.
//

import Foundation

struct WeatherInfo: Codable {
    let temp: Double
    let tempMin: Double
    let tempMax: Double
    let humidity: Int
    let weatherMain: String
    let weatherDescription: String
    let weatherIcon: String
    let cityName: String
    let countryCode: String
    let windSpeed: Double
    let clouds: Int
    let rain: Double
    let timestamp: Date
    let iconUrl: String
    let originalLocation: String
    let isForecast: Bool?
    let isCurrentWeather: Bool?
    let noticeMessage: String?
}

struct ForecastDay: Codable {
    let date: String
    let weather: WeatherInfo?
    let error: String?
    let message: String?
}

struct JourneyForecast: Codable {
    let city: String
    let startDate: String
    let endDate: String
    let forecasts: [ForecastDay]
}
