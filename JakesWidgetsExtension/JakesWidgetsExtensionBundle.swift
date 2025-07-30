//
//  JakesWidgetsExtensionBundle.swift
//  JakesWidgetsExtension
//
//  Created by Jake Huebner on 7/24/25.
//

import WidgetKit
import SwiftUI

@main
struct JakesWidgetsExtensionBundle: WidgetBundle {
    var body: some Widget {
        JakesWidgetsExtension()
        JakesWidgetsExtensionControl()
        JakesWidgetsExtensionLiveActivity()
    }
}
