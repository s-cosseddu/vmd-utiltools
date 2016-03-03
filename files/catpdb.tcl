## \file catpdb --
#       
#  SYNOPSIS                                                                                            
#  catpdb output.pdb 1K4C.pdb solv.pdb \[...\] 							       
# OPTIONS
# @param  output file name,
#        
# @param  pdb files to merge 
# @return null
#

package provide utiltools 3.0

namespace eval utiltools {
    # declaring namespace
    namespace eval files {
	# declaring namespace
	namespace export catpdb 
    }
}


proc ::utiltools::files::catpdb {outfile args} {

    if { [catch {open ${outfile}.pdb w} out] } {
	puts stderr "Could not open ${outfile}.pdb for writing"
    }

    if {[llength $args] == 0} {
	error "Missing list of pdb files to merge. 
usage:
catpdb <outfile> <pdblist>"
    }

    
    set firstfile true

    foreach pdbfile $args {

	if { [catch {open $pdbfile r} inp] } {
	    puts stderr "Could not open ${pdbfile} for reading"
	} 

	puts "opened $pdbfile"
  
	set pdb [split [read $inp] "\n"]

	foreach line $pdb {
	    # do some line processing here

	    if {$firstfile} {
		puts $out $line
		set firstfile false
	    }

	    if {[regexp "^ATOM.*" $line]} {
		puts $out $line
	    } else {
		continue
	    }

	}
	vmdcon -info "catpdb: pdbfile done"
	close $inp
	
    }
    puts $out "END"
    close $out
}
