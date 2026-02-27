//
//  NetworkManager.swift
//  Animality
//
//  Created by t2025-m0143 on 2/27/26.
//
import Alamofire
import Foundation

class NetworkManager {
    private var clientId: String?
    private var secretId: String?
    
    init() {
        do {
            let keys = try fetchKeys()
            self.clientId = keys.client
            self.secretId = keys.secret
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
    private func fetchKeys() throws -> (client: String, secret: String) {
        guard let fileUrl = Bundle.main.url(forResource: "api", withExtension: "json") else {
            throw NetworkingError.invalid
        }
        guard let data = try? Data(contentsOf: fileUrl) else {
            throw NetworkingError.noData
        }
        
        let decoder = JSONDecoder()
        
        do {
            let apiKeys = try decoder.decode(Keys.self, from: data)
            return (client: apiKeys.client, secret: apiKeys.secret)
        } catch {
            throw NetworkingError.failedToDecode
        }
    }
    
    private func fetchMapData() {
        var urlComp = URLComponents(string: "https://maps.apigw.ntruss.com")
        
        let staticMapPath = "map-static/v2"
        let geocodingMapPath = "map-geocode/v2"
    }
}
