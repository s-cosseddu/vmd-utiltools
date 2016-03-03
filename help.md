


## quantumdots ##
### coordNum.tcl --

 Search atoms of the surface and on the bulk according to the
 first_neighbour_distances, the distance of the first neighbours of the same type.
 first_neighbour_distances is user-provided.

 Salvatore Cosseddu 2013-2015

 SYNOPSIS:
   ::utiltools::quantumdot::getAtmTypes <molID> <list atomnames> <list first_neighbour_distances> <frame (0)>\]

 OPTIONS
  * molID
  * atomnames
  * first_neighbour_distances
  * frame (optional, default=0)
  * return ::  list \[array get CoordNumLists \]
	       \[array get CoordNums \]
	       \[array get surfaceIDs \]
	       \[array get bulkIDs \]
 USAGE
 set AtmTypList \[::utiltools::quantumdot::getAtmTypes top \{Cd Se\} \{4.35 4.35\}\]
 array set CoordNumLists \[lindex $AtmTypList 0\]
 array set CoordNums     \[lindex $AtmTypList 1\]
 array set surfaceIDs	  \[lindex $AtmTypList 2\]
 array set bulkIDs       \[lindex $AtmTypList 3\]
 -- 



## measure ##
### coordNum.tcl --

 Search neighbours of sel1 atoms in sel2 atoms 
 if required compute coordination number (coordNum T)
 or do not repeat pairs nopairs (useful for sums)

 Salvatore Cosseddu 2013-2015

 SYNOPSIS:
   ::utiltools::measure::NeighAtms <molID> <sel1> <sel2> <r> <start> <end> \[<coordNum F>\] \[<nopairs F>\]

 OPTIONS
  * molID	 
  * selection
  * sel1
  * sel2
  * r
  * start
  * end
  * coordNum (optional, default=F, return cordinations numbers instead of index of neighbor atoms
  * nopairs (optional, default=F, do not count pairs twice)
  * return ::  \[array(frame) (atomids) (neigh\_atomids) \]
          or if coordNum==T \[array(frame) (atomids) (coordnum) \] 

### distance.tcl --

  procs to measure distances 

 Salvatore Cosseddu 2013

 FUNCTION:
    distance -- compute distance between two selections
 SYNOPSIS:
    utiltools::measure::distance <molID> sel1 sel2 \[frame (now)\] \[weight (null)\] 
 
 FUNCTION:
    distance_traj -- compute distance between two selections over the trajectory
 SYNOPSIS:
    utiltools distance_traj <molID>  <selection1> <selection1> \[options...\] 
 OPTIONS
    weight <value> (i.g. mass), first <first frame to be considered (default 0)>, last <last frame to be considered (default num frames)> 


### measure.tcl --

  Additional useful measure functions

 Salvatore Cosseddu 2013

 Functions:
  measureBox <molID> [sel (water)]
      measure size of a selection

  gettotcharge <molID> [sel (all)]
      return total charge (charge information must be loaded) 
 
 -- 
