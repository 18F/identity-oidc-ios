//
//  LoginGovService.swift
//  OpenIDConnectExample
//
//  Created by Zachary Margolis on 1/30/17.
//  Copyright © 2017 GSA. All rights reserved.
//

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

    static func serviceConfiguration() -> OIDServiceConfiguration {
        let authorizationURL = baseURL.appendingPathComponent("/openid_connect/authorize")
        let tokenURL = baseURL.appendingPathComponent("/openid_connect/token")

        return OIDServiceConfiguration.init(authorizationEndpoint: authorizationURL, tokenEndpoint: tokenURL)
    }

    static func authorizationRequest() -> OIDAuthorizationRequest {
        return OIDAuthorizationRequest.init(
            configuration: serviceConfiguration(),
            clientId: clientId,
            scopes: scopes,
            redirectURL: redirectURL,
            responseType: "code",
            additionalParameters: additionalAuthParameters)
    }

    static func tokenRequest(authorizationCode : String) -> OIDTokenRequest {
        let additionalTokenParameters = [
            "client_assertion": tokenRequestJWT(),
            "client_assertion_type": "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
        ]

        return OIDTokenRequest.init(
            configuration: serviceConfiguration(),
            grantType: "authorization_code",
            authorizationCode: authorizationCode,
            redirectURL: redirectURL,
            clientID: clientId,
            clientSecret: nil,
            scope: nil,
            refreshToken: nil,
            codeVerifier: nil,
            additionalParameters: additionalTokenParameters)!
    }

    private static func tokenRequestJWT() -> String {
        let payload : [String : Any] = [
            "iss": clientId,
            "sub": clientId,
            "aud": serviceConfiguration().tokenEndpoint.absoluteString,
            "jti": UUID.init().uuidString,
            "exp": Date.init().addingTimeInterval(1000).timeIntervalSince1970
        ]

        // TODO: do NOT bundle private key into app
        let keyURL = Bundle.main.url(forResource: "saml_test_sp", withExtension: "p12")
        var data : Data
        do {
            try data = Data.init(contentsOf: keyURL!)
        } catch {
            return "";
        }

        return JWT.encodePayload(payload)!
                  .secretData(data)!
                  .algorithmName(JWTAlgorithmNameRS256)!
                  .privateKeyCertificatePassphrase("")!
                  .encode
    }
}
