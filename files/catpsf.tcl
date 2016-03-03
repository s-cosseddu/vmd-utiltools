## \file catpsf --
#        PROCEDURE                                                                        
# catpsf,										  
# Merge several pdb/psf couple of files together into a single structure using the psfgen 
# Be careful: the segment names have to be unique, the script don't check conflict	  
# in case use rename procedure								  
# file must be declared without extension						  
# SYNOPSIS 										  
# catpsf outfile \[file1\] \[file2\] ...						  
# es. merge protein1 protein2 protein2 dna1 membrane into outfile.p(sf|db)		  
#
# OPTIONS
# @param  output file name,
# @param  prefixes of psf/pdb files to merge 
# @return null
#

package provide utiltools 3.0

namespace eval utiltools {
    # declaring namespace
    namespace eval files {
	# declaring namespace
	namespace export catpsf 
    }
}



proc ::utiltools::files::usage_catpsf {} { 
		
    puts "                                                                              
 ========================================================================================================\n\n\
 PROCEDURE                                                                                             \
 \n\t catpsf,											       \
 \n\t Merge several pdb/psf couple of files together into a single structure using the psfgen  	       \
 \n\t Be careful: the segment names have to be unique, the script don't check conflict		       \
 \n\t in case use rename procedure								       \
 \n\t file must be declared without extension							       \
 \n\n SYNOPSIS 											       \
 \n\t catpsf \[file1\] \[file2\] ...								       \
 \n\t es. merge protein1 protein2 protein2 dna1 membrane					       \
 \n\n												       
  =====================================================================================================
 "
}


proc ::utiltools::files::catpsf {outfile args} {
    package require psfgen

    if { [catch {open ${outfile}.psf w} out] ||
     [catch {open ${outfile}.pdb w} out] } {
	puts stderr "Could not open ${outname} files for writing"
    }

    if {[llength $args] == 0} {
	error "Missing list of files to merge."
	::utiltools::files::usage_catpsf
    }

    resetpsf

    puts "--------------------------------------------------------------------------------

                                      Concatened files:
      "
    foreach input $args {
	readpsf  ${input}.psf
	coordpdb ${input}.pdb
	puts "                             $input"
    }

    # removing first underscore from output file name
    puts "
                              in the outfile 
                    $outfile
--------------------------------------------------------------------------------"
    
    writepsf ${outfile}.psf
    writepdb ${outfile}.pdb
}
