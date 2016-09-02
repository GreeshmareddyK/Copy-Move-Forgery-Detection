%   This is an implementation of an algorithm described in  
%   Fridrich et al, J.Fridrich, D. Soukal, and J. Lukas. Detection of Copy-Move Forgery in  
%   digital Images. Proc. Of Digital Forensic Research Workshop, Aug. 2003. 



%Quality factor influences how 
% "good" a match is (higher value = less match, lower value = stronger 
% match) and the threshold is the number of patches that need to appear  
% to be copied together for it to be considered a forged region.  


clear all;
close all;
[filename, user_canceled] = imgetfile;
color_image=imread(filename);
imshow(color_image,[]);
title('suspected image');
quality_factor = 0.5;  
threshold = 10; 
copy_move(color_image, quality_factor, threshold)
