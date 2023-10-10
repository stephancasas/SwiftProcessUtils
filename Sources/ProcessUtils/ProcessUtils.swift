//
// SwiftProcessUtilities.swift
//
// Created by Stephan Casas on 10/8/23.
//

import Foundation;

public let PROC_PIDPATHINFO_MAXSIZE: UInt32 = 4096; // Apple didn't bridge this??
public let  kProcPidPathInfoMaxSize:    Int = .init(PROC_PIDPATHINFO_MAXSIZE);

/// Get a list of PIDs for all ongoing processes.
///
public func proc_list_all_pids() -> [pid_t] {
    let pidCount = Int(proc_listpids(UInt32(PROC_ALL_PIDS), 0, nil, 0));
    var pidList = [pid_t](repeating: 0, count: pidCount);
    
    proc_listpids(UInt32(PROC_ALL_PIDS), 0, &pidList, Int32(pidCount));
    
    return pidList.filter({ $0 != 0 });
}

/// Get a list of every executable path for every ongoing process.
///
public func proc_list_all_execs() -> [String] {
    var execList = [String]();
    
    var pathBuffer = [CChar](
        repeating: 0,
        count: kProcPidPathInfoMaxSize);
    for pid in proc_list_all_pids() {
        proc_pidpath(pid, &pathBuffer, PROC_PIDPATHINFO_MAXSIZE);
        
        execList.append(.init(cString: pathBuffer));
        
        pathBuffer.withUnsafeMutableBufferPointer({
            $0.initialize(repeating: 0);
        });
    }
    
    return execList;
}

/// Does an ongoing process exist for the executable at the given path?
///
public func proc_exec_running(_ path: String) -> Bool {
    proc_list_all_execs().contains(where: {
        $0.elementsEqual(path)
    })
}

/// Get every process identifier for the executable at the given path,
/// if any such processes for that executable exist.
///
public func proc_exec_pid_list(_ path: String) -> [pid_t] {
    proc_list_all_pids().filter({
        $0.currentPath?.elementsEqual(path) ?? false
    })
}

/// Does a process with the given process identifier exist?
///
public func proc_pid_exists(_ pid: pid_t) -> Bool {
    proc_list_all_pids().contains(pid);
}

/// Does a process with the given name exist?
///
public func proc_name_running(_ name: String) -> Bool {
    proc_list_all_pids().contains(where: {
        $0.currentName?.elementsEqual(name) ?? false
    })
}

/// Does a process with the given bundle id exist?
///
public func proc_bundle_id_exists(_ bundleId: String) -> Bool {
    proc_list_all_pids().contains(where: {
        $0.currentBundleIdentifier?.elementsEqual(bundleId) ?? false
    })
}
