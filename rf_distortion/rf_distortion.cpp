#include <stdio.h>
#include <math.h>

void rf_apply2point(float &ox, float &oy,
                float ix, float iy,
                const float *A1_row, const float *A2_row, const float *A3_row)
{


    float ix2 = ix*ix;
    float iy2 = iy*iy;
    float ixiy = ix*iy;
    float divider;

    divider = ix2 * A3_row[0] + ixiy * A3_row[1] + iy2 * A3_row[2] + ix * A3_row[3] + iy * A3_row[4] + A3_row[5];    

    ox = ( ix2 * A1_row[0] + ixiy * A1_row[1] + iy2 * A1_row[2] + ix * A1_row[3] + iy * A1_row[4] + A1_row[5] ) / divider;
    oy = ( ix2 * A2_row[0] + ixiy * A2_row[1] + iy2 * A2_row[2] + ix * A2_row[3] + iy * A2_row[4] + A2_row[5] ) / divider;
}


void rf_correct(float &x_fp, float &y_fp,
                float i_fp, float j_fp,
                const float *A1_corr_row, const float *A2_corr_row, const float *A3_corr_row)
{
    /**

     Given distorted focal plane coordinates in millimeters (i_fp, j_fp) and parameters of rational CORRECTION
     model A1_corr_row, A2_corr_row, A3_corr_row function returns ideal focal plane coordinates (x_fp, y_fp) 
     in millimeters.

     Rational optical distrotion correction model is described by following equation

     ij_chi_row = [ i_fp^2, i_fp*j_fp, j_fp^2, i_fp, j_fp, 1]

            A1_corr_row * ij_chi_row'
     x =    -------------------------
            A3_corr_row * ij_chi_row'

            A2_corr_row * ij_chi_row'
     y =    ------------------------
            A3_corr_row * ij_chi_row'

    **/

    rf_apply2point(x_fp, y_fp, i_fp, j_fp, A1_corr_row, A2_corr_row, A3_corr_row);
}

void rf_distort(float &i_fp, float &j_fp,
                float x_fp, float y_fp,
                const float *A1_dist_row, const float *A2_dist_row, const float *A3_dist_row)
{
    /**

     Given ideal focal plane coordinates (x_fp, y_fp) in millimeters and parameters of rational DISTORTION*
     model A1_dist_row, A2_dist_row, A3_dist_row function returns distorted focal plane coordinates 
     (i_fp, j_fp) in millimeters

     Rational optical distrotion correction model is described by following equation

     xy_chi_row = [ x_fp^2, x_fp*y_fp, y_fp^2, x_fp, y_fp, 1]

             A1_dist_row * xy_chi_row'
     i_fp =  ------------------------
             A3_dist_row * xy_chi_row'

             A2_dist_row * xy_chi_row'
     j_fp =  -------------------------
             A3_dist_row * xy_chi_row'

    ------------------------------------------------------------------------------------------------------
    *  Interestingly, while not easily invertible, the rational model can represent very precisely the inverse of
       itself. We use this property and instead of inverting the CORRECTION model we simply estimate
       DISTORTION model together with CORRECTION.
    
    **/
    rf_apply2point(i_fp, j_fp, x_fp, y_fp, A1_dist_row, A2_dist_row, A3_dist_row);
}


void rf_detector2focalplane(float &x_fp, float &y_fp, float x, float y, float width, float height, float pix_pitch)
{
    /**
     Given detector coordinates in pixels (x, y) function computes focal plane coordinates in millimeters (x_fp, y_fp)	
    **/

    x_fp = (x - width  / 2.0) * pix_pitch;
    y_fp = (y - height / 2.0) * pix_pitch;

}

void rf_focalplane2detector(float &x, float &y, float x_fp, float y_fp,  float width, float height, float pix_pitch)
{
    /**
     Given focal plane coordinates in millimeters (x_fp, y_fp) function computes detector coordinates in pixels (x, y). 	
    **/

    x = x_fp / pix_pitch + width  / 2.0;
    y = y_fp / pix_pitch + height / 2.0;

}


