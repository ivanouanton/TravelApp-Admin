//
//  GoogleApiServices.swift
//  TravelApp-Admin
//
//  Created by Антон Иванов on 4/16/20.
//  Copyright © 2020 companyName. All rights reserved.
//

import Moya

enum GoogleApiService{
    case getRout(origin: String, destination: String, mode: String = "walking", points: String = "")
    case geocode(address: String)
}

extension GoogleApiService: TargetType{
    var baseURL: URL {
        return URL(string: "https://maps.googleapis.com/maps/api")!
    }
    
    var path: String {
        switch self {
        case .getRout:
            return "/directions/json"
        case .geocode:
            return "/geocode/json"
            
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getRout:
            return .post
        case .geocode:
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .getRout(let origin, let destination, let mode, let points):
            var parameters = [String: String]()
            parameters["origin"] = origin
            parameters["destination"] = destination
            parameters["mode"] = mode
            parameters["waypoints"] = points
            parameters["key"] = Defaults.apiKey
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .geocode(let address):
            var parameters = [String: String]()
            parameters["address"] = address
            parameters["key"] = Defaults.apiKey
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
}
