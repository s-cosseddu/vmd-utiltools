# SMC 2013

package ifneeded utiltools 3.0 "\
[list source [file join $dir files array2ascii.tcl]]; \
[list source [file join $dir files catpdb.tcl]]; \
[list source [file join $dir files catpsf.tcl]]; \
[list source [file join $dir files delete.tcl]]; \
[list source [file join $dir files reduce-trj.tcl]]; \
[list source [file join $dir measure distance.tcl]]; \
[list source [file join $dir measure measure.tcl]]; \
[list source [file join $dir mod center.tcl]]; \
[list source [file join $dir mod delete.tcl]]; \
[list source [file join $dir mod moveCOMto.tcl]]; \
[list source [file join $dir mod moveCloseTo.tcl]]; \
[list source [file join $dir mod superimposer.tcl]]; \
[list source [file join $dir mod swapper.tcl]]; \
[list source [file join $dir rdf rdf.tcl]]; \
[list source [file join $dir rmsd rmsd.tcl]]"
