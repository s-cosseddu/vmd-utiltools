## \file reduce-trj.tcl --
#
#  Easy wrap over catdcd to handle MD trajectories
#
# Salvatore Cosseddu 2013
#
# SYNOPSIS:
#   reduce-trj <selection> <struct_file> <traj_files> [...]
#
# OPTIONS
# @param selection     
# @param struct_file   
# @param traj_files    
# @param dir	   (optional) default tmp
# @param stride    (optional) default 1 
# @param nframe    (optional) default -1     
# @param traj_type (optional) default dcd 
# @return null
#

package provide utiltools 3.0

namespace eval utiltools {
    namespace eval files {
    # declaring namespace
	namespace export reduce-trj
    }
}

proc ::utiltools::files::reduce-trj {selection struct_file traj_files {dir {}} {stride {1}} {nframe {-1}} {traj_type {dcd}}} {

    if {![llength $selection] || ![llength $struct_file] || [llength $traj_files] == 0 } {
	puts "
 Easy wrap over catdcd to handle MD trajectories
 
 SYNOPSIS:
   reduce-trj <selection> <struct_file> <traj_files> [...]
 
 OPTIONS
 selection     
 struct_file   
 traj_files 
 dir	   (optional) default tmp
 stride    (optional) default 1 
 nframe    (optional) default -1     
 traj_type (optional) default dcd"
	return 
    }
    
    puts "Stripping trajectory file $traj_files"
    set first_traj [lindex $traj_files 0]

    if {[llength $dir] != 0} {
        package require fileutil
	::fileutil::tempdir $dir
    }

    set outdcdname {} 
    foreach i $traj_files {
	set outdcdname [concat $outdcdname [file tail [file rootname ${i}]]]
    }
    set outdcdname [regsub -all { } $outdcdname _ ]
    puts "reduce_dcd output name: outdcdname" 
   
    # creating the output file name and the working directory
    set reduced_dcddir  [file join [::fileutil::tempdir] trajtools]
    puts "tmp dir: $reduced_dcddir"
    set reducedprefix [file join $reduced_dcddir reduced$outdcdname ]
    puts "tmp file $reducedprefix"
    file mkdir $reduced_dcddir

    # Creating a log file 
    set logfile [open "${reducedprefix}.log" w]
    puts $logfile "
stripped:
 $struct_file 
 $traj_files
 sel: $selection struct_file traj_files 
 in $reduced_dcddir 
 stride: $stride
 traj_type: $traj_type
" 

    # loading file
    set mol [ mol new $first_traj type $traj_type first 0 last 0 waitfor all]
    mol addfile $struct_file
    

    set sele [atomselect $mol "$selection"]
    # open file with the index of selection
    set idxfile [file join $reduced_dcddir index.data ]
    puts "Opening $idxfile" 
    if [catch {open $idxfile w} idxunit] {
	puts "error opening index.tmp" 
	return 1
    }


    puts $idxunit "[$sele get index]"
    close $idxunit

    
    puts "writing ${reducedprefix}.pdb"
    $sele writepdb ${reducedprefix}.pdb
    animate delete beg 0 end 0 $mol

    # reducing the trajectory file using catdcd (further development introducing a $env(CATDCDDIR) variable)
    if {[llength $traj_files] > 1} {
	set traj_files [join $traj_files " -$traj_type "]
    }

    if {$nframe >= 0} {
	if [catch {exec catdcd -i $idxfile -o ${reducedprefix}.dcd -last $nframe -stride $stride -$traj_type {*}$traj_files} errors] {
	    puts "errors in producing the reduced dcd file, is catdcd in your PATH?

$errors"
	    #exit 1
	}
    } else {
	if [catch {exec catdcd -i $idxfile -o ${reducedprefix}.dcd  -stride $stride -$traj_type {*}$traj_files} errors] {
	    puts "errors in producing the reduced dcd file, is catdcd in your PATH?

$errors"
	    #exit 1
	}

    }

    puts $logfile "$errors"
    close $logfile

    $sele delete
    mol delete $mol
    
    # returning name of the reduced dcd file 
    return $reducedprefix

}
