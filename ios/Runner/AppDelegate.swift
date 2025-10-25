import Flutter
import UIKit
import ActivityKit

@main
@objc class AppDelegate: FlutterAppDelegate {

    private var currentSpriteName: String?
    private var currentSpriteId: Int?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        // 监听应用进入后台
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        // 监听应用回到前台
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )

        setupDynamicIslandChannel()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    @objc func appDidEnterBackground() {
        print("应用进入后台，准备显示灵动岛")
        // 使用从 Flutter 设置的精灵信息
        if let name = currentSpriteName, let id = currentSpriteId {
            DynamicIslandManager.shared.showSpriteInBackground(
                spriteName: name,
                spriteId: id
            )
        } else {
            print("没有设置当前精灵信息")
        }
    }

    @objc func appWillEnterForeground() {
        print("应用回到前台，隐藏灵动岛")
        DynamicIslandManager.shared.hideDynamicIsland()
    }

    private func setupDynamicIslandChannel() {
        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(
            name: "dynamic_island",
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler { [weak self] (call, result) in
            self?.handleDynamicIslandCall(call: call, result: result)
        }
    }

    private func handleDynamicIslandCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if #available(iOS 16.1, *) {
            switch call.method {
            case "setCurrentSprite":
                if let arguments = call.arguments as? [String: Any] {
                    let name = arguments["name"] as? String ?? "未知精灵"
                    let id = arguments["id"] as? Int ?? 0
                    // 保存精灵信息到本地变量
                    self.currentSpriteName = name
                    self.currentSpriteId = id
                    print("保存精灵信息: \(name) (ID: \(id))")
                    result(nil)
                }

            case "showInBackground":
                if let name = self.currentSpriteName, let id = self.currentSpriteId {
                    DynamicIslandManager.shared.showSpriteInBackground(spriteName: name, spriteId: id)
                    result(nil)
                } else {
                    result(FlutterError(code: "NO_SPRITE_DATA", message: "没有设置精灵信息", details: nil))
                }

            case "hideDynamicIsland":
                DynamicIslandManager.shared.hideDynamicIsland()
                result(nil)

            default:
                result(FlutterMethodNotImplemented)
            }
        } else {
            result(FlutterError(code: "UNSUPPORTED_IOS_VERSION", message: "需要iOS 16.1或更高版本", details: nil))
        }
    }
}

// 灵动岛管理器
@available(iOS 16.1, *)
class DynamicIslandManager {
    static let shared = DynamicIslandManager()
    private var currentActivity: Activity<SpriteAttributes>?

    private init() {}

    func showSpriteInBackground(spriteName: String, spriteId: Int) {
        print("在后台显示灵动岛: \(spriteName) (ID: \(spriteId))")

        // 先隐藏之前的活动
        hideDynamicIsland()

        // 创建后台活动
        createBackgroundActivity(spriteName: spriteName, spriteId: spriteId)
    }

    private func createBackgroundActivity(spriteName: String, spriteId: Int) {
        let attributes = SpriteAttributes(spriteName: spriteName)
        let state = SpriteAttributes.ContentState(spriteId: spriteId)

        do {
            let activity = try Activity<SpriteAttributes>.request(
                attributes: attributes,
                contentState: state,
                pushType: nil
            )

            currentActivity = activity
            print("后台灵动岛活动创建成功: \(activity.id)")

        } catch {
            print("创建后台灵动岛活动失败: \(error.localizedDescription)")
        }
    }

    func hideDynamicIsland() {
        guard let activity = currentActivity else { return }

        Task {
            await activity.end(dismissalPolicy: .immediate)
            currentActivity = nil
            print("灵动岛活动已结束")
        }
    }
}

@available(iOS 16.1, *)
struct SpriteAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var spriteId: Int
    }

    var spriteName: String
}