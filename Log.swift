//
//  Log.swift
//
//  Created by Ryugilwan on 2017. 9. 28..
//  Copyright © 2017년 Ryugilwan. All rights reserved.
//

import Foundation

public class Log {

    // MARK: - Enumerable

    public enum LogType: String {
        case info = "[INFO]"
        case debug = "[DEBUG]"
        case warning = "[WARNING]"
        case error = "[ERROR]"
        case emergency = "[EMERGENCY]"
    }

    // MARK: - Property

    static var fileName: String = "log.txt"


    // MARK: - Public
    
    public class func info(file: String = #file, function: String = #function, line: Int = #line, message: String) {
        appendLog(type: .info, file: file, function: function, line: line, message: message)
    }
    
    public class func debug(file: String = #file, function: String = #function, line: Int = #line, message: String) {
        appendLog(type: .debug, file: file, function: function, line: line, message: message)
    }
    
    public class func warning(file: String = #file, function: String = #function, line: Int = #line, message: String) {
        appendLog(type: .warning, file: file, function: function, line: line, message: message)
    }
    
    public class func error(file: String = #file, function: String = #function, line: Int = #line, message: String) {
        appendLog(type: .error, file: file, function: function, line: line, message: message)
    }
    
    public class func emergency(file: String = #file, function: String = #function, line: Int = #line, message: String) {
        appendLog(type: .emergency, file: file, function: function, line: line, message: message)
    }
    

    // MARK: - Private

    /// Append log action
    ///
    /// - Parameters:
    ///   - type: enum LogType
    ///   - file: file name of in log
    ///   - function: method name of in log
    ///   - line: line of in log
    ///   - message: log comment
    private class func appendLog(type: LogType, file: String, function: String, line: Int, message: String) {
        
        guard let loggingFileName = URL(string: file)?.lastPathComponent else {
            print("Failed to found the file name.")
            return
        }
        let txt = "\(getKRTime()) - \(type.rawValue), File: \(loggingFileName), Function: \(function)-\(line), Message: \(message)\n"

        getDirectory { (fileManager, directory) in
            writeLog(at: "\(directory)/\(fileName)", log: txt)
        }
    }
    
    /// Get Log file directory
    ///
    /// - Parameter complete: return filemanager, directory path
    private class func getDirectory(complete: ((FileManager, String) -> (Void))) {
        
        // Set directory path
        let fileManager = FileManager.default
        let dirPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let docsURL = dirPath[0]
        let newDir = docsURL.appendingPathComponent("subDir").path
        
        // Create directory
        do {
            try fileManager.createDirectory(atPath: newDir, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Error : \(error.localizedDescription)")
        }
        complete(fileManager, newDir)
    }
    
    /// Get time to KR
    ///
    /// - Returns: "yyyy.MM.dd. hh.mm.ss"
    private class func getKRTime() -> String {
        let now = Date()

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .medium

        return dateFormatter.string(from: now)
    }
    
    /// Write log
    ///
    /// - Parameters:
    ///   - at: Log file path
    ///   - log: Log text
    private class func writeLog(at path: String, log: String) {
        guard let data = log.data(using: .utf8) else {
            print("Failed to convert string.")
            return
        }

        guard let handle = openFile(at: path) else {
            print("Log file open failed")
            return
        }
        handle.seekToEndOfFile()
        handle.write(data)
        handle.closeFile()

        let splitLog = log.components(separatedBy: "/")
        print(splitLog.last ?? "")
    }

    /// Open the file, and get a FileHandle instance.
    ///
    /// - Parameters:
    ///   - at: Log file path
    private class func openFile(at path: String) -> FileHandle? {
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: path) {
            return FileHandle(forUpdatingAtPath: path)
        } else {
            guard fileManager.createFile(atPath: path, contents: nil, attributes: nil) else {
                print("Log file create failed")
                return nil
            }
            print("Log file create success")

            return FileHandle(forUpdatingAtPath: path)
        }
    }
    
    /// Log file text clear
    private class func clear() {
        getDirectory { (fileManager, directory) in
            guard let url = URL(string: "\(directory)/\(fileName)") else { return }

            do {
                try fileManager.removeItem(at: url)
            } catch let error as NSError {
                print("Error : \(error.localizedDescription)")
            }
        }
    }
}
