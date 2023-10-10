//
//  SemanticProcess.swift
//
//
//  Created by Stephan Casas on 10/8/23.
//

import Foundation;
import Security;

/// A struct which represents a *semantically-intentional* handle on
/// a currently-running process
///
/// Processes may launch and/or terminate at multiple times during the
/// lifecycle of an application with which they are being monitored. As
/// the kernel will re-use PIDs after a period of time, it is insufficient
/// to only match on PID when determining whether or not a process is still
/// the same thing it was when the PID was first acquired.
///
public struct SemanticProcess: Identifiable {
    
    /// The PID for this process.
    public let id: pid_t;

    /// The BSD short name for the process.
    ///
    /// This is usually the filename of the executable.
    public let name: String;
    
    /// The path to the process' executable.
    public let path: String;
    
    /// The bundle identifier for which the process' executable
    /// was signed.
    public let bundleId: String;
    
    /// In epoch time, when did the process launch?
    public let launchTime: Int;
    
    // MARK: - Initializers
    
    /// Create a new `SemanticProcess` using the process' PID (`pid_t`).
    /// - Parameter pid: The process identifier which should resolve.
    ///
    /// This will return `nil` if no process with the given PID is currently hosted.
    public init?(_ pid: pid_t) {
        if !proc_pid_exists(pid) {
            return nil;
        }
        
        self.id = pid;

        guard 
            let name = pid.currentName,
            let path = pid.currentPath,
            let bundleId = pid.currentBundleIdentifier,
            let launchTime = pid.launchTime
        else {
            return nil;
        }
        
        self.name = name;
        self.path = path;
        self.bundleId = bundleId;
        self.launchTime = launchTime;
    }
    
    /// Create a new `SemanticProcess` using the bundle identifier for an executable.
    /// - Parameter bundleId: The bundle identifier for which a process should resolve.
    ///
    /// This will return `nil` if no process with the given bundle identifier is
    /// currently hosted.
    public init?(bundleId: String) {
        guard let pid = proc_list_all_pids().first(where: {
            $0.currentBundleIdentifier?.elementsEqual(bundleId) ?? false
        }) else {
            return nil
        }
        
        self.init(pid);
    }
    
    /// Create a new `SemanticProcess` using the name (BSD short name) of a process.
    /// - Parameter name: The name to resolve into a kernel-hosted process.
    ///
    /// This will return `nil` if no process with the given name is currently hosted.
    public init?(name: String) {
        guard let pid = proc_list_all_pids().first(where: {
            $0.currentName?.elementsEqual(name) ?? false
        }) else {
            return nil;
        }
        
        self.init(pid);
    }
    
    /// Create a new `SemanticProcess` using the path to an executable.
    /// - Parameter path: The path to the executable for which a process should resolve.
    ///
    /// This will return `nil` if no process is currently hosting the given executable.
    public init?(path: String) {
        guard let pid = proc_list_all_pids().first(where: {
            $0.currentPath?.elementsEqual(path) ?? false
        }) else {
            return nil;
        }
        
        self.init(pid);
    }
    
    /// Create a new `SemanticProcess` using the path to an executable.
    /// - Parameter path: The path to the executable for which a process should resolve.
    ///
    /// This will return `nil` if no process is currently hosting the given executable.
    public init?(path: URL) {
        let pathStr = path.path();

        guard let pid = proc_list_all_pids().first(where: {
            $0.currentPath?.elementsEqual(pathStr) ?? false
        }) else {
            return nil;
        }
        
        self.init(pid);
    }
    
    // MARK: - Helpers
    
    /// The path to the process' executable as a file URL.
    public var url: URL {
        URL(fileURLWithPath: self.path)
    }
    
    /// In seconds, how long has the process been running?
    ///
    /// If the semantic process is no longer running, this will
    /// return `nil`.
    ///
    public var uptime: Int? {
        guard self.isRunning else {
            return nil;
        }
        
        return self.id.uptime
    }
        
    /// Is this process, as it was identified at the time it was captured,
    /// still running?
    public var isRunning: Bool {
        proc_pid_exists(self.id)
        &&
        self.id.currentName == self.name
        &&
        self.id.launchTime  == self.launchTime
    }
    
}
