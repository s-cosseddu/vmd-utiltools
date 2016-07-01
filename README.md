UTILTOOLS
=========
Version     : 3.0	
Author      : Salvatore M. Cosseddu 2011-2016

COPYRIGHT
---------
Copyright © 2011-2016 Salvatore Cosseddu		       				  
Centre for Scientific Computing, University of Warwick.		       	  
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>. 
This is free software: you are free to change and redistribute it.         	  
There is NO WARRANTY, to the extent permitted by law.          		  

Description
-----------

The package is a collection of useful VMD/Tcl functions. It is
organised in several sections (namespaces), according to the scope.

Synopsis
-----
The directory of the package must be initially appended to _auto\_path_:

	lappend auto_path <utiltools\_dir>
	
Utiltools is invoked as

	package require utiltools ?3.0?

List of functions
-----------------


### ::utiltools::files

::utiltools::files:: is a collection of I/O procedures.


-------------------


#### ::utiltools::files::array2ascii

**DESCRIPTION**
Write arbitrary shaped tcl arrays to arrays to ascii files.

**SYNOPSIS**

	array2ascii <tclarray>  <output\_file> '[opts ...]'

**OPTIONS**

    * tcllist
    * outname
	* (optional) title <title\_line> 
	* (optional) form <tcl\_formatString (defalut %12.8e) 
	* (optional) delimiter <del\_string (default \t)

#### ::utiltools::files::catpdb

**DESCRIPTION**

Quickly concatenate several pdb files.

**SYNOPSIS**

	catpdb output.pdb 1K4C.pdb solv.pdb [...]

**OPTIONS**

	*  output file name,
	*  pdb files to merge 

#### ::utiltools::files::catpsf

**DESCRIPTION**

Merge several pdb/psf couple of files together into a single structure
using the psfgen.
Be careful: the segment names must be unique, the script does not check for conflicts. Files names are without extensions.

**SYNOPSIS** 										  

	catpsf outfile <file1> <file2> ...						  

es.

	catpsf outfile protein1 protein2 protein3 dna1 membrane

The pair outfile.p(sf|db) is created.
	
**OPTIONS**
	
	* Output file name,
	* Prefixes of psf/pdb files to merge 

#### ::utiltools::files::delete

**DESCRIPTION**

Delete atoms in the provided selection from pdb and psf files. If a
pdb file is provided as argument, it will only return a pdb file. If a
psf file is provided, both pdb and psf files with the same prefix are
processed (using psfgen) and a pdb/psf pair is returned.

**SYNOPSIS**

::utiltools::files::delete <file(s) prefix> <selection>

e.g.

	delete 1K4C.pdb "name OH2" ;# remove atoms labelled as OH2 from a pdb)
	delete 1K4C.psf "name OH2" ;# remove atoms labelled as OH2 from both 1K4C.pdb and 1K4C.psf
 
**OPTIONS**

	* filename: name of the files containing the deleting atoms, if
      the extension is psf, both psf and pdb file will be processed if
      the extension is pdb, only the pdb file will be processed
	* selection 

#### ::utiltools::files::reduce-trj.tcl --

**DESCRIPTION**

Reduce the size of MD trajectories using catdcd (catdcd is assumed to
be in the user $PATH)

**SYNOPSIS**

	reduce-trj <selection> <struct_file> <traj_files> [<dir>] [<stride>] [<last>] [<traj_type>]

**OPTIONS**

	* selection : atom selection to be written 
	* struct\_file : file name of the structure associated to the trajectory file
	* traj\_files : trajectory file name
	* dir : working directory (optional, default tmp)
	* stride : frames to skip when writing (optional, default 1, i.e. all frame written)
	* last : last frame (optional, default -1, i.e. all frame are written)
	* traj\_type : type of the trajectory file (optional, default dcd) 

####::utiltools::files::writesel

**DESCRIPTION**

Write the selection in an output file. Recognise the
output type according to the file extension. 

**SYNOPSIS**

	::utiltools::files::writesel <output_filename> <selection>

**OPTIONS**

	* output file name,
	* selection of atom (i.g. name OH2)

---------------------

### ::utiltools::measure

::utiltools::measure provides additional measure functions with respect of those built in VMD.


#### ::utiltools::measure::NeighAtms

**DESCRIPTION**

Search neighbours of sel1 atoms among atoms in sel2. If required compute
coordination number (coordNum T) or do not repeat pairs nopairs
(useful for sums for further analysis).

**SYNOPSIS**

	::utiltools::measure::NeighAtms <molID> <sel1> <sel2> <r> <start> <end> [<coordNum F>] [<nopairs F>]

