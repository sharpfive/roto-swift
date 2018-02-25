import Foundation
import CSV
import RotoSwift

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

print("Team Relative Values")

processTeamsWithRelativeValues()
