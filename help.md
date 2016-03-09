


## measure ##
### coordNum.tcl --

  Set of tools to compute neighbor atoms and coordination atoms 

 Salvatore Cosseddu 2013-2015

 FUNCTION:
   NeighAtms -
   Search neighbours of sel1 atoms in sel2 atoms  
   if required compute coordination number (coordNum T)
   or do not repeat pairs nopairs (useful for sums)

 SYNOPSIS:
   ::utiltools::measure::NeighAtms <molID> <sel1> <sel2> <r> <start> <end> \[<coordNum F>\] \[<nopairs F>\]

 OPTIONS
  * molID	 
  * sel1 : main selection from which neighbors/coordNums are computed
  * sel2 : selection of neighbor atoms
  * r : cutoff of neighbors
  * start, end : first and last considered frames. If if equals a simplified output is returned, see RETURN below
  * coordNum (optional, default=F, return cordinations numbers instead of index of neighbor atoms
  * nopairs (optional, default=F, do not count pairs twice)
 

RETURN
  if start != end (working with trajectory)
             if coordNum==F -> \[list  (atomids) \[array(frame) (neigh\_atomids) \]\]
             if coordNum==T -> \[list  (atomids) \[array(frame) (coordnum) \]\]
         if start == end (working with single frame)
             if coordNum==F -> \[list  (atomids) (neigh\_atomids) \]
             if coordNum==T -> \[list  (atomids) (coordnum) \]

 FUNCTION:
   AtmXcoordNum -
   Sort atoms according to the number of neighbor atoms belonging to a given atom selection and within a range r.
   Implementation is independent from ::utiltools::measure::NeighAtms and therefore faster if
   more detailed information are not required.
 
   For flexibility (array are not flexible in tcl),
   output is \[list (coordnums1 coordnums2 ) \[list \{atomids_list1\} \{atomids_list1\} ...\]\]
   which maps into the simple two dimensional array
        coordnums1         coordnums2         ...
   1  atomids_list1,1   atomids_list2,1       ...
   2  atomids_list1,2   atomids_list2,2	 ...
   3  atomids_list1,3   atomids_list2,3       ...
   ...   ...                 ...              ...

 SYNOPSIS:
   ::utiltools::measure::AtmXcoordNum <molID> <sel1> <sel2> <r> <start> <end> 

 OPTIONS
  * molID	 
  * sel1 : main selection from which neighbors/coordNums are computed
  * sel2 : selection of neighbor atoms
  * r : cutoff for searching neighbors
  * start, end : first and last considered frames. If if equals a simplified output is returned, see RETURN below
 

RETURN
  \[list (coordnums1 coordnums2 ) [list {atomids_list1} {atomids_list1} ...] (see description)
 Compute id of neighbor atms of coord atoms at certain frame,
 defined to be called by ::utiltools::measure::NeighAtms and not directly 
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
