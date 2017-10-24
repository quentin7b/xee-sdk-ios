//
//  XeeRequestManager.swift
//  XeeSDK
//
//  Created by Jean-Baptiste Dujardin on 03/10/2017.
//

import Foundation
import Alamofire
import ObjectMapper

public class XeeRequestManager: SessionManager{
    
    private init() {
        super.init(configuration: URLSessionConfiguration.default, delegate: Alamofire.SessionDelegate(), serverTrustPolicyManager: nil)
    }
    
    public static let shared = XeeRequestManager()
    
    var baseURL: URL? {
        get {
            if let baseURL = XeeConnectManager.shared.baseURL {
                return baseURL
            }else {
                return nil
            }
        }
    }
    
    var clientID: String? {
        get {
            if let clientID = XeeConnectManager.shared.config?.clientID {
                return clientID
            }else {
                return nil
            }
        }
    }
    
    var secretKey: String? {
        get {
            if let secretKey = XeeConnectManager.shared.config?.secretKey {
                return secretKey
            }else {
                return nil
            }
        }
    }
    
    var scope: String? {
        get {
            if let scope = XeeConnectManager.shared.token?.scope {
                return scope
            }else {
                return nil
            }
        }
    }
    
    public func getToken(withCode code: String, completionHandler: ((_ error: Error?, _ token: XeeToken?) -> Void)? ) {
        
        let parameters: Parameters = ["grant_type":"authorization_code", "code":code]
        var headers: HTTPHeaders = [:]
        
        if let authorizationHeader = Request.authorizationHeader(user: clientID!, password: secretKey!) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        
        self.request("\(baseURL!)" + "/oauth/token", method:.post, parameters:parameters, encoding:URLEncoding.default, headers:headers).responseObject { (response: DataResponse<XeeToken>) in
            if let error = response.error {
                UserDefaults.standard.set(nil, forKey: "XeeSDKInternalAccessToken")
                UserDefaults.standard.synchronize()
                if let completionHandler = completionHandler {
                    completionHandler(error, nil)
                }
            }else {
                if let token = response.result.value {
                    UserDefaults.standard.set(token.toJSON(), forKey: "XeeSDKInternalAccessToken")
                    UserDefaults.standard.synchronize()
                    if let completionHandler = completionHandler {
                        completionHandler(nil, token)
                    }
                }
            }
        }
    }
    
    public func refreshToken(completionHandler: ((_ error: Error?, _ token: XeeToken?) -> Void)? ) {
        
        var parameters: Parameters = ["grant_type":"refresh_token"]
        if let refreshToken = XeeConnectManager.shared.token?.refreshToken {
            parameters["refresh_token"] = refreshToken
        }
        if let scope = XeeConnectManager.shared.token?.scope {
            parameters["scope"] = scope
        }
        
        var headers: HTTPHeaders = [:]
        
        if let authorizationHeader = Request.authorizationHeader(user: clientID!, password: secretKey!) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        
        self.request("\(baseURL!)" + "/oauth/token", method:.post, parameters:parameters, encoding:URLEncoding.default, headers:headers).responseObject { (response: DataResponse<XeeToken>) in
            if let error = response.error {
                UserDefaults.standard.set(nil, forKey: "XeeSDKInternalAccessToken")
                UserDefaults.standard.synchronize()
                if let completionHandler = completionHandler {
                    completionHandler(error, nil)
                }
            }else {
                if let token = response.result.value {
                    UserDefaults.standard.set(token.toJSON(), forKey: "XeeSDKInternalAccessToken")
                    UserDefaults.standard.synchronize()
                    if let completionHandler = completionHandler {
                        completionHandler(nil, token)
                    }
                }
            }
        }
    }
    
    public func revokeToken(completionHandler: ((_ error: Error?) -> Void)? ) {
        
        var headers: HTTPHeaders = [:]
        if let accessToken = XeeConnectManager.shared.token?.accessToken {
            headers["Authorization"] = "Bearer " + accessToken
        }
        
        self.request("\(baseURL!)" + "/oauth/revoke", method:.post, encoding:URLEncoding.default, headers:headers).responseObject { (response: DataResponse<XeeObject>) in
            if let error = response.error {
                if let completionHandler = completionHandler {
                    completionHandler(error)
                }
            }else {
                if let completionHandler = completionHandler {
                    completionHandler(nil)
                }
            }
        }
    }
    
