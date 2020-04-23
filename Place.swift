//
//  Place.swift
//  TravelApp-Admin
//
//  Created by Антон Иванов on 4/22/20.
//  Copyright © 2020 companyName. All rights reserved.
//

import Foundation
import Firebase

struct Place {
    var address: String
    var addressCode: String
    var audio: String? = nil
    var category: Category
    var description: String?
    var image: String = ""
    var isMustVisit: Bool
    var location: GeoPoint? = nil
    var name: String
    var price: Price
    
    init(with data: [String]) {
        name = data[0]
        address = data[1]
        addressCode = data[2]
        category = Category(data[3])!
        price = Price(rawValue: data[4])!
        let isMust = data[5].trimmingCharacters(in: .whitespacesAndNewlines)
        isMustVisit = isMust == "No" ? false : true
    }
    
    func getData() -> [String: Any] {
        let db1 = Firestore.firestore()
        let documentRefString = db1.collection("gs:/trello-2704d.appspot.com/rome_places").document("\(name).jpg")
        let userRef = db1.document(documentRefString.path)
        
        return [
            "address": address,
            "audio": NSNull(),
            "category": self.category.getFirVal(),
            "description": NSNull(),
            "image": userRef,
            "isMustVisit": isMustVisit,
            "location": location!,
            "name": name,
            "price": price.getFirVal(),
        ]
    }
}

enum Category: String {
    case parks = "Piazzas & Parks"
    case culturalsites = "Cultural Sites"
    case museums = "Museums & Galleries"
    case shopping = "Shopping"
    case cityviews = "City Views"
    case restaurants = "Restaurants & Cafés"
    case churches = "Churches"
    
    init?(_ category: String){
        self.init(rawValue: category)
    }
}

enum Price: String {
    case free = "Free"
    case low = "€"
    case medium = "€€"
    case high
    
    init?(_ price: String){
        let price = price.trimmingCharacters(in: .whitespacesAndNewlines)
        self.init(rawValue: price)
    }
    
    init(with value: String) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        switch trimmed {
        case "Free":
            self = .free
        case "€":
            self = .low
        case "€€":
            self = .medium
        default:
            self = .high
        }
    }
    
    func getFirVal() -> Int {
        switch self {
        case .free:
            return 0
        case .low:
            return 1
        case .medium:
            return 2
        default:
            return 3
        }
    }
}

extension Category {

    func getFirVal() -> String {
        switch self {
        case .parks:
            return "parks"
        case .culturalsites:
            return "culturalsites"
        case .museums:
            return "museums"
        case .shopping:
            return "shopping"
        case .cityviews:
            return "cityviews"
        case .restaurants:
            return "restaurants"
        case .churches:
            return "churches"
        }
    }
}


