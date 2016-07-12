#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include "rf_distortion.h"

using namespace std;

int main()
{
   float A1_row[6] = {-0.0018, -0.1367, -0.0000,  0.9999,  0.0000, 0.0000};
   float A2_row[6] = {-0.0036, -0.0018, -0.1366,  0.0000,  0.9949, 0.0000};
   float A3_row[5] = {-0.0467, -0.0001, -0.0466, -0.0018, -0.1044 };
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
        fprintf(f, "%3.5f %3.5f %3.5f %3.5f\n", (float)x, (float)y, i-x, j-y);
        if (err > max_err) max_err = err;
        mean_err += err;
        cnt++;
   }
   mean_err /= cnt;
   printf("Error of distortion and correction function: mean=%.5f, max=%.5f\n", mean_err, max_err);
   fclose(f);

   return 0;
}