**OPTIONS**

	* molID	 
	* sel1 : main selection from which neighbors/coordNums are computed
	* sel2 : selection of neighbor atoms
	* r : cutoff of neighbors
	* start, end : first and last considered frames. If if equals a simplified output is returned, see RETURN below
	* coordNum (optional, default=F, return cordinations numbers instead of index of neighbor atoms
	* nopairs (optional, default=F, do not count pairs twice)

**RETURN**

	if start != end (working with trajectory)
             if coordNum==F -> [list  (atomids) [array(frame) (neigh_atomids) ]]
             if coordNum==T -> [list  (atomids) [array(frame) (coordnum) ]]
         if start == end (working with single frame)
             if coordNum==F -> [list  (atomids) (neigh_atomids) ]
             if coordNum==T -> [list  (atomids) (coordnum) ]


#### ::utiltools::measure::AtmXcoordNum

**DESCRIPTION**

Sort atoms according to the number of neighbor atoms belonging to a
given atom selection and within a range r.  Implementation is
independent from ::utiltools::measure::NeighAtms and therefore faster
if more detailed information are not required.

For flexibility (array are not flexible in tcl), output is
'[list (coordnums1 coordnums2 ) [list \{atomids\_list1\} \{atomids\_list1\} ...]]'
which maps into the simple two dimensional array

	     coordnums1         coordnums2         ...
	1  atomids\_list1,1   atomids\_list2,1     ...
	2  atomids\_list1,2   atomids\_list2,2     ...
	3  atomids\_list1,3   atomids\_list2,3     ...
	...     ...                 ...            ...

Array is used for trajectories (start != end):
array($frame) <- '[[list (coordnums1 coordnums2 )] [list {atomids_list1} {atomids_list1} ...]]'
 
**SYNOPSIS**

	::utiltools::measure::AtmXcoordNum <molID> <sel1> <sel2> <r> <start> <end> 

**OPTIONS**

	* molID	 
	* sel1 : main selection from which neighbors/coordNums are computed
	* sel2 : selection of neighbor atoms
	* r : cutoff for searching neighbors
	* start, end : first and last considered frames. If if equals a simplified output is returned, see RETURN below
 
**RETURN**

start == end:
	[list (coordnums1 coordnums2 ) [list {atomids\_list1} {atomids\_list1} ...]

Trajectories (start != end):
	set array($frame) [[list (coordnums1 coordnums2 )] [list {atomids_list1} {atomids_list1} ...]]

See description for more details.


#### ::utiltools::measure::distance

**DESCRIPTION**

Compute distance between the center (geomtric or of mass) of two selections of atoms.

**SYNOPSIS**

	utiltools::measure::distance <molID> sel1 sel2 [frame (now)] [weight (null)] 
 
#### ::utiltools::measure::distance_traj

**DESCRIPTION**

Compute distances between the center (geomtric or of mass) of two selections of atoms over a trajectory.

**SYNOPSIS**

	utiltools distance_traj <molID>  <selection1> <selection1> [options...] 

**OPTIONS**

	* weight <value> (i.g. mass)
	* first <first frame to be considered (default 0)>
	* last <last frame to be considered (default total num of frames)> 



#### ::utiltools::measure::measureBox

**DESCRIPTION**

Measure size of a selection. The function was intended only to have a quick estimate (i.g. when setting a MD box).

	::utiltools::measure::measureBox <molID> [sel (water)]



#### ::utiltools::measure::gettotcharge

**DESCRIPTION**

Return total charge (charge information must be loaded into the molecule). 

	::utiltools::measure::gettotcharge <molID> [sel (all)]


---------------


### ::utiltools::mod

::utiltools::mod is a collection of procedures that apply some kind of modification to atom coordinates.

#### ::utiltools::mod::center

**DESCRIPTION**

Center the selection (default "all") of the molecule <molID> according
to <weight> (default NULL, i.e. simple geometrical center) at
the <frame>th frame (default now).

**SYNOPSIS**

	::utiltools::mod::utiltools center <molID> [<selection>] [<frame>] [<weight>]

**OPTIONS**

	* molID	 
	* selection
	* frame	 (optional, default now) 
	* weight  (optional, default none) 

#### ::utiltools::mod::delete

**DESCRIPTION**

Delete atoms given a selection (similar to ::utiltools::files::delete,
but works on the loaded molecules instead that working on files). If
<outfile> is present, coordinates are saved in the file. Type of file
is determined from its extension.

**SYNOPSIS**

	::utiltools::mod::delete <molID> <selection> [<outfile>]

 ex. delete top "name OH2" ;# delete atoms named OH2 from top
 molecule delete 2 "name OH2" 1K4C.pdb (write to file)
 
**OPTIONS**

	*  molID
	*  selection
	*  output filename (optional)


#### ::utiltools::mod::moveCOMto

**DESCRIPTION**

move a group of atom (moving\_selection) in order to move the COM of a
second selection (COM\_selection) to a given position

**SYNOPSIS**

	utiltools::mod::moveCOMto <molID> <moving\_selection> <COM> [<COM_selection (default moving_selection)]

#### ::utiltools::mod::moveCloseTo

**DESCRIPTION**

Move a group of atoms at a given distance from a second one. Distances
are computed with respect of the centers of mass.

**SYNOPSIS**

	utiltools::mod::moveclose <molID> <moving\_selection> <ref\_selection> [<distance from reference vector> (default {0.5 0.5 0.5})  [<output pdb>]

### rotate.tcl --

**DESCRIPTION**

Perform a rotation around selected axes on a selection of a pdb file

**SYNOPSIS**

	utiltools::mod::rotate <molID> <selection> [<x|y|z> <angle> ...]

ex.

	utiltools::mod::rotate top "all" x -15 z 45

**OPTIONS**

	* molID	 
	* selection, select what part of the system will be rotated
	* x <angle> y <angle> z <angle>, rotation is performed around axes and angles here selected, the angles are in degrees, only one is needed, more can be provided
	

#### ::utiltools::mod::superimposer

**DESCRIPTION**

Superimpose two molecules (or the same molecule with respect of a
specific frame) and, if requested, return rmsd.

**SYNOPSIS**

	utiltools::mod::superimposer selection molID\_1 molID\_2 [<moving\_mol\_selection>] [<rmsd>] [<protein>]

**OPTIONS**

	* selection for superposition 
	* molID\_1: reference molecule. Optionally a frame can be provided, es. \{0 123\} (see details)
	* molID\_2: moving molecule. If equal to molID\_1, a frame must be provided in molID\_1.  	
	* moving\_mol\_selection: a different selection for molID\_2  (optional, see details) 
	* rmsd : should rmsd be returned? Boolean, optional, default F		     
	* protein protein: selection should be used? Boolean, optional, default F, see details

DETAILS

molID\_1 (reference structure) can be provided as a list. In this case
the second element is used to set the reference frame. Es. for \{0
123\} the superposition is performed with respect of the 123rd frame
of molID 0.  If molID\_1 is not a list, a superposition is performed
on each frame of the trajectory of molID\_1.

 Definition of the atom selection for moving atoms selection that is
 equal to <selection> unless the param moving\_mol\_selection is
 provided.  In case of <protein>=T the application of
 moving\_mol\_selection=selection is a bit more complicated to allow
 superposition of different structures.
 
#### ::utiltools::mod::swapper

**DESCRIPTION**

Swap positions of two group of atoms. Positions are computed as centers of mass.
 

**SYNOPSIS**

	utiltools::mod::swapper <molID> <selection1> <selection2> [<output pdb>]


-----------------


### ::utiltools::rdf

::utiltools::rdf provides additional procs to compute non-standard
radial distribution functions.

#### ::utiltools::rdf::rdf-com

**DESCRIPTION**

Compute radial distribution function from the center of mass of a given selection. BE CAREFUL this is different from the more standard radial pair distribution function (_g_(r)). 

**SYNOPSIS**

	rdf-com <molID> <selection> <ref\_sel> <radius> <delta\_r> [<first\_frame> (0)] [<end> (-1)] [<rho> (1.)]

-- 

### ::utiltools::rmsd

::utiltools::rmsd provides some useful procs to compute rmsd.

#### ::utiltools::rmsd::rmsd-r

**DESCRIPTION**

Rmsd-r computes RMSD of atoms as a function of distance from the center of mass of reference (provided by selection). It writes 2 outfiles (rmsd<sel>-r<...>.dat) time series and averages.

**SYNOPSIS**

	::utiltools::rmsd::rmsd-r <molID> <r> <dr> <selection> [<molIDreference (molID)>] [<plot (TRUE)>]

**OPTIONS**

	* molID
	* r : max radius of the RDF
	* dr : size of the histagram bins 
	* selection : selection of the reference 
	* molIDreference (optional, default == molID, ref always set to frame 0
                       of molIDreference, selection in molID and molIDreference must have same indices) 
	* plot boolean, plot result?

**RETURN**

	[list <r> <averaged rmsds>]

------------------ 


### ::utiltools::quantumdots

::utiltools::quantumdots provides procedures useful to study quantum dots and nanocrystals.

#### ::utiltools::quantumdots::getAtmTypes

**DESCRIPTION**

Search atoms of the surface and on the bulk according to the
first\_neighbour\_distances, the distance of the first neighbours of
the same type.  first\_neighbour\_distances is user-provided.

**SYNOPSIS**

	::utiltools::quantumdot::getAtmTypes <molID> <list atomnames> <list first\_neighbour\_distances> <frame (0)>]

**OPTIONS**

	* molID
	* atomnames
	* first\_neighbour\_distances
	* frame (optional, default=0)

**RETURN**

	list [array get CoordNumLists ]
	     [array get CoordNums ]
	     [array get surfaceIDs ]
	     [array get bulkIDs ]

Ex. of usage:

	set AtmTypList '[::utiltools::quantumdot::getAtmTypes top \{Cd Se\} \{4.35 4.35\}]'
	array set CoordNumLists '[lindex $AtmTypList 0]'
	array set CoordNums     '[lindex $AtmTypList 1]'
	array set surfaceIDs	  '[lindex $AtmTypList 2]'
	array set bulkIDs       '[lindex $AtmTypList 3]'


----------------
