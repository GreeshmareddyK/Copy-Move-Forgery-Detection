  




function Q_16x16 = compute_dct_matrix() 
  
 

      Q_8x8 =[ 4, 4, 6, 11, 24, 24, 24, 24 ; 
              4, 5, 6, 16, 24, 24, 24, 24 ; 
	         6, 6, 14, 24, 24, 24, 24, 24; 
	       11, 16, 24, 24, 24, 24, 24, 24; 
		  24, 24, 24, 24, 24, 24, 24, 24; 
		  24, 24, 24, 24, 24, 24, 24, 24; 
 		  24, 24, 24, 24, 24, 24, 24, 24; 
 		  24, 24, 24, 24, 24, 24, 24, 24; ]; 

      
%     Q_8x8=[16  ,11,  10 , 16 , 24 , 40,  51,  61;
%     12 , 12 , 14 , 19 , 26  ,58 , 60,  55;
%     14  ,13 , 16 , 24 , 40 , 57,  69 , 56;
%     14  ,17 , 22  ,29 , 51 , 87 , 80  ,62;
%     18  ,22 , 37 , 56 , 68 , 109 ,103 ,77;
%     24  ,35  ,55 , 64 , 81 , 104 ,113 ,92;
%     49  ,64 , 78 , 87 , 103 ,121 ,120 ,101;
%     72 , 92 , 95 , 98 , 112 ,100, 103, 99]  ;
                                               
       Q_16x16=imresize(Q_8x8,[16,16]);
 end 

%  Q_8x8_prime = Q_8x8; 
%  Q_8x8_prime(1,1) = 2*Q_8x8_prime(1,1); 
%  Q_8x8_prime(2:8,2:8) = 2.5*Q_8x8_prime(2:8,2:8);%Top left corner block 
%  Q_18 = zeros(8,8) + 2.5*Q_8x8(1,8); %top right corner block 
%  Q_81 = zeros(8,8) + 2.5*Q_8x8(8,1); %bottom left corner block 
%  Q_88 = zeros(8,8) + 2.5*Q_8x8(8,8); %bottom right corner block 
 

 %Q_16x16 is the concactenation of all of the blocks described above 
%  Q_16x16 = vertcat(horzcat(Q_8x8_prime, Q_18),horzcat(Q_81, Q_88)); 

