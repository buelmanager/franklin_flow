import Flutter
import UIKit
// ✨ flutter_local_notifications 임포트 추가
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // flutter_local_notifications: UNUserNotificationCenter delegate 설정
    // 이 설정이 있어야 앱이 실행 중일 때도 알림이 표시됩니다
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    // flutter_local_notifications: Plugin Registrant 콜백 설정
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        GeneratedPluginRegistrant.register(with: registry)
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Foreground Notification Handling
  // ─────────────────────────────────────────────────────────────────────────

  /// 앱이 foreground 상태일 때 알림을 어떻게 표시할지 결정
  /// 이 메서드가 없으면 앱 실행 중에는 알림이 표시되지 않습니다
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // iOS 14 이상: 배너, 사운드, 배지 모두 표시
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .sound, .badge])
    }
    // iOS 13 이하: alert, 사운드, 배지 표시
    else {
      completionHandler([.alert, .sound, .badge])
    }
  }

  /// 사용자가 알림을 탭했을 때 처리
  /// 알림을 탭하면 앱이 열리고 특정 화면으로 이동하는 등의 처리 가능
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    // 알림 payload 확인 (선택사항)
    let userInfo = response.notification.request.content.userInfo

    // TODO: payload에 따라 특정 화면으로 이동하는 로직 추가 가능
    // 예: if payload == "morning" → 아침 의도 화면으로 이동

    completionHandler()
  }
}