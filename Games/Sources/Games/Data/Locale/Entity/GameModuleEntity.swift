//
//  File.swift
//  
//
//  Created by Yoga Prasetyo on 19/08/23.
//

import Foundation
import RealmSwift

public class GameModuleEntity: Object {
    
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String
    @Persisted var desc: String
    @Persisted var released: String
    @Persisted var imagePath: String
    @Persisted var website: String
    @Persisted var rating: Double
    @Persisted var playtime: Int
    @Persisted var platforms: List<String>
    @Persisted var genres: List<String>
    @Persisted var favorite: Bool = false
    
}
