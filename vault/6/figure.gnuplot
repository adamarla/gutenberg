
set format "%.5f" ;
set samples 30 ; 

set table "m05_1.table" ; 
plot [0.5:-1.5] (-1-x) ;                                                                                                               
set table "m05_2.table" ;
plot [-0.5:1.5] (x-1) ;

set table "m05_3.table" ;
plot [0.5:-1.5] (1+x) ;

set table "m05_4.table" ;
plot [-0.5:1.5] (1-x) ;

