Img_directory ='IMG_DIRECTORY'; %The directory storaging the NIR940 linearized tiff images
Code_directory='MATLAB_LIBRARY'; %The path indicating Matlab script library
Result_directory='RESUTL_DIRECTORY'; %Where the results should go
labelfileName='LABEL_FILE.csv'; %The corresponding CSV file that containing label information (see Examplar file for data structure)
%%
%%%Guide%%%
%The entire process must be in order: Left -> Right; Top -> Bottom
%Once an image shows
%Press "left" and "right" arrow to select the prefered box
%Use "mouse" to resize the box if need
%Press "down" arrow TWICE to confirm the box for that specimen
%Press "r" if you want to redo this entire image before it is closed
%Press 'f' if you want to finish the process or if tthe panel doesn't close by itself (i.e. No corresponding record found.) after defining the
%box for the last specimen on the stage. (Must do it right after defining the last one! [pressing twice the "down arrow" for the last one.]) 
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(genpath(Code_directory)) %Add the library to the path
ManuallyFindCoraseOutlines2(Img_directory,Code_directory,Result_directory,labelfileName);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%