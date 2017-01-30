//
//  LoginGovService.swift
//  OpenIDConnectExample
//
//  Created by Zachary Margolis on 1/30/17.
//  Copyright © 2017 GSA. All rights reserved.
//

import Foundation
import AppAuth

class LoginGovService {
    static let baseURL = URL(string: "http://localhost:3000")!
    static let clientId = "urn:gov:gsa:openidconnect:development"
    static let scopes = ["profile", "openid"]
    static let redirectURL = URL(string: "gov.gsa.openidconnect.development://result")!
    static let additionalParameters = [
        "prompt" : "select_account",
        "acr_values" : "http://idmanagement.gov/ns/assurance/loa/3"
    ]

    static func authorizationRequest() -> OIDAuthorizationRequest {
        let authorizationURL = baseURL.appendingPathComponent("/openid_connect/authorize")
        let tokenURL = baseURL.appendingPathComponent("/openid_connect/token")

        let serviceConfiguration = OIDServiceConfiguration.init(authorizationEndpoint: authorizationURL, tokenEndpoint: tokenURL)

        return OIDAuthorizationRequest.init(
            configuration: serviceConfiguration,
            clientId: clientId,
            scopes: scopes,
            redirectURL: redirectURL,
            responseType: "code",
            additionalParameters: additionalParameters)
    }
}
