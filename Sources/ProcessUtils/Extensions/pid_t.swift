//
//  pid_t.swift
//
//
//  Created by Stephan Casas on 10/8/23.
//

import Foundation;
import Security;

public extension pid_t {
    
    /// The `SemanticProcess`-equivalent struct for this process identifier.
    var semanticProcess: SemanticProcess? {
        .init(self)
    }
    
    /// The name of the process which presently has this process identifier.
    var currentName: String? {
        var name = [CChar](repeating: 0, count: kProcPidPathInfoMaxSize);
        proc_name(self, &name, PROC_PIDPATHINFO_MAXSIZE);
        
        let nameStr = String(cString: name);
        if nameStr.isEmpty {
            return nil;
        }
        
        return nameStr;
    }
    
    /// The path to the executable presently running under this process identifier.
    var currentPath: String? {
        var path = [CChar](repeating: 0, count: kProcPidPathInfoMaxSize);
        proc_pidpath(self, &path, PROC_PIDPATHINFO_MAXSIZE);
        
        let pathStr = String(cString: path);
        if pathStr.isEmpty {
            return nil;
        }
        
        return pathStr;
    }
    
    /// The file URL for the executable presently running under this process identifier.
    var currentUrl: URL? {
        guard let path = self.currentPath else {
            return nil;
        }
        
        return URL(fileURLWithPath: path)
    }
    
    // MARK: - Sysctl Info
    
    /// The management information base passed to sysctl for information about 
    /// this process.
    private var sysctlMib: [Int32] {[
        CTL_KERN, KERN_PROC, KERN_PROC_PID, self
    ]}
    
    /// The sysctl information struct (`kinfo_proc`) for this process.
    var sysctlInfo: kinfo_proc? {
        var mib = self.sysctlMib;
        var procInfo = kinfo_proc();
        var procInfoSize = MemoryLayout<kinfo_proc>.size;
        
        guard sysctl(
            &mib, .init(mib.count),
            &procInfo, &procInfoSize,
            nil, 0
        ) == 0 else {
            return nil;
        }
        
        return procInfo;
    }
    
    /// In epoch time, when did the process launch?
    var launchTime: Int? {
        self.sysctlInfo?.kp_proc.p_starttime.tv_sec;
    }
    
    /// In seconds, how long has the process been running?
    var uptime: Int? {
        guard let launchTime = self.launchTime else {
            return nil;
        }
        
        var now = timeval();
        gettimeofday(&now, nil);
        
        return now.tv_sec - launchTime;
    }
    
    // MARK: - Code-signing Info
    
    private var currentSecurityStaticCode: SecStaticCode? {
        var securityCode: SecStaticCode?;
        guard
            let url = self.currentUrl,
            SecStaticCodeCreateWithPath(
                url as CFURL,
                .init(rawValue: 0), &securityCode
            ) == .success else {
            return nil;
        }
        
        return securityCode;
    }
    
    /// The code-sigining info dictionary for the executable presently running
    /// under this process identifier.
    var currentCodeSigningInfo: [String: Any]? {
        var signingInfo: CFDictionary?;
        guard
            let securityStaticCode = self.currentSecurityStaticCode,
            SecCodeCopySigningInformation(
                securityStaticCode,
                .init(rawValue: 2),
                &signingInfo
            ) == .success,
            let signingInfo = signingInfo as? [String: Any]
        else {
            return nil
        }
        
        return signingInfo;
    }
    
    /// The bundle identifier for which the executable presently running under
    /// this process identifier was signed.
    var currentBundleIdentifier: String? {
        self.currentCodeSigningInfo?["identifier"] as? String
    }
    
}
