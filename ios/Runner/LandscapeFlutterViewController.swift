import Flutter
import UIKit

class LandscapeFlutterViewController: FlutterViewController {
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    .landscape
  }

  override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
    .landscapeRight
  }

  override var shouldAutorotate: Bool {
    true
  }
}
