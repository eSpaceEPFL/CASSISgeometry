# Use example (C++)

If we want to compute distorted coordinates (i, j) form ideal coordinates (x, y) :
~~~~
rf_normalize_point(x_norm, y_norm, x, y, width, height)
rf_distort_point(i_norm, j_norm, x_norm, y_norm, A1_row, A2_row, A3_row)
rf_denormalize_point(i, j, i_norm, j_norm, width, height)
~~~~

If we want to compute  ideal coordinates (x, y) fom distorted coordinates (i, j):
~~~~
rf_normalize_point(i_norm, j_norm, i, j, width, height);
rf_undistort_point(x_norm, y_norm, divider, i_norm, j_norm, A1_row, A2_row, A3_row);
rf_denormalize_point(x_, y_, x_norm, y_norm, width, height);
~~~~
