#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include "rf_distortion.h"

using namespace std;

int main()
{
   float A1_row[6] = {-0.6106, -0.5445, -0.0015, 0.9998, 0.0002, 0};
   float A2_row[6] = {-0.0049, -0.607, -0.5433, -0.0005, 0.9943, 0.0005};
   float A3_row[6] = {-0.0496, -0.0257, -0.0703, -0.6092, -0.5101, 1};
   float width = 2048;
   float height = 2048;

   // save original, distorted and corrected coordinates to file
   FILE *f = fopen("vectorfield.txt", "w");

   float max_err = 0;
   float mean_err = 0;
   float cnt;
   for(int x = 0; x < width; x+=50)
   for(int y = 0; y < height; y+=50)
   {
        float x_norm, y_norm;
        float i_norm, j_norm;
        float x_, y_;
        float i, j;
        float divider;

        // distort
        rf_normalize_point(x_norm, y_norm, x, y, width, height);
        rf_distort_point(i_norm, j_norm, x_norm, y_norm, A1_row, A2_row, A3_row);
        rf_denormalize_point(i, j, i_norm, j_norm, width, height);

        // correct
        rf_normalize_point(i_norm, j_norm, i, j, width, height);
        rf_undistort_point(x_norm, y_norm, divider, i_norm, j_norm, A1_row, A2_row, A3_row);
        rf_denormalize_point(x_, y_, x_norm, y_norm, width, height);

        float err = sqrt((x-x_)*(x-x_) + (y-y_)*(y-y_));
        fprintf(f, "%3.5f %3.5f %3.5f %3.5f\n", (float)i, (float)j, x_-i, y_-j);
        if (err > max_err) max_err = err;
        mean_err += err;
        cnt++;
   }
   mean_err /= cnt;
   printf("Error of distortion and correction function: mean=%.5f, max=%.5f\n", mean_err, max_err);
   fclose(f);

   return 0;
}
