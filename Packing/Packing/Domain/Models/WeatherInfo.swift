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
    let timestamp: String // ISO 8601 날짜 문자열로 변경
    let iconUrl: String
    let originalLocation: String
    let isForecast: Bool?
    let isCurrentWeather: Bool?
    let noticeMessage: String?
    
    // 편의를 위한 timestamp Date 변환 프로퍼티
    var date: Date? {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: timestamp)
    }
    
    // 서버에서 rain 필드가 없을 때는 0으로 처리하기 위한 초기화 메서드
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        temp = try container.decode(Double.self, forKey: .temp)
        tempMin = try container.decode(Double.self, forKey: .tempMin)
        tempMax = try container.decode(Double.self, forKey: .tempMax)
        humidity = try container.decode(Int.self, forKey: .humidity)
        weatherMain = try container.decode(String.self, forKey: .weatherMain)
        weatherDescription = try container.decode(String.self, forKey: .weatherDescription)
        weatherIcon = try container.decode(String.self, forKey: .weatherIcon)
        cityName = try container.decode(String.self, forKey: .cityName)
        countryCode = try container.decode(String.self, forKey: .countryCode)
        windSpeed = try container.decode(Double.self, forKey: .windSpeed)
        clouds = try container.decode(Int.self, forKey: .clouds)
        timestamp = try container.decode(String.self, forKey: .timestamp)
        iconUrl = try container.decode(String.self, forKey: .iconUrl)
        originalLocation = try container.decode(String.self, forKey: .originalLocation)
        
        // 선택적 필드 디코딩
        rain = (try? container.decodeIfPresent(Double.self, forKey: .rain)) ?? 0.0
        isForecast = try container.decodeIfPresent(Bool.self, forKey: .isForecast)
        isCurrentWeather = try container.decodeIfPresent(Bool.self, forKey: .isCurrentWeather)
        noticeMessage = try container.decodeIfPresent(String.self, forKey: .noticeMessage)
    }
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
