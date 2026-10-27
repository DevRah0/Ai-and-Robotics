# iOS signing and installation

The GitHub Action compiles an iOS simulator `.app` and an **unsigned** device `.ipa`.
The latter is a build artifact only; iOS won't install it as-is.

For on-device installation, use Xcode with your Apple team and a valid development
provisioning profile, or create an Ad Hoc distribution profile that includes your
device's UDID. Never commit certificates, private keys, `.p12`, or provisioning
profiles to source control. A signed CI distribution workflow requires secrets,
carefully scoped keychains, a matching bundle identifier, and a registered device.

Recommended procedure:
1. On a Mac, open `GeoLab.xcodeproj`.
2. Choose Signing & Capabilities → your Apple Development Team.
3. Change `PRODUCT_BUNDLE_IDENTIFIER` to your unique identifier.
4. Connect the device, authorize developer mode, then Build and Run.
5. Test local route preview and CoreLocation diagnostics separately.

This application intentionally does not affect the GPS supplied to other apps.
