//
//@testable import TealiumAppData
@testable import TealiumCollect
//@testable import TealiumConnectivity
@testable import TealiumConsentManager
@testable import TealiumCore
//@testable import TealiumDelegate
//@testable import TealiumDeviceData
//@testable import TealiumLogger
//@testable import TealiumPersistentData
@testable import TealiumVisitorService
//@testable import TealiumVolatileData
//@testable import TealiumLogger
import XCTest

class TealiumModulesTest: XCTestCase {

    let numberOfCurrentModules = TestTealiumHelper.allTealiumModuleNames().count

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testNilModulesList() {
        // If nil assigned will return defaults
        //        let modules = TealiumModules.initializeModulesFor(nil, assigningDelegate: self)
        //
        //        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
        //            XCTAssert(modules.count == self.numberOfCurrentModules, "Count detected: \(modules.count)\nExpected:\(self.numberOfCurrentModules)")
        //        }
    }

    func testBlacklistSingleModule() {
        let modulesList = TealiumModulesList(isWhitelist: false,
                                             moduleNames: ["visitorService"])

        let config = TealiumConfig(account: "test",
                                   profile: "test",
                                   environment: "dev")

        //        config.modulesList = modulesList
        //
        //        let modules = TealiumModules.initializeModulesFor(config.modulesList,
        //                                                          assigningDelegate: self)

        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
            //            XCTAssert(modules.count == (self.numberOfCurrentModules - modulesList.moduleNames.count), "Modules contains incorrect number: \(modules)")
            //
            //            for module in modules {
            //                XCTAssert(!(module is TealiumVisitorServiceModule), "Visitor service module was found when shouldn't have been present.")
            //            }
        }
    }

    func testBlacklistMultipleModules() {
        let modulesList = TealiumModulesList(isWhitelist: false,
                                             moduleNames: ["consentmanger", "visitorSerVice"])

        let config = TealiumConfig(account: "test",
                                   profile: "test",
                                   environment: "dev")

        //        config.modulesList = modulesList
        //
        //        let modules = TealiumModules.initializeModulesFor(config.modulesList,
        //                                                          assigningDelegate: self)

        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
            //            XCTAssert(modules.count == (self.numberOfCurrentModules - modulesList.moduleNames.count), "Modules contains incorrect number: \(modules)")

            //            for module in modules {
            //                if module is TealiumVisitorServiceModule {
            //                    XCTFail("Logger module was found when shouldn't have been present.")
            //                }
            //                if module is TealiumConsentManagerModule {
            //                    XCTFail("TealiumConsentManagerModule module was found when shouldn't have been present.")
            //                }
            //            }

        }
    }

    func testEnableSingleModuleFromWhitelistConfig() {
        //        let config = TealiumConfig(account: "tealiummobile",
        //                                   profile: "demo",
        //                                   environment: "dev",
        //                                   optionalData: nil)
        //
        //        let modulesList = TealiumModulesList(isWhitelist: true,
        //                                             moduleNames: ["VisitorSerVice"])
        //
        //        config.modulesList = modulesList
        //
        //        let modules = TealiumModules.initializeModulesFor(config.modulesList,
        //                                                          assigningDelegate: self)
        //
        //        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
        //            XCTAssert(modules.count == modulesList.moduleNames.count, "Modules contains too many elements: \(modules)")
        //
        //            let module = modules[0]
        //
        //            if module is TealiumVisitorServiceModule {
        //                // How in the world do we do a 'is not' in Swift?
        //            } else {
        //                XCTFail("Incorrect module loaded: \(module)")
        //                return
        //            }
        //        }
    }

    func testEnableFromConfigWithWhitelistNoModulesListed() {
        // Should auto load - currently 15 modules
        let config = TealiumConfig(account: "tealiummobile",
                                   profile: "demo",
                                   environment: "dev",
                                   optionalData: nil)

        //        let list = config.modulesList
        //
        //        let modules = TealiumModules.initializeModulesFor(list,
        //                                                          assigningDelegate: self)
        //
        //        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
        //            XCTAssert(modules.count == self.numberOfCurrentModules, "Modules contains incorrect number of modules: \(modules)")
        //        }
    }

    func testEnableFromConfigWithWhitelistMultipleModulesListed() {
        let config = TealiumConfig(account: "tealiummobile",
                                   profile: "demo",
                                   environment: "dev",
                                   optionalData: nil)

        //        let modulesList = TealiumModulesList(isWhitelist: true,
        //                                             moduleNames: ["Logger", "lifecycle", "persistentData"])
        //
        //        config.modulesList = modulesList
        //
        //        let modules = TealiumModules.initializeModulesFor(config.modulesList,
        //                                                          assigningDelegate: self)
        //
        //        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
        //            XCTAssert(modules.count == modulesList.moduleNames.count, "Modules contains too many elements: \(modules)")
        //        }
    }

    func testDisableOneModuleWithBlacklistAfterExitingConfigAlreadyActived() {
        // Initial setup
        let initialConfig = TealiumConfig(account: "tealiummobile",
                                          profile: "demo",
                                          environment: "dev",
                                          optionalData: nil)

        let modulesList = TealiumModulesList(isWhitelist: false,
                                             moduleNames: Set<String>())

        //        initialConfig.modulesList = modulesList
        //
        //        let modulesManager = TealiumModulesManager(initialConfig)
        //        modulesManager?.setupModulesFrom(config: initialConfig)
        //        modulesManager?.enable(config: initialConfig, enableCompletion: nil)
        //
        //        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
        //            XCTAssert(modulesManager?.modules!.count == (self.numberOfCurrentModules - modulesList.moduleNames.count), "Incorrect number of enabled modules: \(modulesManager?.modules!)")
        //        }
        //
        //        // Updated setup
        //        let newModulesList = TealiumModulesList(isWhitelist: false,
        //                                                moduleNames: ["visitorservice"])
        //
        //        let newConfig = TealiumConfig(account: "test",
        //                                      profile: "test",
        //                                      environment: "test")
        //        newConfig.isEnabled = true
        //
        //        newConfig.modulesList = newModulesList
        //
        //        modulesManager?.update(config: newConfig, oldConfig: initialConfig)
        //
        //        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
        //            XCTAssert(modulesManager?.modules!.count == (self.numberOfCurrentModules - newModulesList.moduleNames.count), "Incorrect number of enabled modules: \(modulesManager?.modules!)")
        //
        //            for module in modulesManager?.modules! where module is TealiumVisitorServiceModule {
        //                XCTFail("Failed to disable the visitor service module.")
        //            }
        //        }
    }

    func testEnableFewerModulesAfterExitingConfigAlreadyActived() {
        // Initial setup
        let initialConfig = TealiumConfig(account: "tealiummobile",
                                          profile: "demo",
                                          environment: "dev",
                                          optionalData: nil)

        //        let modulesList = TealiumModulesList(isWhitelist: true,
        //                                             moduleNames: ["Logger", "lifecycle", "persistentData"])
        //
        //        initialConfig.modulesList = modulesList
        //
        //        let modulesManager = TealiumModulesManager(initialConfig)
        //        modulesManager?.setupModulesFrom(config: initialConfig)
        //
        //        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
        //            XCTAssert(modulesManager?.modules!.count == modulesList.moduleNames.count, "Incorrect number of enabled modules: \(modulesManager?.modules!)")
        //        }
        //
        //        // Updated setup
        //        let newModulesList = TealiumModulesList(isWhitelist: true,
        //                                                moduleNames: ["appdata"])
        //
        //        let newConfig = TealiumConfig(account: "test",
        //                                      profile: "test",
        //                                      environment: "test")
        //        newConfig.isEnabled = true
        //        newConfig.modulesList = newModulesList
        //
        //        modulesManager?.update(config: newConfig, oldConfig: initialConfig)
        //
        //        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
        //            XCTAssert(modulesManager?.modules!.count == newModulesList.moduleNames.count, "Incorrect number of enabled modules: \(modulesManager?.modules!)")
        //        }
    }

    func testEnableMoreModulesAfterExitingConfigAlreadyActived() {
        // Initial setup
        //        let initialConfig = TealiumConfig(account: "tealiummobile",
        //                                          profile: "demo",
        //                                          environment: "dev",
        //                                          optionalData: nil)
        //
        //        let modulesList = TealiumModulesList(isWhitelist: true,
        //                                             moduleNames: ["Logger"])
        //
        //        initialConfig.modulesList = modulesList
        //
        //        let modulesManager = TealiumModulesManager(initialConfig)
        //        modulesManager?.setupModulesFrom(config: initialConfig)
        //        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
        //            XCTAssert(modulesManager?.modules!.count == modulesList.moduleNames.count, "Incorrect number of enabled modules: \(modulesManager?.modules!)")
        //        }
        //        // Updated setup
        //        let newModulesList = TealiumModulesList(isWhitelist: true,
        //                                                moduleNames: ["appdata", "devicedata", "lifecycle"])
        //
        //        let newConfig = TealiumConfig(account: "test",
        //                                      profile: "test",
        //                                      environment: "test")
        //
        //        newConfig.modulesList = newModulesList
        //        newConfig.isEnabled = true
        //        modulesManager?.update(config: newConfig, oldConfig: initialConfig)
        //
        //        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
        //            XCTAssert(modulesManager?.modules!.count == newModulesList.moduleNames.count, "Incorrect number of enabled modules: \(modulesManager?.modules!)")
        //        }
    }

    func testEnableCompletelyDifferentModulesAfterExitingConfigAlreadyActived() {
        // Initial setup
        let initialConfig = TealiumConfig(account: "tealiummobile",
                                          profile: "demo",
                                          environment: "dev",
                                          optionalData: nil)
        //
        //        let modulesList = TealiumModulesList(isWhitelist: true,
        //                                             moduleNames: ["delegate", "persistentData"])
        //
        //        initialConfig.modulesList = modulesList
        //
        //        let modulesManager = TealiumModulesManager(initialConfig)
        //        modulesManager?.setupModulesFrom(config: initialConfig)
        //
        //        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
        //            XCTAssert(modulesManager?.modules!.count == modulesList.moduleNames.count, "Incorrect number of enabled modules: \(modulesManager?.modules!)")
        //        }
        //
        //        // Updated setup
        //        let newModulesList = TealiumModulesList(isWhitelist: true,
        //                                                moduleNames: ["visitorservice", "volatileData"])
        //
        //        let newConfig = TealiumConfig(account: "test",
        //                                      profile: "test",
        //                                      environment: "test")
        //
        //        newConfig.modulesList = newModulesList
        //        newConfig.isEnabled = true
        //        modulesManager?.update(config: newConfig, oldConfig: initialConfig)
        //
        //        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
        //            XCTAssert(modulesManager?.modules!.count == modulesList.moduleNames.count, "Incorrect number of enabled modules: \(modulesManager?.modules!)")
        //
        //            for module in modulesManager?.modules! {
        //                if module is TealiumDelegateModule {
        //                    XCTFail("delegate module was found when shouldn't have been present.")
        //                }
        //                if module is TealiumVisitorServiceModule {
        //                    XCTFail("visitorservice module was found when shouldn't have been present.")
        //                }
        //
        //            }
        //        }
    }

}

extension TealiumModulesTest: TealiumModuleDelegate {
    func requestTrack(_ track: TealiumTrackRequest) {

    }

    func requestReleaseQueue(reason: String) {

    }

    func tealiumModuleFinished(module: TealiumModule, process: TealiumRequest) {

    }

    func tealiumModuleRequests(module: TealiumModule?, process: TealiumRequest) {

    }

    func tealiumModuleFinishedReport(fromModule: TealiumModule, module: TealiumModule, process: TealiumRequest) {

    }
}
