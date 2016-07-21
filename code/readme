# Theory

### Normalization and denormalization 
 
Before applying distrtion and undistortion functions we normalize image coordinates. Normalization basically scales and centers coordinates:

$$ x_n = \dfrac {x - .5*width } {height + width} $$ $$ y_n = \dfrac {y - .5*height} {height + width} $$

After applying distrtion and undistortion functions we denormalize image coordinates. 

### [Distortion](http://www.robots.ox.ac.uk/~dclaus/publications/claus05rf_model.pdf) 

 Given distorted image coordinates (i, j) and parameters of rational distortion model A1_row, A2_row, A3_row we can compute ideal image coordinates (x, y) as
  
$$ \chi = \begin{bmatrix} i^2 & i*j  & j^2 & i &  j & 1 \end{bmatrix} $$ $$ x = \dfrac { A_{1row} \chi^T } { A_{3row} \chi^T }$$ $$ y = \dfrac { A_{2row} \chi^T } { A_{3row} \chi^T }$$

From this equation it follows that for every distorted coordinates (i, j), there is a unique pair of undistorted coordinates (x, y). Converse is not true.

### Undistortion

To find distorted coordinates (i, j) from ideal coordinates (x, y) we need to solve system of equations, that potentially has several solutions. The fact that lens distortions are small allows us to find the unique solution using Newton method, described below.

To find distorted coordinates, we minimize vector function with respect to i and j 

$$ F(i, j) = 
\left[
\begin{array}{r} 
x - \dfrac { A_{1row} \chi^T } { A_{3row}  \chi^T } \\ 
y - \dfrac { A_{2row} \chi^T } { A_{3row} \chi^T} 
\end{array}
\right]
$$

This function has Jacobian

$$ J(i, j) = 
\left[
\begin{array}{r} 
 - \dfrac {(A_{1row}{\chi_i'}^T)(A_{3row}\chi^T) - (A_{1row}\chi^T)(A_{3row}{\chi_i'}^T)} { (A_{2row}*\chi^T)^2} &
 - \dfrac {(A_{1row}{\chi_j'}^T)(A_{3row}\chi^T) - (A_{1row}\chi^T)(A_{3row}{\chi_j'}^T)} { (A_{2row}*\chi^T)^2} \\
 - \dfrac {(A_{2row}{\chi_i'}^T)(A_{3row}\chi^T) - (A_{2row}\chi^T)(A_{3row}{\chi_i'}^T)} { (A_{2row}*\chi^T)^2} &
 - \dfrac {(A_{2row}{\chi_j'}^T)(A_{3row}\chi^T) - (A_{2row}\chi^T)(A_{3row}{\chi_j'}^T)} { (A_{2row}*\chi^T)^2} \end{array}
\right]
$$

$$ \chi_i' = \begin{bmatrix} 2i &  j &  0 &  1 & 0 & 0 \end{bmatrix} $$ $$ \chi_j' = \begin{bmatrix} 0 &  i &  2j &  1 & 0 & 0 \end{bmatrix} $$ 

We can find (i, j) using several iterations of Newton Method, starting from $ (i_0, j_0) = (x, y) $ as following
$$ \begin{bmatrix} i_n \\ j_n  \end{bmatrix}  =  \begin{bmatrix} i_{n-1} \\ j_{n-1}  \end{bmatrix} - \mathbf J(i_{n-1}, j_{n-1})^{-1} \times \mathbf F(i_{n-1}, j_{n-1}) $$
      
$$ \mathbf J^{-1} \times \mathbf F = \dfrac {1} {J_{11} J_{22} - J_{12} J_{21}} \begin{bmatrix}{J_{22}F_{11} - F_{12} J_{12}  \\ -J_{21} F_{11} + J_{11} F_{12}} \end{bmatrix} $$
              

# Use example (C++)

If we want to compute distorted coordinates (i, j) form ideal coordinates (x, y) :
  
> rf_normalize_point(x_norm, y_norm, x, y, width, height);
> rf_distort_point(i_norm, j_norm, x_norm, y_norm, A1_row, A2_row, A3_row);
> rf_denormalize_point(i, j, i_norm, j_norm, width, height);

If we want to compute  ideal coordinates (x, y) fom distorted coordinates (i, j):

> rf_normalize_point(i_norm, j_norm, i, j, width, height);
> rf_undistort_point(x_norm, y_norm, divider, i_norm, j_norm, A1_row, A2_row, A3_row);
> rf_denormalize_point(x_, y_, x_norm, y_norm, width, height);
