
set format "%.5f" ;
set samples 30 ; 

set table "m04_1.table";
plot[0:1.5] (2*sqrt(x)) ;

set table "m04_2.table";
plot[0:1.5] (-2*sqrt(x)) ;

set parametric ;
set table "m04_3.table" ;
set trange [0:2*pi] ;
plot 1.5*cos(t), 1.5*sin(t) ;  
