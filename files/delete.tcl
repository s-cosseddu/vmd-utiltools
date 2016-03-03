## \file files.tcl --
#
#  Set of functions to perform actions on files
#                        Salvatore Cosseddu 2013
#
#
#    - Delete :: Delete atoms given a selection
#
# SYNOPSIS:
#  delete atoms from pdb and psf files, all the arguments are necessary			       
#  if pdb file is provided as argument, it will print only a pdb file, 			       
#  if psf file is provided as argument, it will process a pdb and a psf file with the same prefix   
#  using psfgen to remove atoms and to rebuild psf file. 					       
#  es.                                                                                            
#  delete 1K4C.pdb "name OH2"  (to remove atoms labelled as OH2 from a pdb)	      
#   											       
#  delete 1K4C.psf "name OH2"  (to remove atoms labelled as OH2 from the 1K4C.pdb and 1K4C.psf)   			 			
# #
# OPTIONS
# @param  filename,                                                					       
#         name of the files containing the deleting atoms,         					       
#         if the extension is psf, both psf and pdb file will be processed				       
#         if the extension is pdb, only the pdb file will be processed				       
#        
# @param  selection
# @return null
#


package provide utiltools 3.0

namespace eval utiltools {
    # declaring namespace
    namespace eval files {
	# declaring namespace
	namespace export delete
    }
}

proc ::utiltools::files::usage_delete {} {
	puts "                                                                              
 ========================================================================================================\n\n\
 PROCEDURE                                                                                             \  
 \n\t delete,											       \
 \n\t delete atoms from pdb and psf files, all the arguments are necessary			       \
 \n\t if pdb file is provided as argument, it will print only a pdb file, 			       \
 \n\t if psf file is provided as argument, it will process a pdb and a psf file with the same prefix   \
 \n\t using psfgen to remove atoms and to rebuild psf file. 					       \
 \n\n\t es.                                                                                            \
 \n\t delete 1K4C.pdb \"name OH2\"  (to remove atoms labelled as OH2 from a pdb)	      
 \t or  											       \
 \n\t delete 1K4C.psf \"name OH2\"  (to remove atoms labelled as OH2 from the 1K4C.pdb and 1K4C.psf)   \			 			
 \n\n OPTIONS                                                       				       \
 \n\t filename,                                                					       \
 \n\t name of the files containing the deleting atoms,         					       \
 \n\t if the extension is psf, both psf and pdb file will be processed				       \
 \n\t if the extension is pdb, only the pdb file will be processed				       \
 \n\t selection,                  								       \
 \n\t select that will be delete  								       \
 \n\n												       
  =====================================================================================================
 "
	    }


proc ::utiltools::files::delete {{filename {}} {selection {}}} {
    
    # {topofile {}} removed
    
    # checking which file will be processed
    # if the input is a psf-> psf and pdb will be centered
    # if the input is a pdb-> only the pdb will be centered

    # checking input
    if {![ llength $filename ] || ![regexp {\.p(db|sf)$} $filename]} { 
	puts "\
======================================== 
            error in the file name
======================================== "
	::utiltools::usage_delete
	return
    }

    # checking if the input is a pdb or a psf file (the behavior will be different)
    set onlypdb [regexp -nocase .pdb $filename]
  
    # set name of the file without extention
    set filename [regsub -nocase {\.p[sd][fb]$} $filename {}]

    # changing commas in spaces 
    #regsub -all , $selection { } selection

    if $onlypdb {
	puts "--------------------------------------------------------------------------------

                            working only with a pdb file 

--------------------------------------------------------------------------------"
	# load molecule
	mol load pdb ${filename}.pdb
	# getting rid of unwanted part
	set writing [atomselect top "not ($selection)"]
	# writing new file
	$writing writepdb ${filename}_delete.pdb

    } else {
	puts "--------------------------------------------------------------------------------

                            working with pdb and psf files 

--------------------------------------------------------------------------------"


	# loading psfgen
	package require psfgen
	resetpsf

	# load molecule
	    readpsf ${filename}.psf
	    coordpdb ${filename}.pdb
	    mol new ${filename}.pdb waitfor all
	    mol addfile ${filename}.psf  waitfor all
	    
	    # selecting part to be deleted
	    set deleting [atomselect top $selection]
	    
	    # deleting previous selection
	    foreach segid [$deleting get segid] resid [$deleting get resid] atmname [$deleting get name] {
		# the selection is so explicit to allow single atom delete
		delatom $segid $resid $atmname
	    }
    
	    writepsf ${filename}_delete.psf
	    writepdb ${filename}_delete.pdb
	}

    puts "--------------------------------------------------------------------------------

                        $selection
                                deleted from 
                                $filename
  
--------------------------------------------------------------------------------"

}

