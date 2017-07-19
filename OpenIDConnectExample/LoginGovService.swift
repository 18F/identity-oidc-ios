import Foundation
import AppAuth
import SafariServices

class LoginGovService {
    static let baseURL = URL(string: "http://localhost:3000")!
    static let clientId = "urn:gov:gsa:openidconnect:development"
    static let scopes = ["profile", "openid"]
    static let redirectURL = URL(string: "gov.gsa.openidconnect.development://result")!

    class LogoutSession {
        static let logoutPath = "/logout"
        static let postLogoutRedirectURL = redirectURL.appendingPathComponent(logoutPath)

        var serviceConfiguration : OIDServiceConfiguration
        var idToken : String

        var state : String?
        var presentingViewController : UIViewController?
        var callback : (() -> Void)?

        init(serviceConfiguration : OIDServiceConfiguration, idToken : String) {
            self.serviceConfiguration = serviceConfiguration
            self.idToken = idToken
        }

        func present(presenting: UIViewController, callback : @escaping () -> Void) {
            let state = UUID.init().uuidString
            self.state = state
            self.callback = callback
            self.presentingViewController = presenting

            let safariViewController = SFSafariViewController.init(url: logoutUrl(state: state))
            presenting.navigationController!.pushViewController(safariViewController, animated: false)
        }

        func resumeLogout(with url: URL) -> Bool {
            guard let url = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return false }
            let state = url.queryItems?.first(where: { $0.name == "state" })?.value

            if (url.string!.hasPrefix(LogoutSession.postLogoutRedirectURL.absoluteString) && self.state == state) {
                presentingViewController?.navigationController?.popViewController(animated: false)
                callback!();
                return true;
            } else {
                return false;
            }
        }

        private func logoutUrl(state: String) -> URL {
            let logoutURLBase = serviceConfiguration.discoveryDocument?.discoveryDictionary["end_session_endpoint"] as! String

            let logoutURL = logoutURLBase.appending("?id_token_hint=")
                .appending(idToken.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
                .appending("&post_logout_redirect_uri=")
                .appending(LogoutSession.postLogoutRedirectURL.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
                .appending("&state=")
                .appending(state.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)

            return URL.init(string: logoutURL)!
        }
    }

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
            additionalParameters: additionalAuthParameters())
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

    private static func additionalAuthParameters() -> [String : String] {
        return [
            "prompt" : "select_account",
            "acr_values" : "http://idmanagement.gov/ns/assurance/loa/3",
            "nonce" : UUID().uuidString
        ]
    }

}
