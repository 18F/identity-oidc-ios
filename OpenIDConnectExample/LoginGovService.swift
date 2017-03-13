import Foundation
import AppAuth
import JWT

class LoginGovService {
    static let baseURL = URL(string: "http://localhost:3000")!
    static let clientId = "urn:gov:gsa:openidconnect:development"
    static let scopes = ["profile", "openid"]
    static let redirectURL = URL(string: "gov.gsa.openidconnect.development://result")!
    static let additionalAuthParameters = [
        "prompt" : "select_account",
        "acr_values" : "http://idmanagement.gov/ns/assurance/loa/3"
    ]

    static func discoverConfiguration(callback : @escaping OIDDiscoveryCallback) {
        OIDAuthorizationService.discoverConfiguration(forIssuer: baseURL, completion: callback)
    }

    static func authorizationRequest(serviceConfiguration: OIDServiceConfiguration) -> OIDAuthorizationRequest {
        return OIDAuthorizationRequest.init(
            configuration: serviceConfiguration,
            clientId: clientId,
            clientSecret: nil,
            scopes: scopes,
            redirectURL: redirectURL,
            responseType: "code",
            additionalParameters: additionalAuthParameters)
    }

    static func tokenRequest(serviceConfiguration: OIDServiceConfiguration, authorizationCode : String, codeVerifier : String) -> OIDTokenRequest {
        return OIDTokenRequest.init(
            configuration: serviceConfiguration,
            grantType: "authorization_code",
            authorizationCode: authorizationCode,
            redirectURL: redirectURL,
            clientID: clientId,
            clientSecret: nil,
            scope: nil,
            refreshToken: nil,
            codeVerifier: codeVerifier,
            additionalParameters: nil)!
    }

    static func loadUserinfo(serviceConfiguration: OIDServiceConfiguration, accessToken : String, callback : @escaping (Any?, Error?) -> Void) {
        var urlRequest = URLRequest.init(url: serviceConfiguration.discoveryDocument!.userinfoEndpoint!)
        urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let urlSession = URLSession.init(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        let dataTask = urlSession.dataTask(with: urlRequest) { (data : Data?, response : URLResponse?, err : Error?) in
            var json : Any?
            var error = err
            if  let data = data {
                do {
                    try json = JSONSerialization.jsonObject(with: data, options: .allowFragments)
                } catch (let err) {
                    error = err
                }
            }
            DispatchQueue.main.async {
                callback(json, error)
            }
        }
        dataTask.resume()
    }
}
