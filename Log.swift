//
//  Log.swift
//
//  Created by Ryugilwan on 2017. 9. 28..
//  Copyright © 2017년 Ryugilwan. All rights reserved.
//

import UIKit

class Log {
    
    enum LogType: String {
        case info = "[INFO]"
        case debug = "[DEBUG]"
        case warning = "[WARNING]"
        case error = "[ERROR]"
        case emergency = "[EMERGENCY]"
    }
    
    class func info(file: String = #file, function: String = #function, line: Int = #line, message: String) {
        appendLog(type: .info, file: file, function: function, line: line, message: message)
    }
    
    class func debug(file: String = #file, function: String = #function, line: Int = #line, message: String) {
        appendLog(type: .debug, file: file, function: function, line: line, message: message)
    }
    
    class func warning(file: String = #file, function: String = #function, line: Int = #line, message: String) {
        appendLog(type: .warning, file: file, function: function, line: line, message: message)
    }
    
    class func error(file: String = #file, function: String = #function, line: Int = #line, message: String) {
        appendLog(type: .error, file: file, function: function, line: line, message: message)
    }
    
    class func emergency(file: String = #file, function: String = #function, line: Int = #line, message: String) {
        appendLog(type: .emergency, file: file, function: function, line: line, message: message)
    }
    
    /// Append log action
    ///
    /// - Parameters:
    ///   - type: enum LogType
    ///   - file: file name of in log
    ///   - function: method name of in log
    ///   - line: line of in log
    ///   - message: log comment
    private class func appendLog(type: LogType, file: String, function: String, line: Int, message: String) {
        
        let filePath = arrayBySplit(path: file, splitter: "/")
        let txt: String = "\(getKRTime()) - \(type.rawValue), File: \(filePath.last!), Function: \(function)-\(line), Message: \(message)\n"
        getDirectory { (fileManager, directory) in
            // Write log
            let directory = directory + "/log.txt"
            if fileManager.fileExists(atPath: directory) {
                let readingLogFile = FileHandle(forReadingAtPath: directory)
                if readingLogFile == nil {
                    print("Log file open failed")
                } else {
                    writeLog(path: directory, log: txt)
                }
            } else {
                if fileManager.createFile(atPath: directory, contents: nil, attributes: nil) {
                    print("Log file create success")
                    let readingLogFile = FileHandle(forReadingAtPath: directory)
                    if readingLogFile == nil {
                        print("Log file open failed")
                    } else {
                        writeLog(path: directory, log: txt)
                    }
                } else {
                    print("Log file create failed")
                }
            }
        }
    }
    
    /// Get Log file directory
    ///
    /// - Parameter complete: return filemanager, directory path
    private class func getDirectory(complete: ((FileManager, String) -> (Void))? = nil) {
        
        // Set directory path
        let fileManager = FileManager.default
        let dirPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let docsURL = dirPath[0]
        let newDir = docsURL.appendingPathComponent("subDir").path
        
        // Create directory
        do {
            try fileManager.createDirectory(atPath: newDir, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            NSLog("Error : \(error.localizedDescription)")
        }
        complete!(fileManager, newDir)
    }
    
    /// Get time to KR
    ///
    /// - Returns: "yyyy.MM.dd. hh.mm.ss"
    private class func getKRTime() -> String {
        let now = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ko_KR") as Locale!
        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .medium
        let nowdate = dateFormatter.string(from: now as Date)
        return nowdate
    }
    
    /// Write log
    ///
    /// - Parameters:
    ///   - path: Log file path
    ///   - log: Log text
    private class func writeLog(path: String, log: String) {
        let updateLogFile = FileHandle(forUpdatingAtPath: path)
        updateLogFile?.seekToEndOfFile()
        updateLogFile?.write(log.data(using: .utf8)!)
        updateLogFile?.closeFile()
        let splitLog = arrayBySplit(path: log, splitter: "/")
        print(splitLog.last!)
    }
    
    /// Log file text clear
    private class func clear() {
        getDirectory { (fileManager, directory) in
            let directory = directory + "/log.txt"
            if fileManager.fileExists(atPath: directory) {
                let readingLogFile = FileHandle(forReadingAtPath: directory)
                if readingLogFile == nil {
                    print("Log file open failed")
                } else {
                    let logFile = FileHandle(forUpdatingAtPath: directory)
                    logFile?.truncateFile(atOffset: 0)
                    logFile?.closeFile()
                    print("Log file delete success")
                }
            } else {
                print("Log file not exists")
            }
        }
    }
    
    private class func arrayBySplit(path: String, splitter: String? = nil) -> [String] {
        if let s = splitter {
            return path.components(separatedBy: s)
        } else {
            return path.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        }
    }
}







