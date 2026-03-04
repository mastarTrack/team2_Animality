//
//  NetworkManager.swift
//  Animality
//
//  Created by t2025-m0143 on 2/27/26.
//
import Alamofire
import Foundation

class NetworkManager {
    private(set) var clientId: String?
    private var secretId: String?
    private var searchClientId: String?
    private var searchSecretId: String?
    
    init() {
        do {
            let keys = try fetchKeys()
            self.clientId = keys.client
            self.secretId = keys.secret
            self.searchClientId = keys.searchClient
            self.searchSecretId = keys.searchSecret
        } catch NetworkingError.invalid {
            print("유효하지 않은 url입니다.")
        } catch NetworkingError.noData {
            print("데이터가 존재하지 않습니다.")
        } catch NetworkingError.failedToDecode {
            print("디코딩에 실패했습니다.")
        } catch {
            print("알 수 없는 에러입니다.")
        }
    }
    
    // api 키 할당을 위한 함수
    private func fetchKeys() throws -> (client: String, secret: String, searchClient: String, searchSecret: String) {
        guard let fileUrl = Bundle.main.url(forResource: "api", withExtension: "json") else {
            throw NetworkingError.invalid
        }
        guard let data = try? Data(contentsOf: fileUrl) else {
            throw NetworkingError.noData
        }
        
        let decoder = JSONDecoder()
        
        do {
            let apiKeys = try decoder.decode(Keys.self, from: data)
            return (client: apiKeys.client, secret: apiKeys.secret,
                    searchClient: apiKeys.searchClient, searchSecret: apiKeys.searchSecret)
        } catch {
            throw NetworkingError.failedToDecode
        }
    }
}

//MARK: 검색 API
extension NetworkManager {
    // 지역 검색
    func searchLocationData(of text: String) async throws -> SearchResponse {
        // url 및 헤더 설정
        var urlComp = URLComponents(string: "https://openapi.naver.com/v1/search/local.json")
        let queryItems = [
            URLQueryItem(name: "query", value: text) // 검색어
            ]
        
        urlComp?.queryItems = queryItems
        
        guard let url = urlComp?.url else { throw NetworkingError.invalid }
        print(url)
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "X-Naver-Client-Id": searchClientId ?? "",
            "X-Naver-Client-Secret": searchSecretId ?? ""
        ]
        
        // request
        let dataTask = AF.request(url, method: .get, headers: headers)
                .validate()
                .serializingDecodable(SearchResponse.self)
        
        switch await dataTask.result {
        case .success(let data):
            return data
        case .failure(let error):
            print("request 실패: \(error)")
            throw NetworkingError.failedToDecode
        }
    }
    
    // 이미지 검색
    func searchImageData(of text: String) async throws -> ImageResponse {
        // url 및 헤더 설정
        var urlComp = URLComponents(string: "https://openapi.naver.com/v1/search/image")
        let queryItems = [
            URLQueryItem(name: "query", value: text) // 검색어
            ]
        
        urlComp?.queryItems = queryItems
        
        guard let url = urlComp?.url else { throw NetworkingError.invalid }
        print(url)
        let headers: HTTPHeaders = [
            "X-Naver-Client-Id": searchClientId ?? "",
            "X-Naver-Client-Secret": searchSecretId ?? ""
        ]
        
        // request
        let dataTask = AF.request(url, method: .get, headers: headers)
                .validate()
                .serializingDecodable(ImageResponse.self)
        
        switch await dataTask.result {
        case .success(let data):
            return data
        case .failure(let error):
            print("request 실패: \(error)")
            throw NetworkingError.failedToDecode
        }
    }
}
