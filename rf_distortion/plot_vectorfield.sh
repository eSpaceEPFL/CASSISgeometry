#!/usr/bin/gnuplot -persist
magn(x,y) = sqrt(x*x+y*y)
plot "vectorfield.txt" using 1:2:(5*$3):(5*$4):(magn($3,$4)) w vec filled lc palette; pause -1


    