    public func getUser(completionHandler: ((_ error: Error?, _ user: XeeUser?) -> Void)? ) {
        
        var headers: HTTPHeaders = [:]
        if let accessToken = XeeConnectManager.shared.token?.accessToken {
            headers["Authorization"] = "Bearer " + accessToken
        }
        
        self.request("\(baseURL!)" + "/users/me", encoding:URLEncoding.default, headers:headers).responseObject { (response: DataResponse<XeeUser>) in
            if let error = response.error {
                if let completionHandler = completionHandler {
                    completionHandler(error, nil)
                }
            }else {
                if let user = response.result.value {
                    if let completionHandler = completionHandler {
                        completionHandler(nil, user)
                    }
                }
            }
        }
    }
    
    public func updateUser(WithUser user:XeeUser, completionHandler: ((_ error: Error?, _ vehicle: XeeUser?) -> Void)? ) {
        
        let parameters: Parameters = user.toJSON()
        
        var headers: HTTPHeaders = [:]
        if let accessToken = XeeConnectManager.shared.token?.accessToken {
            headers["Authorization"] = "Bearer " + accessToken
        }
        
        self.request("\(baseURL!)users/\(user.userID!)", method:.patch, parameters:parameters, encoding:JSONEncoding.default, headers:headers).responseObject { (response: DataResponse<XeeUser>) in
            if let error = response.error {
                if let completionHandler = completionHandler {
                    completionHandler(error, nil)
                }
            }else {
                if let user = response.result.value {
                    if let completionHandler = completionHandler {
                        completionHandler(nil, user)
                    }
                }
            }
        }
    }
    
    public func getVehicles(WithUserID userId:String?, completionHandler: ((_ error: Error?, _ vehicles: [XeeVehicle]?) -> Void)? ) {
        
        var headers: HTTPHeaders = [:]
        if let accessToken = XeeConnectManager.shared.token?.accessToken {
            headers["Authorization"] = "Bearer " + accessToken
        }
        
        var userIDString: String
        if let userID = userId {
            userIDString = userID
        }else {
            userIDString = "me"
        }
        
        self.request("\(baseURL!)users/\(userIDString)/vehicles", headers:headers).responseArray { (response: DataResponse<[XeeVehicle]>) in
            if let error = response.error {
                if let completionHandler = completionHandler {
                    completionHandler(error, nil)
                }
            }else {
                if let vehicles = response.result.value {
                    if let completionHandler = completionHandler {
                        completionHandler(nil, vehicles)
                    }
                }
            }
        }
    }
    
    public func getVehicle(WithVehicleID vehicleId:String, completionHandler: ((_ error: Error?, _ vehicle: XeeVehicle?) -> Void)? ) {
        
        var headers: HTTPHeaders = [:]
        if let accessToken = XeeConnectManager.shared.token?.accessToken {
            headers["Authorization"] = "Bearer " + accessToken
        }
        
        self.request("\(baseURL!)vehicles/\(vehicleId)", headers:headers).responseObject { (response: DataResponse<XeeVehicle>) in
            if let error = response.error {
                if let completionHandler = completionHandler {
                    completionHandler(error, nil)
                }
            }else {
                if let vehicle = response.result.value {
                    if let completionHandler = completionHandler {
                        completionHandler(nil, vehicle)
                    }
                }
            }
        }
    }
    
    public func getStatus(WithVehicleID vehicleId:String, completionHandler: ((_ error: Error?, _ status: XeeStatus?) -> Void)? ) {
        
        var headers: HTTPHeaders = [:]
        if let accessToken = XeeConnectManager.shared.token?.accessToken {
            headers["Authorization"] = "Bearer " + accessToken
        }
        
        self.request("\(baseURL!)vehicles/\(vehicleId)/status", headers:headers).responseObject { (response: DataResponse<XeeStatus>) in
            if let error = response.error {
                if let completionHandler = completionHandler {
                    completionHandler(error, nil)
                }
            }else {
                if let status = response.result.value {
                    if let completionHandler = completionHandler {
                        completionHandler(nil, status)
                    }
                }
            }
        }
    }
    
    public func getTrips(WithVehicleID vehicleId:String, completionHandler: ((_ error: Error?, _ trips: [XeeTrip]?) -> Void)? ) {
        
        self.delegate.taskWillPerformHTTPRedirection = { session, task, response, request in
            var finalRequest = request
            
            if let originalRequest = task.originalRequest, let urlString = originalRequest.url?.absoluteString {
                if urlString.contains("apple.com")
                {
                    finalRequest = originalRequest
                }
            }
            
            return finalRequest
        }
        
        var headers: HTTPHeaders = [:]
        if let accessToken = XeeConnectManager.shared.token?.accessToken {
            headers["Authorization"] = "Bearer " + accessToken
        }
        
        self.request("\(baseURL!)vehicles/\(vehicleId)/trips", headers:headers).responseArray { (response: DataResponse<[XeeTrip]>) in
            if let error = response.error {
                if let completionHandler = completionHandler {
                    completionHandler(error, nil)
                }
            }else {
                if let trips = response.result.value {
                    if let completionHandler = completionHandler {
                        completionHandler(nil, trips)
                    }
                }
            }
        }
    }
    
