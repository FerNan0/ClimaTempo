import Foundation

class WeatherService {
    static let shared = WeatherService()
    private let apiKey = Secrets.openWeatherMapKey
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    
    // MARK: - Buscar Clima Atual
    func fetchWeather(for city: String, completion: @escaping (Weather?) -> Void) {
        let urlString = "\(baseURL)/weather?q=\(city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city)&appid=\(apiKey)&units=metric&lang=pt_br"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 10.0
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Erro ao buscar clima: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Status HTTP Clima: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("Erro: API retornou status \(httpResponse.statusCode)")
                    completion(nil)
                    return
                }
            }
            
            guard let data = data else {
                print("Erro: Sem dados recebidos do clima")
                completion(nil)
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(OpenWeatherResponse.self, from: data)
                let weather = Weather(
                    city: decoded.name,
                    temperature: decoded.main.temp,
                    feelsLike: decoded.main.feels_like,
                    condition: decoded.weather.first?.main ?? "",
                    description: decoded.weather.first?.description ?? "",
                    humidity: decoded.main.humidity,
                    windSpeed: decoded.wind.speed,
                    cloudiness: decoded.clouds.all,
                    sunrise: Date(timeIntervalSince1970: TimeInterval(decoded.sys.sunrise)),
                    sunset: Date(timeIntervalSince1970: TimeInterval(decoded.sys.sunset)),
                    uvIndex: 0.0,
                    visibility: decoded.visibility
                )
                
                DispatchQueue.main.async {
                    completion(weather)
                }
            } catch {
                print("Erro ao decodificar clima: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    // MARK: - Previsão 5 Dias
    func fetchForecast(for city: String, completion: @escaping ([DailyForecast]?) -> Void) {
        let urlString = "\(baseURL)/forecast?q=\(city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city)&appid=\(apiKey)&units=metric&lang=pt_br&cnt=40"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Erro ao buscar previsão: \(error?.localizedDescription ?? "Desconhecido")")
                completion(nil)
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(ForecastResponse.self, from: data)
                
                // Agrupar por dia (pegar 1 previsão por dia ao meio-dia)
                var dailyForecasts: [DailyForecast] = []
                var lastDate = ""
                
                for item in decoded.list {
                    let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
                    let dateString = Calendar.current.dateComponents([.year, .month, .day], from: date)
                    let dayKey = "\(dateString.year ?? 0)-\(dateString.month ?? 0)-\(dateString.day ?? 0)"
                    
                    if dayKey != lastDate {
                        let daily = DailyForecast(
                            date: date,
                            tempMax: item.main.temp,
                            tempMin: item.main.temp,
                            condition: item.weather.first?.main ?? "",
                            description: item.weather.first?.description ?? "",
                            precipitation: item.pop * 100,
                            humidity: item.main.humidity,
                            windSpeed: item.wind.speed
                        )
                        dailyForecasts.append(daily)
                        lastDate = dayKey
                    }
                }
                
                DispatchQueue.main.async {
                    completion(Array(dailyForecasts.prefix(5)))
                }
            } catch {
                print("Erro ao decodificar previsão: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    // MARK: - Buscar Sugestões de Cidades (Geocoding)
    func searchCities(query: String, completion: @escaping ([String]) -> Void) {
        guard query.count >= 3 else {
            completion([])
            return
        }
        
        let urlString = "https://api.openweathermap.org/geo/1.0/direct?q=\(query)&limit=10&appid=\(apiKey)"
        
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            completion([])
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 8.0
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Erro ao buscar cidades: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let data = data else {
                print("Erro: Sem dados recebidos da geocodificação")
                completion([])
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode([GeocodingResult].self, from: data)
                // Deduplica resultados mantendo a ordem
                var seen = Set<String>()
                let cities = decoded.compactMap { result -> String? in
                    let cityName: String
                    if let state = result.state {
                        cityName = "\(result.name), \(state)"
                    } else {
                        cityName = result.name
                    }
                    return seen.insert(cityName).inserted ? cityName : nil
                }
                DispatchQueue.main.async {
                    completion(cities)
                }
            } catch {
                print("Erro ao decodificar geocodificação: \(error)")
                completion([])
            }
        }.resume()
    }
}
