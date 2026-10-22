# Kivora Verification Capabilities & Limitations

Kivora transparently documents the technical boundaries of each verification modality. System interfaces and audit logs never make unverified legal presence guarantees.

---

## 1. Device Biometric Prompts
- **Mechanism**: Invokes OS-level APIs (`LocalAuthentication` on iOS, `BiometricManager` / `BiometricPrompt` on Android) via the Flutter package `local_auth`.
- **Guarantee**: Confirms that the person holding the unlocked phone was able to satisfy the device's local biometric or passcode challenge.
- **Limitations**:
  - Does not cryptographically tie the phone's biometric hardware to Kivora's server unless hardware-attested keypairs are provisioned.
  - Does not verify physical location.
  - Shared family devices may have multiple fingerprints registered in OS settings.
  - Raw biometric data is inaccessible to the application.

## 2. GPS Geofencing
- **Mechanism**: Device reports latitude, longitude, and accuracy radius via `geolocator`. Server checks proximity to branch center coordinates using Haversine calculation.
- **Guarantee**: Verifies that the client OS reported coordinates within the designated radius at the moment of request submission.
- **Limitations**:
  - GPS signals can suffer from urban canyoning, indoor multipath interference, and low satellite accuracy.
  - Coordinates can be manipulated on rooted/jailbroken devices or via developer mock location providers.
  - Low accuracy readings (> 50m radius) trigger `needs_review` rather than arbitrary punitive failure.

## 3. Network Verification
- **Mechanism**: Inspects client IP address against configured organizational public subnets or trusted gateways.
- **Guarantee**: Confirms the request traversed a network interface configured as trusted by the branch.
- **Limitations**:
  - Wi-Fi SSID alone is spoofable and weak evidence.
  - Cellular carrier CGNAT and dynamic residential/commercial IPs can result in false mismatches unless static corporate egress IPs or hardware verifiers are used.

## 4. QR Code Identification
- **Mechanism**: Renders a dynamic or static member identifier token.
- **Guarantee**: Facilitates rapid scanning and record lookup in administrative or kiosk contexts.
- **Limitations**:
  - Scanning a static QR code alone is not proof of physical attendance, as QR codes can be photographed or forwarded unless combined with one-time rotating OTP signatures and location checks.
