import Foundation
import CSV
import RotoSwift

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif


calculateProjections()