    public func getTrip(WithTripID tripID:String, completionHandler: ((_ error: Error?, _ trip: XeeTrip?) -> Void)? ) {
        
        var headers: HTTPHeaders = [:]
        if let accessToken = XeeConnectManager.shared.token?.accessToken {
            headers["Authorization"] = "Bearer " + accessToken
        }
        
        self.request("\(baseURL!)trips/\(tripID)", headers:headers).responseObject { (response: DataResponse<XeeTrip>) in
            if let error = response.error {
                if let completionHandler = completionHandler {
                    completionHandler(error, nil)
                }
            }else {
                if let trip = response.result.value {
                    if let completionHandler = completionHandler {
                        completionHandler(nil, trip)
                    }
                }
            }
        }
    }
    
    public func getSignals(WithTripID tripId:String, completionHandler: ((_ error: Error?, _ signals: [XeeSignal]?) -> Void)? ) {
        
        self.delegate.taskWillPerformHTTPRedirection = { session, task, response, request in
            var redirectedRequest = request
            
            if let originalRequest = task.originalRequest, let headers = originalRequest.allHTTPHeaderFields, let authorizationHeaderValue = headers["Authorization"] {
                let mutableRequest = request as! NSMutableURLRequest
                mutableRequest.setValue(authorizationHeaderValue, forHTTPHeaderField: "Authorization")
                redirectedRequest = mutableRequest as URLRequest
            }
            
            return redirectedRequest
        }
        
        var headers: HTTPHeaders = [:]
        if let accessToken = XeeConnectManager.shared.token?.accessToken {
            headers["Authorization"] = "Bearer " + accessToken
        }
        
        self.request("\(baseURL!)trips/\(tripId)/signals", headers:headers).responseArray { (response: DataResponse<[XeeSignal]>) in
            if let error = response.error {
                if let completionHandler = completionHandler {
                    completionHandler(error, nil)
                }
            }else {
                if let signals = response.result.value {
                    if let completionHandler = completionHandler {
                        completionHandler(nil, signals)
                    }
                }
            }
        }
    }
    
    public func getLocations(WithTripID tripId:String, completionHandler: ((_ error: Error?, _ locations: [XeeLocation]?) -> Void)? ) {
        
        self.delegate.taskWillPerformHTTPRedirection = { session, task, response, request in
            var redirectedRequest = request
            
            if let originalRequest = task.originalRequest, let headers = originalRequest.allHTTPHeaderFields, let authorizationHeaderValue = headers["Authorization"] {
                let mutableRequest = request as! NSMutableURLRequest
                mutableRequest.setValue(authorizationHeaderValue, forHTTPHeaderField: "Authorization")
                redirectedRequest = mutableRequest as URLRequest
            }
            
            return redirectedRequest
        }
        
        var headers: HTTPHeaders = [:]
        if let accessToken = XeeConnectManager.shared.token?.accessToken {
            headers["Authorization"] = "Bearer " + accessToken
        }
        
        self.request("\(baseURL!)trips/\(tripId)/locations", headers:headers).responseArray { (response: DataResponse<[XeeLocation]>) in
            if let error = response.error {
                if let completionHandler = completionHandler {
                    completionHandler(error, nil)
                }
            }else {
                if let locations = response.result.value {
                    if let completionHandler = completionHandler {
                        completionHandler(nil, locations)
                    }
                }
            }
        }
    }
    
    public func updateVehicle(WithVehicle vehicle:XeeVehicle, completionHandler: ((_ error: Error?, _ vehicle: XeeVehicle?) -> Void)? ) {
        
        let parameters: Parameters = vehicle.toJSON()
        
        var headers: HTTPHeaders = [:]
        if let accessToken = XeeConnectManager.shared.token?.accessToken {
            headers["Authorization"] = "Bearer " + accessToken
        }
        
        self.request("\(baseURL!)vehicles/\(vehicle.vehiculeID!)", method:.patch, parameters:parameters, encoding:JSONEncoding.default, headers:headers).responseObject { (response: DataResponse<XeeVehicle>) in
            if let error = response.error {
                if let completionHandler = completionHandler {
                    completionHandler(error, nil)
                }
            }else {
                if let vehicle = response.result.value {
                    if let completionHandler = completionHandler {
                        completionHandler(nil, vehicle)
                    }
                }
            }
        }
    }
    
