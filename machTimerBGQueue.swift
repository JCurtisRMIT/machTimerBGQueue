// https://stackoverflow.com/questions/50184820/mach-wait-until-strange-behavior-on-ipad

import PlaygroundSupport
import Foundation

PlaygroundPage.current.needsIndefiniteExecution = true

class TimeBase {
    static let NANOS_PER_USEC: UInt64 = 1000
    static let NANOS_PER_MILLISEC: UInt64 = 1000 * NANOS_PER_USEC
    static let NANOS_PER_SEC: UInt64 = 1000 * NANOS_PER_MILLISEC

    static var timebaseInfo: mach_timebase_info! = {
        var tb = mach_timebase_info(numer: 0, denom: 0)
        let status = mach_timebase_info(&tb)
        if status == KERN_SUCCESS {
            return tb
        } else {
            return nil
        }
    }()

    static func toNanos(abs:UInt64) -> UInt64 {
        return (abs * UInt64(timebaseInfo.numer)) / UInt64(timebaseInfo.denom)      
    }

    static func toAbs(nanos:UInt64) -> UInt64 {
        return (nanos * UInt64(timebaseInfo.denom)) / UInt64(timebaseInfo.numer)
    }

}

let duration = TimeBase.toAbs(nanos: 10 * TimeBase.NANOS_PER_SEC)

DispatchQueue.global(qos: .userInitiated).async {

    print("Start")
    let start = mach_absolute_time()
    mach_wait_until(start+duration)
    let stop = mach_absolute_time()

    let elapsed = stop-start
    let elapsedNanos = TimeBase.toNanos(abs: elapsed)
    let elapsedSecs = elapsedNanos/TimeBase.NANOS_PER_SEC
    print("Elapsed nanoseconds = \(elapsedNanos)")
    print("Elapsed seconds = \(elapsedSecs)")

}
