package provide utiltools 3.0

namespace eval utiltools {
    namespace eval random {
	# declaring namespace
	namespace export randomSphere
    }
}


proc ::utiltools::random::randRangeInt {a b} {
    # return random value in the range \[a b). Useful because lists are zero-based.  
    return [expr {$a + int(0 + rand() * $b)}]
}
