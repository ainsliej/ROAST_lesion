ROAST_lesion
Ainslie Johnstone
Jan 2021


The ROAST_lesion folder contains code needed for running two modified version of ROAST 2.7 (https://www.parralab.org/roast/)

- roast_seg 
This is a truncated version of ROAST which just runs segmentation and then stops. It outputs all the files needed to run ROAST from stage 3 onwards. This is useful because you can modify the ROAST segmented files as needed, e.g. adding another tissue type, cleaning up lesion segmentation etc. 
 
- roast7 
This is a version of ROAST which allows for a 7th tissue type. You must input all the files that are output from roast_seg, either with or without your own edits. 

N.B. zeropadding, resampling and RAS reorienting are all turned off in roast_seg and roast7. You should make sure your inputs are already correctly oriented before you run these scripts. A function (PrepForROAST.m) to perform this is included here also. 


Also here is an example of the code (lesion_example_solarSystemAJ.m) I used to make the artificial lesions, and run roast7 in my own brain. 
