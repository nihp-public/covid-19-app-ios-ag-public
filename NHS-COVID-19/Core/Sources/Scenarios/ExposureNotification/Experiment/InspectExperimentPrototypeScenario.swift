//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

@available(iOSApplicationExtension, unavailable)
public class InspectExperimentPrototypeScenario: Scenario {
    public static let name = "Inspect Experiment"
    public static let kind = ScenarioKind.prototype
    
    static var appController: AppController {
        InspectExperimentAppController()
    }
}
