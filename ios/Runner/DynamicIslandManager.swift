// ios/Runner/DynamicIslandManager.swift
import ActivityKit
import Flutter

@available(iOS 16.1, *)
class DynamicIslandManager {

    func showSpriteInDynamicIsland(arguments: [String: Any]) {
        // iOS 开发者需要实现这部分
        // 使用 ActivityKit 创建 Live Activity
        print("显示精灵到灵动岛: \(arguments)")
    }

    func hideDynamicIsland() {
        // iOS 开发者需要实现这部分
        // 结束所有 Live Activities
        print("隐藏灵动岛")
    }
}