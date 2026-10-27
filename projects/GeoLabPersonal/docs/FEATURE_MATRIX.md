# Comparison: Locanger vs GeoLab Personal 0.2.0

Evidence: user-provided screenshots and the earlier static IPA analysis. Statuses are not guarantees of original product behavior.

| Capability | Locanger evidence | GeoLab Personal 0.2.0 |
|---|---|---|
| SwiftUI / Arabic map user interface | Screenshots | Implemented |
| Apple Maps / map styles / 3D | Screenshots | Implemented |
| Map search / coordinate selection | Screenshots | Implemented |
| Favorites, categories | Screenshots | Implemented |
| Search/selection history | Static analysis | Implemented selection history |
| Fixed, walking, cycling, driving, flight | Screenshots | In-app preview modes |
| Joystick | Screenshots/static analysis | In-app manual movement |
| Route authoring/import | App supports movement routes | Implemented GPX route authoring/import |
| Route playback | Movement capability | Implemented in-app interpolation |
| Altitude, accuracy sliders | Screenshots | Test-model variables only |
| Developer pairing / DDI | Static analysis/screenshots | Not implemented |
| Packet tunnel / VPN | Static analysis/screenshots | Not implemented |
| System-wide location simulation | Static analysis shows APIs; runtime not independently verified | Not implemented |
| Background persistence of system changes | Claimed in UI; not verified | Not implemented |
| Anti-ban/drift masking | UI claim, not verified | Not implemented |
| Local geofence/accuracy/fix-age checks | Unknown | Implemented |
| CoreLocation source info flag | Unknown | Implemented |
| CI simulator and device compilation | Unknown | Workflow created (requires GitHub Actions to run) |

Changes deliberately exclude third-party attendance spoofing and anti-detection.
