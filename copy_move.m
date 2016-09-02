
 
%   This is an implementation of an algorithm described in  
%   Fridrich et al, J.Fridrich, D. Soukal, and J. Lukas. Detection of Copy-Move Forgery in  
%   digital Images. Proc. Of Digital Forensic Research Workshop, Aug. 2003. 



%Quality factor influences how 
% "good" a match is (higher value = less match, lower value = stronger 
% match) and the threshold is the number of patches that need to appear  
% to be copied together for it to be considered a forged region.  


function image_copy = copy_move(color_image, quality_factor, threshold) 
 
    image_copy = color_image; 
    input_image = 255*im2double(rgb2gray(color_image)); % convert to RGB image



block_size = 16; %want 16x16 blocks 
%========compute DCT Matrix ===================================
      Q_8x8 =[ 4, 4, 6, 11, 24, 24, 24, 24 ; 
              4, 5, 6, 16, 24, 24, 24, 24 ; 
	         6, 6, 14, 24, 24, 24, 24, 24; 
	       11, 16, 24, 24, 24, 24, 24, 24; 
		  24, 24, 24, 24, 24, 24, 24, 24; 
		  24, 24, 24, 24, 24, 24, 24, 24; 
 		  24, 24, 24, 24, 24, 24, 24, 24; 
 		  24, 24, 24, 24, 24, 24, 24, 24; ]; 
Q_16x16 = imresize(Q_8x8,[16,16]);
[height, width] = size(input_image); 
test_image = zeros(height, width, 3); 



%================ Break image into blocks  ===================== 
%% 
patches = im2col(input_image(:,:,1),[block_size,block_size],'sliding'); %breaks image into blocks 
[m1, n1] = size(patches); 
num_blocks = (1:n1); 
%================ Break image into blocks  ===================== 


%================First compute DCT of each block================ 
%% 
disp('Computing the DCT Transform of each 16x16 window'); 
%size of matrix for storing dct's is 
num_rows = (size(input_image, 1) - block_size + 1) * (size(input_image, 2) - block_size + 1); 
dct_matrix = zeros(num_rows, block_size*block_size + 2); %the plus two is for xy locationof block in image 
[rows,cols] = ind2sub(size(input_image(:,:,1))- block_size + 1, num_blocks); 
for ind = 1:num_rows %for every 16x16 window in the image, compute 
                     %the DCT transform of that window and save it 
    %first find the top left corner of that block in the image 
    %then convert each block to a single row vector 
    %then compute its DCT  
    %then store that row in the dct matrix 
    x1 = rows(ind);  
    y1 = cols(ind); 
    %note that the blocks are column vectors. 
    %need to reshape each one into a block, compute the dct of the block, 
    %and then convert it to a row vector to be stored in the image 
    temp_mat = reshape(patches(:,ind), [block_size block_size]); 
    temp_mat = round((dct2(temp_mat)./quality_factor)./Q_16x16); 
    temp_mat = temp_mat(:)'; 
    dct_matrix(ind,:) = [temp_mat, x1, y1]; 
end 


%================First compute DCT of each block================ 


%%  
%================Sort the DCT Matrix================ 
disp('sort rows of dct matrix'); 
%store the x,y of the top left corner of each block 
%in the last two columns of this matrix, and then sort the matrix based on 
%the first 1 - n-2 columns (thereby preserving the information and keeping 
%the data so that it can be found when we want to find a block in the 
%image) 
dct_matrix = sortrows(dct_matrix, 1:size(dct_matrix,2) - 2);  


%into 2 matrices, one with the locations and 
%one with the dct values 
dct_locs = dct_matrix(:,size(dct_matrix,2) - 1: size(dct_matrix,2)); 
dct_matrix = dct_matrix(:, 1:size(dct_matrix,2)-2); 
                                   %image 
%================Sort the DCT Matrix================ 


%%  
%=========Find matching blocks and construct shift vectors===========                  


disp('Constructing shift vectors for all the matching block pairs'); 
%here we need to make sure that we only compare all the columns but the 
%last two so that we don't accidently compare the xy locations of the block 
%in the image  


