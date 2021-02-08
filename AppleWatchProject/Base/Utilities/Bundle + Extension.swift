//
//  Bundle + Extension.swift
//  AppleWatchProject
//
//  Created by Juan Enrique Seillant Perez on 15/07/2020.
//

import Foundation
public extension Bundle {
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
    var versionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var buildNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }

    var versionAndBuildNumbersWithUnderscores : String? {
        if let versionAndBuild = self.versionAndBuildNumbersWithoutUnderscores {
            let formattedVersionAndBuild = versionAndBuild.replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: ".", with: "_")

            return formattedVersionAndBuild
        }

        return nil
    }

    @objc var versionAndBuildNumbersWithoutUnderscores : String? {
        if let version = self.versionNumber, let build = self.buildNumber {
            return version + "." + build
        }
        return nil
    }

    var versionAndBuildNumbers : String? {
        if let version = self.versionNumber, let build = self.buildNumber {
            return version + "(\(build))"
        }
        return nil
    }
}
