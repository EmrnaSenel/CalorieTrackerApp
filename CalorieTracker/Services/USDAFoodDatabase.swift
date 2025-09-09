import Foundation

class USDAFoodDatabase {
    private let apiKey: String
    private let baseURL = "https://api.nal.usda.gov/fdc/v1"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func searchFood(query: String) async throws -> [USDAFood] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "\(baseURL)/foods/search?api_key=\(apiKey)&query=\(encodedQuery)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(USDAFoodResponse.self, from: data)
        return response.foods
    }
} 