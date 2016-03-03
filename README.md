UTILTOOLS
=========

> : Author      : Salvatore Cosseddu - S.M.Cosseddu@warwick.ac.uk		  
> : Institution : University of Warwick - Centre for Scientific Computing and	  
>                                         School of Engineering			  
> : Description : Serveral useful VMD small procedures  				  
> : Version     : 3.00

>  COPYRIGHT
>  Copyright © 2010-2016 Salvatore Cosseddu		       				  
>  Centre for Scientific Computing, University of Warwick.		       	  
>  License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>. 
>  This is free software: you are free to change and redistribute it.         	  
>  There is NO WARRANTY, to the extent permitted by law.          		  

## files ##

I/O procedures 

### array2ascii.tcl --

  Write arbitrary shaped tcl arrays to arrays to ascii files

 SYNOPSIS:
   array2ascii <tclarray>  <output\_file> [opts ...]

 OPTIONS
  * tcllist
  * outname
  * (optional) title <title\_line> 
  * (optional) form <tcl\_formatString (defalut %12.8e) 
  * (optional) delimiter <del\_string (default \t)
  * return ::  null

### catpdb --
       
  SYNOPSIS                                                                                            
	catpdb output.pdb 1K4C.pdb solv.pdb \[...\] 							       
  OPTIONS
  *  output file name,
        
  *  pdb files to merge 
  * return ::  null

### catpsf --
 Merge several pdb/psf couple of files together into a single structure using the psfgen 
 Be careful: the segment names have to be unique, the script don't check conflict	  
 in case use rename procedure								  
 file must be declared without extension						  
 SYNOPSIS 										  
 catpsf outfile \[file1\] \[file2\] ...						  
 es. merge protein1 protein2 protein2 dna1 membrane into outfile.p(sf|db)		  

 OPTIONS
  *  output file name,
  *  prefixes of psf/pdb files to merge 
  * return ::  null

### Delete :: Delete atoms given a selection

 SYNOPSIS:
  delete atoms from pdb and psf files, all the arguments are necessary			       
  if pdb file is provided as argument, it will print only a pdb file, 			       
  if psf file is provided as argument, it will process a pdb and a psf file with the same prefix   
  using psfgen to remove atoms and to rebuild psf file. 					       
  es.                                                                                            
  delete 1K4C.pdb "name OH2"  (to remove atoms labelled as OH2 from a pdb)	      
   											       
  delete 1K4C.psf "name OH2"  (to remove atoms labelled as OH2 from the 1K4C.pdb and 1K4C.psf)   			 			
 
 OPTIONS
  *  filename,                                                					       
         name of the files containing the deleting atoms,         					       
         if the extension is psf, both psf and pdb file will be processed				       
         if the extension is pdb, only the pdb file will be processed				       
        
  *  selection
  * return ::  null

### reduce-trj.tcl --

  Easy wrap over catdcd to handle MD trajectories

 SYNOPSIS:
   reduce-trj <selection> <struct\_file> <traj\_files> [...]

 OPTIONS
  * selection     
  * struct\_file   
  * traj\_files    
  * dir	   (optional) default tmp
  * stride    (optional) default 1 
  * nframe    (optional) default -1     
  * traj\_type (optional) default dcd 
  * return ::  null

 -- 

## measure ##

Additional measure functions

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

 FUNCTION:
    distance -- compute distance between two selections
 SYNOPSIS:
    utiltools::measure::distance <molID> sel1 sel2 \[frame (now)\] \[weight (null)\] 
 
 FUNCTION:
    distance\\_traj -- compute distance between two selections over the trajectory
 SYNOPSIS:
    utiltools distance\_traj <molID>  <selection1> <selection1> \[options...\] 
 OPTIONS
    weight <value> (i.g. mass), first <first frame to be considered (default 0)>, last <last frame to be considered (default num frames)> 

 FUNCTION:
  measureBox <molID> [sel (water)]
      measure size of a selection

 FUNCTION:
  gettotcharge <molID> [sel (all)]
      return total charge (charge information must be loaded) 
 
 -- 


## mod ##

Procs to apply some kind of modification

### center.tcl --

   Center the selection (default "all") of the molID molecule
   according to the weight (default simple geometrical center) at
   <frame>th frame (default now)

 -2015

 SYNOPSIS:
   utiltools center <molID> \[<selection>\] \[<frame>\] \[<weight>\]

 OPTIONS
  * molID	 
  * selection
  * frame	 (optional, default now) 
  * weight  (optional, default none) 
  * return ::  null