    public func getDevice(ForVehicleID vehicleId:String, completionHandler: ((_ error: Error?, _ vehicle: XeeDevice?) -> Void)? ) {
        
        var headers: HTTPHeaders = [:]
        if let accessToken = XeeConnectManager.shared.token?.accessToken {
            headers["Authorization"] = "Bearer " + accessToken
        }
        
        self.request("\(baseURL!)vehicles/\(vehicleId)/device", headers:headers).responseObject { (response: DataResponse<XeeDevice>) in
            if let error = response.error {
                if let completionHandler = completionHandler {
                    completionHandler(error, nil)
                }
            }else {
                if let device = response.result.value {
                    if let completionHandler = completionHandler {
                        completionHandler(nil, device)
                    }
                }
            }
        }
    }
    
    public func getPrivacies(ForVehicleID vehicleId:String, From from:Date?, To to:Date?, Limit limit:Int?, completionHandler: ((_ error: Error?, _ privacies: [XeePrivacy]?) -> Void)? ) {
        
        var parameters: Parameters = [:]
        if let from = from {
            parameters["from"] = from.iso8601
        }
        if let to = to {
            parameters["to"] = to.iso8601
        }
        if let limit = limit {
            parameters["limit"] = limit
        }
        
        var headers: HTTPHeaders = [:]
        if let accessToken = XeeConnectManager.shared.token?.accessToken {
            headers["Authorization"] = "Bearer " + accessToken
        }
        
        self.request("\(baseURL!)vehicles/\(vehicleId)/privacies", parameters:parameters, headers:headers).responseArray { (response: DataResponse<[XeePrivacy]>) in
            if let error = response.error {
                if let completionHandler = completionHandler {
                    completionHandler(error, nil)
                }
            }else {
                if let privacies = response.result.value {
                    if let completionHandler = completionHandler {
                        completionHandler(nil, privacies)
                    }
                }
            }
        }
    }
    
    public func startPrivacy(ForVehicleID vehicleId:String, completionHandler: ((_ error: Error?, _ privacy: XeePrivacy?) -> Void)? ) {
        
        var headers: HTTPHeaders = [:]
        if let accessToken = XeeConnectManager.shared.token?.accessToken {
            headers["Authorization"] = "Bearer " + accessToken
        }
        
        self.request("\(baseURL!)vehicles/\(vehicleId)/privacies", method:.post, headers:headers).responseObject { (response: DataResponse<XeePrivacy>) in
            if let error = response.error {
                if let completionHandler = completionHandler {
                    completionHandler(error, nil)
                }
            }else {
                if let privacy = response.result.value {
                    if let completionHandler = completionHandler {
                        completionHandler(nil, privacy)
                    }
                }
            }
        }
    }
    
    public func stopPrivacy(ForVPrivacyID privacyID:String, completionHandler: ((_ error: Error?, _ privacy: XeePrivacy?) -> Void)? ) {
        
        var headers: HTTPHeaders = [:]
        if let accessToken = XeeConnectManager.shared.token?.accessToken {
            headers["Authorization"] = "Bearer " + accessToken
        }
        
        self.request("\(baseURL!)privacies/\(privacyID)", method:.put, headers:headers).responseObject { (response: DataResponse<XeePrivacy>) in
            if let error = response.error {
                if let completionHandler = completionHandler {
                    completionHandler(error, nil)
                }
            }else {
                if let privacy = response.result.value {
                    if let completionHandler = completionHandler {
                        completionHandler(nil, privacy)
                    }
                }
            }
        }
    }
    
    public func associateVehicle(WithXeeConnectId xeeConnectId:String, PinCode pin: String, completionHandler: ((_ error: Error?, _ privacy: XeePrivacy?) -> Void)? ) {
        
        var headers: HTTPHeaders = [:]
        if let accessToken = XeeConnectManager.shared.token?.accessToken {
            headers["Authorization"] = "Bearer " + accessToken
        }
        
        var parameters: Parameters = [:]
        parameters["deviceId"] = xeeConnectId
        parameters["devicePin"] = pin
        
        self.request("\(baseURL!)users/me/vehicles", method:.post, parameters:parameters, encoding:JSONEncoding.default, headers:headers).responseObject { (response: DataResponse<XeePrivacy>) in
            if let error = response.error {
                if let completionHandler = completionHandler {
                    completionHandler(error, nil)
                }
            }else {
                if let privacy = response.result.value {
                    if let completionHandler = completionHandler {
                        completionHandler(nil, privacy)
                    }
                }
            }
        }
    }

}