num_match_index = 1; 
shift_vector = zeros(num_rows, 2); 
match1 = zeros(num_rows, 2); 
match2 = zeros(num_rows, 2); 
shift_vector_count = zeros(max(height+1, width+1),max(height+1, width+1));  


 %shift vectors are stored 1 bigger than they actually are to correct for 
 %matlab indexing that starts at 1 instead of zero 
 for ind = 1:num_rows - 1  
     if isequal(dct_matrix(ind,:), dct_matrix(ind + 1,:)) %compare every row to its adjacent row 
        % disp('Found two equal rows in the DCT_matrix'); 
         %they are equal. now lets grab the coordinates of these blocks in 
         %the image 
         x1y1 = dct_locs(ind, :); 
         x2y2 = dct_locs(ind + 1, :); 
          
         %then compute the shift vector between the two of the matching 
         %blocks 
         % the shift vector is made using the indices of the top left 
         % corner of the block's position. 
         shift_vector(num_match_index,:) = [abs(x1y1(1) - x2y2(1)), abs(x1y1(2) - x2y2(2))]; 
         if ~isequal(shift_vector(num_match_index,:), [0,1]) && ... 
                 ~isequal(shift_vector(num_match_index,:), [1,0]) && ... 
                 ~isequal(shift_vector(num_match_index,:), [1,1]) 
              
             match1(num_match_index,:) = x1y1; 
             match2(num_match_index,:) = x2y2; 
             shift_vector_count(abs(x1y1(1) - x2y2(1)) + 1, abs(x1y1(2) - x2y2(2)) + 1) ...  
                 = shift_vector_count(abs(x1y1(1) - x2y2(1)) + 1, abs(x1y1(2) - x2y2(2)) + 1) + 1; 
             num_match_index = num_match_index + 1; %incrememnt index in structure 
         end 
     end 
 end %end for loop 
 

 %clamp the match1, match2, shift_vector matrices after this loop according  
 %to num_match_index so that we dont keep them around too long and slow  
 %down processing 
 

 match1 = match1(1:num_match_index, :); 
 match2 = match2(1:num_match_index, :); 
 shift_vector = shift_vector(1:num_match_index, :); 
 %% 
 disp('Looking for common shift vectors among matching blocks'); 
 %currently have a count of all shift vectors and the number of times they 
 %occured. loop over all the counts of shift vectors 
 %in this list and if there is a shift vector that occurred more than 
 %threshold times, then find all occurrences of that shift vector in the 
 %shift_struct and color those pairs. 
 

 

 %get all coordinates with value greater than the threshold 
 [shiftx,shifty] = ind2sub(size(shift_vector_count), find(shift_vector_count > threshold)); 
 

 %then extract those shift vectors from shift_vector_count 
 %all pairs of values that correspond with some shift vector (tempx,tempy) 
 %will be colored with the same color 
 

 disp(strcat('there are:',{' '}, num2str(size(min(shiftx,shifty),1)), ' shift vectors')); 
 for ind = 1:size(min(shiftx,shifty), 1) %for all shift vectors 
     %grab locations of those shift vectors and subtract one to correct for 
     %indexing from before 
     locs = ind2sub(size(shift_vector,1), ... 
         find(shift_vector(:,1) == (shiftx(ind) - 1) & shift_vector(:,2) == (shifty(ind) - 1)));  
                                                             
     %locs are the indices in match1, match2, and shift_vector corresponding  
     %to this shift that met the threshold 
      
     %disp(strcat({'shift vector '}, num2str(ind), {', [x = ' }, num2str(shiftx(ind) - 1), {', y = '}, num2str(shifty(ind) - 1), {']; appeared: '}, num2str(size(locs, 1)), {' times'})); 
     for ind2 = 1:size(locs, 1) %for all the pairs that have that shift vector 
         x1y1 = match1(locs(ind2),:); 
         x2y2 = match2(locs(ind2),:); 
          %color them the same color 
          image_copy(x1y1(1):x1y1(1)+block_size - 1, x1y1(2):x1y1(2)+block_size - 1, 1 + mod(ind,3)) = 250; 
          image_copy(x2y2(1):x2y2(1)+block_size - 1, x2y2(2):x2y2(2)+block_size - 1, 1 + mod(ind,3)) = 250; 
           
          test_image(x1y1(1):x1y1(1)+block_size - 1, x1y1(2):x1y1(2)+block_size - 1, 1 + mod(ind,3)) = 1; 
          test_image(x2y2(1):x2y2(1)+block_size - 1, x2y2(2):x2y2(2)+block_size - 1, 1 + mod(ind,3)) = 1;        
     end 
 end 
 % 
 %figure, imagesc(color_image), title('original image'); 
 figure, imagesc(image_copy), title([{'with highlighting'}, { 'quality factor = ', quality_factor,  ... 
     ' threshold = ' , threshold}]); 
 figure, imagesc(test_image), title([{'Test Image'}, { 'quality factor = ', quality_factor,  ... 
     ' threshold = ' , threshold}]); 

        
 end 
