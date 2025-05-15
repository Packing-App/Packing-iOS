//
//  WeatherSection.swift
//  Packing
//
//  Created by 이융의 on 4/22/25.
//

import SwiftUI
import RxSwift

// MARK: - Weather Section View
struct WeatherSection: View {
    let journey: Journey
    @State private var currentWeather: WeatherInfo?
    @State private var forecast: JourneyForecast?
    @State private var isLoading = true
    @State private var error: String?
    @State private var showFullForecast = false
    
    private let locationService = LocationService()
    private let disposeBag = DisposeBag()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Section header
            HStack {
                Text("여행지 날씨".localized)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                } else if forecast != nil || currentWeather != nil {
                    Button(action: {
                        withAnimation {
                            showFullForecast.toggle()
                        }
                    }) {
                        Text(showFullForecast ? "간략히 보기".localized : "상세 보기".localized)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.main)
                    }
                }
            }
            
            // Error message
            if let error = error {
                Text(error)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }
            
            // Current weather view
            if let weather = currentWeather, !isLoading {
                currentWeatherView(weather: weather)
            }
            
            // Forecast View - Only shown when showFullForecast is true
            if let forecast = forecast, showFullForecast {
                Divider()
                    .padding(.vertical, 5)
                
                Text("여행 기간 날씨".localized)
                    .font(.system(size: 16, weight: .medium))
                    .padding(.top, 5)
                
                forecastListView(forecast: forecast)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(Color(.systemBackground))
        .onAppear {
            loadWeatherData()
        }
    }
    
    // MARK: - Current Weather View
    private func currentWeatherView(weather: WeatherInfo) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 15) {
                // Weather icon
                ZStack {
                    if let iconUrl = URL(string: weather.iconUrl) {
                        AsyncImage(url: iconUrl) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            default:
                                Image(systemName: weatherIcon(for: weather.weatherMain))
                                    .font(.system(size: 30))
                                    .foregroundStyle(Color.main)
                            }
                        }
                        .frame(width: 60, height: 60)
                    } else {
                        Image(systemName: weatherIcon(for: weather.weatherMain))
                            .font(.system(size: 30))
                            .foregroundStyle(Color.main)
                            .frame(width: 60, height: 60)
                    }
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(weather.cityName), \(weather.countryCode)")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text(weather.weatherDescription.capitalized)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 15) {
                        Text("\(Int(weather.temp))°C")
                            .font(.system(size: 20, weight: .bold))
                        
                        Text("최저 \(Int(weather.tempMin))° / 최고 \(Int(weather.tempMax))°".lowercased())
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            // Additional weather details
            HStack(spacing: 20) {
                weatherDetailItem(icon: "drop.fill", value: "\(weather.humidity)%", label: "습도".localized)
                weatherDetailItem(icon: "wind", value: "\(Int(weather.windSpeed))m/s", label: "풍속".localized)
                
                if weather.rain > 0 {
                    weatherDetailItem(icon: "cloud.rain.fill", value: "\(weather.rain)mm", label: "강수량".localized)
                } else {
                    weatherDetailItem(icon: "cloud.fill", value: "\(weather.clouds)%", label: "구름".localized)
                }
            }
            .padding(.top, 5)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
    
    // MARK: - Weather Detail Item
    private func weatherDetailItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.main)
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Forecast List View
    private func forecastListView(forecast: JourneyForecast) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(forecast.forecasts.indices, id: \.self) { index in
                    if let weather = forecast.forecasts[index].weather {
                        forecastDayView(day: forecast.forecasts[index].date, weather: weather)
                    } else {
                        noForecastView(day: forecast.forecasts[index].date)
                    }
                }
            }
            .padding(.top, 5)
            .padding(.bottom, 10)
        }
    }
    
    // MARK: - Forecast Day View
    private func forecastDayView(day: String, weather: WeatherInfo) -> some View {
        VStack(spacing: 8) {
            Text(formattedDay(from: day))
                .font(.system(size: 14, weight: .medium))
            
            // Weather icon
            if let iconUrl = URL(string: weather.iconUrl) {
                AsyncImage(url: iconUrl) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    default:
                        Image(systemName: weatherIcon(for: weather.weatherMain))
                            .font(.system(size: 22))
                            .foregroundStyle(Color.main)
                    }
                }
                .frame(width: 45, height: 45)
            } else {
                Image(systemName: weatherIcon(for: weather.weatherMain))
                    .font(.system(size: 22))
                    .foregroundStyle(Color.main)
                    .frame(width: 45, height: 45)
            }
            
            Text("\(Int(weather.temp))°")
                .font(.system(size: 16, weight: .bold))
            
            Text("\(Int(weather.tempMin))°/\(Int(weather.tempMax))°")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            
            // 간단한 상태 설명
            Text(weather.weatherDescription)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(width: 80)
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - No Forecast View
    private func noForecastView(day: String) -> some View {
        VStack(spacing: 8) {
            Text(formattedDay(from: day))
                .font(.system(size: 14, weight: .medium))
            
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 45, height: 45)
                
                Image(systemName: "questionmark")
                    .font(.system(size: 22))
                    .foregroundColor(.gray)
            }
            
            Text("정보 없음".localized)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80)
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Weather Data Loading
    private func loadWeatherData() {
        isLoading = true
        error = nil
        
        // 현재 날씨 정보 로드
        locationService.getCityWeather(city: journey.destination, date: nil)
            .subscribe(onNext: { weather in
                self.currentWeather = weather
                self.loadForecast()
            }, onError: { error in
                self.isLoading = false
                self.error = "현재 날씨 정보를 불러올 수 없습니다.".localized
                print("날씨 로드 오류: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    private func loadForecast() {
        // 여행 기간 내 예보 조회
        locationService.getJourneyForecast(city: journey.destination, startDate: journey.startDate, endDate: journey.endDate)
            .subscribe(onNext: { forecast in
                self.forecast = forecast
                self.isLoading = false
            }, onError: { error in
                self.isLoading = false
                self.error = "예보를 불러올 수 없습니다.".localized
                print("예보 로드 오류: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Helper Functions
    private func formattedDay(from dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: dateString) {
            // 요일 표시
            let weekdayFormatter = DateFormatter()
            weekdayFormatter.dateFormat = "EEE" // 요일 표시 (월, 화, 수...)
            weekdayFormatter.locale = Locale(identifier: "ko_KR")
            let weekday = weekdayFormatter.string(from: date)
            
            // 일자 표시
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "d일"
            let day = dayFormatter.string(from: date)
            
            return "\(weekday)\n\(day)"
        }
        return ""
    }
    
    // 날씨 상태에 따른 아이콘 (API에서 제공하는 iconUrl이 실패할 경우 백업으로 사용)
    private func weatherIcon(for weatherMain: String) -> String {
        switch weatherMain {
        case "Clear":
            return "sun.max.fill"
        case "Clouds":
            return "cloud.fill"
        case "Rain":
            return "cloud.rain.fill"
        case "Drizzle":
            return "cloud.drizzle.fill"
        case "Thunderstorm":
            return "cloud.bolt.rain.fill"
        case "Snow":
            return "cloud.snow.fill"
        case "Mist", "Fog":
            return "cloud.fog.fill"
        case "Haze":
            return "sun.haze.fill"
        case "Dust", "Sand":
            return "sun.dust.fill"
        case "Smoke", "Ash":
            return "smoke.fill"
        case "Squall":
            return "wind.fill"
        case "Tornado":
            return "tornado"
        default:
            return "cloud.fill"
        }
    }
}
