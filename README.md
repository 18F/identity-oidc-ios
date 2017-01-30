# login.gov
## Sample OpenID Connect iOS Client

A sample iOS app that uses the login.gov OpenID Connect 1.0 endpoints

## Developing

```
open OpenIDConnectExample.xcworkspace
```

## Dependencies

We use Cocoapods to manage dependencies, and check dependency source into our example repo.

To install dependencies (assuming [Cocoapods has been installed][cocoapods-install]).

[cocoapods-install]: https://guides.cocoapods.org/using/getting-started.html

```
pod install
```

- **[AppAuth](https://github.com/openid/AppAuth-iOS)**: For working with OpenID Connect 1.0 APIs

- **[JWT](https://github.com/yourkarma/jwt)**: For creating, signing, and decoding JWT tokens
