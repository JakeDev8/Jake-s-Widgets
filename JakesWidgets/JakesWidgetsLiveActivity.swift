//
//  JakesWidgetsLiveActivity.swift
//  JakesWidgets
//
//  Created by Jake Huebner on 7/29/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct JakesWidgetsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct JakesWidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: JakesWidgetsAttributes.self) { context in
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

extension JakesWidgetsAttributes {
    fileprivate static var preview: JakesWidgetsAttributes {
        JakesWidgetsAttributes(name: "World")
    }
}

extension JakesWidgetsAttributes.ContentState {
    fileprivate static var smiley: JakesWidgetsAttributes.ContentState {
        JakesWidgetsAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: JakesWidgetsAttributes.ContentState {
         JakesWidgetsAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: JakesWidgetsAttributes.preview) {
   JakesWidgetsLiveActivity()
} contentStates: {
    JakesWidgetsAttributes.ContentState.smiley
    JakesWidgetsAttributes.ContentState.starEyes
}
