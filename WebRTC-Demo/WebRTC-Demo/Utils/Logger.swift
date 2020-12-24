//
//  logger.swift
//  AppRTCMacSwiftUIDemo
//
//  Created by luqi on 2020/12/20.
//

import Foundation

public func dLog(_ object: Any, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
  #if DEBUG
    let className = (fileName as NSString).lastPathComponent
    print("[\(className)] \(functionName) [#\(lineNumber)]| \(object)\n")
  #endif
}
