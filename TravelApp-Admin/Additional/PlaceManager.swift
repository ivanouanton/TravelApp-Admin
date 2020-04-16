//
//  PlaceManager.swift
//  TravelApp-Admin
//
//  Created by Антон Иванов on 4/16/20.
//  Copyright © 2020 companyName. All rights reserved.
//

import Foundation
import CoreXLSX

class PlaceManager {
    static let shared = PlaceManager()
    
    private init() {}
    
    func parseExel() {

        
            guard let path =  Bundle.main.path(forResource: "rome", ofType: "xlsx"),
                let file = XLSXFile(filepath: path) else {
                print("error")
                return }
            
            do{
              let sharedStrings = try file.parseSharedStrings()
              
              for path in try file.parseWorksheetPaths() {
                let worksheet = try file.parseWorksheet(at: path)
                for row in worksheet.data?.rows ?? [] {
                  var f: String = ""
                    for (index, c) in row.cells.enumerated() {
                        if (index == 2) {
                            getCoordinate(with: c.stringValue(sharedStrings) ?? "")
                        }
//                        print(index, c.stringValue(sharedStrings))
                    let v = c.stringValue(sharedStrings)
                    f += " " + (v ?? "nil")
                  }
                  print(f)
                }
              }
            } catch(let error) {
              print(error.localizedDescription)
            }
    }
    

    func getCoordinate(with address: String) {
        NetworkProvider.shared.getMoyaProvider().request(.geocode(address: address)) { result in
            switch result{
            case .success(let response):
                if let json : [String:Any] = try? JSONSerialization.jsonObject(with: response.data, options: .allowFragments) as? [String: Any]{
                    
                    guard
                        let results = json["results"] as? Array<Any>,
                        !results.isEmpty,
                        let result = results[0] as? [String: Any] else {
                            print("location not found")
                            return
                    }
                    
                   
                        guard
                            let geometry = result["geometry"] as? [String: Any],
                            let location = geometry["location"] as? [String: Any],
                            let lat = location["lat"] as? Double,
                            let lng = location["lng"] as? Double else {
                            print("location not found")
                            return
                        }

                    print("\(lat) \(lng)")
                    
                    
                }else{
                    print("location not found")
                }

            case .failure(let error):
                print(error.localizedDescription)
                print("location not found")
            }
        }
    }
}
