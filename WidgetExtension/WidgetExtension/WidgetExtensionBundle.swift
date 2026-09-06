import WidgetKit
import SwiftUI

@main
struct CalculatorWidgetBundle: WidgetBundle {
    var body: some Widget {
        CalculatorHomeWidget()
        CalculatorHistoryWidget()
        CalculatorLockScreenWidget()
    }
}
