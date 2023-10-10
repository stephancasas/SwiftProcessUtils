# SwiftProcessUtils (`ProcessUtils`)

SwiftProcessUtils offers you modern utilities for working with Darwin's low-level process-oriented functions and extensions on the fundamental `pid_t` type to quickly access path, name, bundle identifier, and other characteristics.

## Install

Install the package using Swift Package Manager:

```
https://github.com/stephancasas/SwiftProcessUtils
```

## Example

```swift
import ProcessUtils;

guard
    proc_name_running("Xcode"),
    let xcodeProcess = SemanticProcess(
        name: "Xcode")
else {
    fatalError("Xcode is not running.");
}

print("Xcode has been running for \(xcodeProcess.uptime) seconds.");
```

## Utility Functions

|                       Name |   Return   | Description                                                                                     |
| -------------------------: | :--------: | :---------------------------------------------------------------------------------------------- |
|     `proc_list_all_pids()` | `[pid_t]`  | Get a list of all PIDs for all ongoing processes.                                               |
|    `proc_list_all_execs()` | `[String]` | Get a list of every executable path for every ongoing process.                                  |
|     `proc_exec_running(:)` |   `Bool`   | Does an ongoing process exist for the executable at the given path?                             |
|    `proc_exec_pid_list(:)` | `[pid_t]`  | Get every process identifier for the executable at the given path, if any such processes exist. |
|       `proc_pid_exists(:)` |   `Bool`   | Does a process with the given process identifier exist?                                         |
|     `proc_name_running(:)` |   `Bool`   | Does a process with the given name exist?                                                       |
| `proc_bundle_id_exists(:)` |   `Bool`   | Does a process with the given bundle id exist?                                                  |

## `pid_t` Extensions

|                      Name |      Return       | Description                                                                                                |
| ------------------------: | :---------------: | :--------------------------------------------------------------------------------------------------------- |
|         `semanticProcess` | `SemanticProcess` | The `SemanticProcess`-equivalent struct for this process.                                                  |
|             `currentName` |     `String?`     | The name of the process which presently has this process identifier.                                       |
|             `currentPath` |     `String?`     | The path to the executable presently running under this process identifier.                                |
|              `currentUrl` |      `URL?`       | The file URL for the executable presently running under this process identifier.                           |
| `currentBundleIdentifier` |     `String?`     | The bundle identifier for which the executable presently running under this process identifier was signed. |
|  `currentCodeSigningInfo` | `[String: Any]?`  | The code-signing info dictionary for the executable presently running under this process identifier.       |
|              `launchTime` |      `Int?`       | In epoch time, when did the process launch?                                                                |
|                  `uptime` |      `Int?`       | In seconds, how long has the process been running?                                                         |
|              `sysctlInfo` |   `kinfo_proc?`   | The sysctl information struct for this process.                                                            |

## `SemanticProcess` Struct

The `SemanticProcess` `struct` provides a persistent store and statefulness for a process — creating a snapshot of the process' characteristics (name, exec path, etc.) at the time of initialization, and then further using this to provide detail about the process' current disposition.

For example, creating an instance using `SemanticProcess(name: "imagent")` could yield an `SemanticProcess` with the id (pid) `4321`. However it's possible that during the lifecycle of your application, the instance of _"imagent"_ being hosted under PID 4321 could be killed or terminated. As the kernel will re-use PIDs after a period of time, it is not sufficient to simply check that PID 4321 exists when considering whether or not your targeted instance of _"imagent"_ is still ongoing. To this end, `SemanticProcess` will verify multiple immutable factors to determine whether or not your _semantically-intended_ process reference is running.

## Contact

[Follow Stephan on X](https://x.com/stephancasas)

## License

MIT
