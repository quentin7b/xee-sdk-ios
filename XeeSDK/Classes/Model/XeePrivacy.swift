//
//  XeePrivacy.swift
//  XeeSDK
//
//  Created by Jean-Baptiste Dujardin on 05/10/2017.
//

import ObjectMapper

public class XeePrivacy: XeeObject {
    
    public var privacyID: String?
    public var startedAt: Date?
    public var endedAt: Date?
    
    required public init?(map: Map) {
        super.init(map: map)
    }
    
    public override func mapping(map: Map) {
        super.mapping(map: map)
        privacyID <- map["id"]
        startedAt <- (map["startedAt"], dateTransform)
        endedAt <- (map["endedAt"], dateTransform)
    }
    
}
