
set format "%.5f" ;
set samples 30 ; 

set parametric ;
set table "m06_1.table" ;
set trange [0:2*pi] ;
plot cos(t), sin(t) ;  
