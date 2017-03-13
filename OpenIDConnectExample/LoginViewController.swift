import UIKit
import AppAuth

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearError()
        self.stopSpinning()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!

    @IBAction func didSelectLoginGov(_ sender: Any) {
        self.clearError()
        self.startSpinning()

        let delegate = UIApplication.shared.delegate! as! AppDelegate

        LoginGovService.discoverConfiguration() { (serviceConfiguration : OIDServiceConfiguration?, error: Error?) in
            guard let serviceConfiguration = serviceConfiguration else {
                self.showError(error: error!)
                return
            }

            let authRequest = LoginGovService.authorizationRequest(serviceConfiguration: serviceConfiguration)

            delegate.currentAuthorizationSession = OIDAuthorizationService
                .present(authRequest, presenting: self) { (authReponse: OIDAuthorizationResponse?, error: Error?) in

                    guard let authorizationCode = authReponse?.authorizationCode else {
                        self.showError(error: error!)
                        return
                    }

                    let tokenRequest = LoginGovService.tokenRequest(
                        serviceConfiguration: serviceConfiguration,
                        authorizationCode: authorizationCode,
                        codeVerifier: authRequest.codeVerifier!
                    )
                    OIDAuthorizationService.perform(tokenRequest) { (tokenResponse : OIDTokenResponse?, error : Error?) in
                        guard let accessToken = tokenResponse?.accessToken else {
                            self.showError(error: error!)
                            return
                        }

                        LoginGovService.loadUserinfo(serviceConfiguration: serviceConfiguration, accessToken: accessToken, callback: { (json : Any?, error : Error?) in
                            if let json = json {
                                self.showProfile(json: json)
                            } else if let error = error {
                                self.showError(error: error)
                            }
                        })
                    }
                }
        }
    }

    private func showProfile(json : Any) {
        self.stopSpinning()

        let profileController = self.storyboard?.instantiateViewController(withIdentifier: "Profile") as! ProfileController
        profileController.updateProfile(json: json)

        self.navigationController?.pushViewController(profileController, animated: true)
    }

    private func showError(error : Error) {
        self.stopSpinning()

        self.errorLabel.text = error.localizedDescription
        self.errorLabel.isHidden = false;
    }

    private func clearError() {
        self.errorLabel.isHidden = true
    }

    private func startSpinning() {
        self.spinner.isHidden = false
        self.spinner.startAnimating()
    }

    private func stopSpinning() {
        self.spinner.isHidden = true
        self.spinner.stopAnimating()
    }
}

