//
//  JakesWidgetsExtensionLiveActivity.swift
//  JakesWidgetsExtension
//
//  Created by Jake Huebner on 7/24/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct JakesWidgetsExtensionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct JakesWidgetsExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: JakesWidgetsExtensionAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension JakesWidgetsExtensionAttributes {
    fileprivate static var preview: JakesWidgetsExtensionAttributes {
        JakesWidgetsExtensionAttributes(name: "World")
    }
}

extension JakesWidgetsExtensionAttributes.ContentState {
    fileprivate static var smiley: JakesWidgetsExtensionAttributes.ContentState {
        JakesWidgetsExtensionAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: JakesWidgetsExtensionAttributes.ContentState {
         JakesWidgetsExtensionAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: JakesWidgetsExtensionAttributes.preview) {
   JakesWidgetsExtensionLiveActivity()
} contentStates: {
    JakesWidgetsExtensionAttributes.ContentState.smiley
    JakesWidgetsExtensionAttributes.ContentState.starEyes
}