int main()
{
  
   float A1_corr_row[6] = {0.00376130530948266, -0.0134154156065812,   -1.86749521007237e-05, 1.00021352681836,    -0.000432362371703953,-0.000948065735350123};
   float A2_corr_row[6] = {9.9842559363676e-05,  0.00373543707958162,  -0.0133299918873929,  -0.000215311328389359, 0.995296015537294,   -0.0183542717710778};
   float A3_corr_row[6] = {-3.13320167004204e-05,-7.35655125749807e-06,-1.57664245066771e-05, 0.00373549465439151, -0.0141671946930935,   1.0};
   
   float A1_dist_row[6] = {0.00213658795560622  ,  -0.00711785765064197,  1.10355974742147e-05, 0.573607182625377,    0.000250884350194894, 0.000550623913037132};
   float A2_dist_row[6] = {-5.69725741015406e-05,  0.00215155905679149,  -0.00716392991767185,  0.000124152787728634, 0.576459544392426,    0.010576940564854};
   float A3_dist_row[6] = {1.78250771483506e-05 ,  4.24592743471094e-06,  9.51220699036653e-06, 0.00215158425420738, -0.0066835595774833,   0.573741540971609};
   
   float width = 2048;
   float height = 2048;
   float pix_pitch = 0.01; // mm
     
   float max_err = -1;
   FILE *f_distorted2ideal = fopen("distorted2ideal.txt", "w");
   FILE *f_ideal2distorted = fopen("ideal2distorted.txt", "w");

   for(float x = 0; x < width; x+=16)
   for(float y = 0; y < height; y+=16)
   {
	float x_fp, y_fp;
	float i_fp, j_fp;
	float i, j;
	
	float x_fp_pred, y_fp_pred;
	float x_pred, y_pred;	

        // detector to focal plane
	rf_detector2focalplane(x_fp, y_fp, x, y, width, height, pix_pitch);
	//printf("(x, y) = (%3.5f,%3.5f) == > (x_fp, y_fp) = (%3.5f,%3.5f)\n", x, y, x_fp, y_fp);

        // distort
	rf_distort(i_fp, j_fp, x_fp, y_fp, A1_dist_row, A2_dist_row, A3_dist_row);
	//printf("(x_fp, y_fp) = (%3.5f,%3.5f) == > (i_fp, j_fp) = (%3.5f,%3.5f)\n", x_fp, y_fp, i_fp, j_fp);
	rf_focalplane2detector(i, j, i_fp, j_fp, width, height, pix_pitch);
	
	// correct
	rf_correct(x_fp_pred, y_fp_pred, i_fp, j_fp, A1_corr_row, A2_corr_row, A3_corr_row);
	//printf("(i_fp, j_fp) = (%3.5f,%3.5f) == > (x_fp_pred, y_fp_pred) = (%3.5f,%3.5f)\n", i_fp, j_fp, x_fp_pred, y_fp_pred);

	// focal plane to detector
	rf_focalplane2detector(x_pred, y_pred, x_fp_pred, y_fp_pred, width, height, pix_pitch);
    //printf("(x_fp_pred, y_fp_pred) = (%3.5f,%3.5f) == > (x_pred, y_pred) = (%3.5f,%3.5f)\n", x_fp_pred, y_fp_pred,  x_pred, y_pred);
	   
    float err = sqrt((x-x_pred)*(x-x_pred) + (y-y_pred)*(y-y_pred));
    if (err > max_err) max_err = err;

    fprintf(f_distorted2ideal, "%3.5f, %3.5f, %3.5f, %3.5f\n", i, j, x_pred-i, y_pred-j);
    fprintf(f_ideal2distorted, "%3.5f, %3.5f, %3.5f, %3.5f\n", x, y, x-i, y-j);
   }
   printf("Maximum error after distortion and correction %.5f\n", max_err);
   fclose(f_distorted2ideal);
   fclose(f_ideal2distorted);

   return 0;
}




