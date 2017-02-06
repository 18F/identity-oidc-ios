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

        LoginGovService.serviceConfiguration() { (configuration: OIDServiceConfiguration?, error: Error?) in
            guard let configuration = configuration else {
                self.showError(error: error!)
                return
            }

            let authRequest = LoginGovService.authorizationRequest(configuration: configuration)

            delegate.currentAuthorizationSession = OIDAuthorizationService.present(authRequest, presenting: self) { (authReponse: OIDAuthorizationResponse?, error: Error?) in

                guard let authorizationCode = authReponse?.authorizationCode else {
                    self.showError(error: error!)
                    return
                }

                let tokenRequest = LoginGovService.tokenRequest(
                    configuration: configuration,
                    authorizationCode: authorizationCode,
                    codeVerifier: authRequest.codeVerifier!
                )
                OIDAuthorizationService.perform(tokenRequest) { (tokenResponse : OIDTokenResponse?, error : Error?) in
                    guard let accessToken = tokenResponse?.accessToken else {
                        self.showError(error: error!)
                        return
                    }

                    LoginGovService.loadUserinfo(configuration: configuration, accessToken: accessToken, callback: { (json : Any?, error : Error?) in
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

        let navigationController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileNavigation") as! UINavigationController

        let profileController = navigationController.viewControllers.first as! ProfileController
        profileController.updateProfile(json: json)

        self.present(navigationController, animated: true, completion: nil)
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

