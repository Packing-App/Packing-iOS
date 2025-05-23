//
//  LocationService.swift
//  Packing
//
//  Created by 이융의 on 4/22/25.
//

import Foundation
import RxSwift

// MARK: - LocationService Protocol
protocol LocationServiceProtocol {
    // 도시 검색 (자동완성)
    func searchLocations(query: String, limit: Int) -> Observable<[CitySearchResult]>
    
    // 도시 영문명 변환
    func translateCity(city: String) -> Observable<CityTranslation>
    
    // 도시 날씨 정보 조회
    func getCityWeather(city: String, date: Date?) -> Observable<WeatherInfo>
    
    // 여행 기간 내 날씨 정보 조회
    func getJourneyForecast(city: String, startDate: Date, endDate: Date) -> Observable<JourneyForecast>
}

// MARK: - LocationService Implementation
class LocationService: LocationServiceProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    // MARK: - 도시 검색 (자동완성)
    func searchLocations(query: String, limit: Int = 10) -> Observable<[CitySearchResult]> {
        print(#fileID, #function, #line, "- 도시 검색 시작: \(query)")
        return apiClient.request(LocationEndpoint.searchLocations(query: query, limit: limit))
            .map { (response: APIResponse<[CitySearchResult]>) -> [CitySearchResult] in
                guard let cities = response.data else {
                    print("응답에 data 필드가 없음")
                    throw NetworkError.invalidResponse
                }
                print("도시 검색 결과: \(cities.count)개")
                return cities
            }
            .catch { error in
                print("도시 검색 오류: \(error)")
                return Observable.error(error)
            }
    }
    
    // MARK: - 도시 영문명 변환
    func translateCity(city: String) -> Observable<CityTranslation> {
        print(#fileID, #function, #line, "- 도시명 변환 시작: \(city)")
        return apiClient.request(LocationEndpoint.translateCity(city: city))
            .map { (response: APIResponse<CityTranslation>) -> CityTranslation in
                guard let translation = response.data else {
                    print("응답에 data 필드가 없음")
                    throw NetworkError.invalidResponse
                }
                print("도시명 변환 결과: \(translation.korName) -> \(translation.engName)")
                return translation
            }
            .catch { error in
                print("도시명 변환 오류: \(error)")
                return Observable.error(error)
            }
    }
    
    // MARK: - 도시 날씨 정보 조회
    func getCityWeather(city: String, date: Date? = nil) -> Observable<WeatherInfo> {
        print(#fileID, #function, #line, "- 날씨 정보 조회 시작: \(city)")
        return apiClient.request(LocationEndpoint.getCityWeather(city: city, date: date))
            .map { (response: APIResponse<WeatherInfo>) -> WeatherInfo in
                guard let weatherInfo = response.data else {
                    print("응답에 data 필드가 없음")
                    throw NetworkError.invalidResponse
                }
                print("날씨 정보 조회 결과: \(weatherInfo.cityName), \(weatherInfo.temp)°C, \(weatherInfo.weatherDescription)")
                return weatherInfo
            }
            .catch { error in
                print("날씨 정보 조회 오류: \(error)")
                return Observable.error(error)
            }
    }
    
    // MARK: - 여행 기간 내 날씨 정보 조회
    func getJourneyForecast(city: String, startDate: Date, endDate: Date) -> Observable<JourneyForecast> {
        print(#fileID, #function, #line, "- 여행 기간 날씨 정보 조회 시작: \(city), \(startDate) ~ \(endDate)")
        return apiClient.request(LocationEndpoint.getJourneyForecast(city: city, startDate: startDate, endDate: endDate))
            .map { (response: APIResponse<JourneyForecast>) -> JourneyForecast in
                guard let forecast = response.data else {
                    print("응답에 data 필드가 없음")
                    throw NetworkError.invalidResponse
                }
                print("여행 기간 날씨 정보 조회 결과: \(forecast.city), \(forecast.forecasts.count)일")
                return forecast
            }
            .catch { error in
                print("여행 기간 날씨 정보 조회 오류: \(error)")
                return Observable.error(error)
            }
    }
}