### delete.tcl --

  Delete atoms given a selection

 SYNOPSIS:
  quickly delete atoms  					       
  es.                                                                                            
  delete top "name OH2" 
  delete 2 "name OH2" 1K4C.pdb (write to file)
 
 OPTIONS
  *  mol ID
  *  selection
  *  filename (optional)

  * return ::  null

### moveCOMto.tcl --

  move a group of atom (moving\_selection) in order to move the COM of a second selection (COM\_selection) to a given position

 SYNOPSIS:
      utiltools::mod::moveCOMto <molID> <moving\_selection> <COM> \[<COM\_selection (default moving\_selection)\]

### moveCloseTo.tcl --

  move a group of atom at a given distance from a second one

 SYNOPSIS:
     utiltools::mod::moveclose <molID> <moving\_selection> <ref\_selection> \[<distance from reference vector> (default {0.5 0.5 0.5})  \[<output pdb>\]

### rotate.tcl --

 Perform a rotation around selected axes on a selection of a pdb file                            
 es.  											       
 rotate top "all"  x -15 z 45 							       
 OPTIONS                                                       				       
 * molID	 
 * selection, select what part of the system will be rotate      					       
 * x <angle> y <angle> z <angle>,   								       
   rotation is performed around axes and angles here selected, the angles are in degrees,         
   only one is needed									       
 * return : null

### superimposer.tcl --

   Superimpose two molecules (or the same molecule with respect of a
   specific frame) and, if requested, return rmsd.

   -2015

 SYNOPSIS:
   utiltools::mod::superimposer selection molID\_1 molID\_2 \[<moving\_mol\_selection>\] \[<rmsd>\] \[<protein>\] 

 OPTIONS
  * selection for superposition 
  * molID\_1 reference molecule. Optionally a frame can be provided, es. \{0 123\} (see details)
  * molID\_2 moving molecule. If equal to molID\_1, a frame must be provided in molID\_1.  	
  * moving\_mol\_selection a different selection for molID\_2  (optional, see details) 
  * rmsd return rmsd? Boolean, optional, default F		     
  * protein protein selection should be used? Boolean, optional, default F, see details
  * return ::  null or rmsd

 DETAILS
 molID\_1 (reference structure) can be provided as a list. In this
 case the second element is used to set the reference
 frame. Es. for \{0 123\} the superposition is performed with
 respect of the 123rd frame of molID 0.  If molID\_1 is not a
 list, a superposition is performed on each frame of the
 trajectory of molID\_1.

 Definition of the atom selection for moving atoms selection that is equal to <selection>
 unless the param moving\_mol\_selection is provided.
 In case of <protein>=T the application of moving\_mol\_selection=selection is a bit more complicated
 to allow superposition of different structures.
 
### swapper.tcl --

  swap position of two group of atoms

 

 SYNOPSIS:
    utiltools::mod::swapper <molID> <selection1> <selection2> \[<output pdb>\]

 -- 



## rdf ##

Additional procs to compute non-standard radial distribution functions

### measure.tcl --

  Useful function to compute radial distribution functions

 Salvatore Cosseddu 2016

 Functions:
  rdf-com <molID> <selection> <ref\_sel> <radius> <delta\_r> \[<first\_frame> (0)\] \[<end> (-1)\] [<rho> (1.)\]
          measure RDF from the center of mass of ref\_sel
	lappend norm\_factor [expr {1./(double($n\_gr) * (4./3.) * $pi * (pow($bin+1,3) - pow($bin,3)) * pow($delta\_r,3)) } ]
 -- 

## rmsd ##
### rmsd.tcl --

   Few function to compute RMSD:
   rmsd-r: Compute RMSD of atoms as a function of distance (with respect of the reference)
           write 2 outfiles (rmsd<sel>-r<...>.dat) time series and averages

 SYNOPSIS:
   ::utiltools::rmsd::rmsd-r molID r dr selection <molIDreference (molID)> <plot (TRUE)>

 OPTIONS
  * molID	 
  * selection
  * molIDreference (optional, default == molID, ref always set to frame 0
                       of molIDreference, selection in molID and molIDreference must have same indices) 
  * plot boolean, plot result?
  * return ::  \[list <r> <averaged rmsds>\]

 -- 


## quantumdots ##
### coordNum.tcl --

 Search atoms of the surface and on the bulk according to the
 first\_neighbour\_distances, the distance of the first neighbours of the same type.
 first\_neighbour\_distances is user-provided.

 Salvatore Cosseddu 2013-2015

 SYNOPSIS:
   ::utiltools::quantumdot::getAtmTypes <molID> <list atomnames> <list first\_neighbour\_distances> <frame (0)>\]

 OPTIONS
  * molID
  * atomnames
  * first\_neighbour\_distances
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
