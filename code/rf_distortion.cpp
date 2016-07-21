#include "rf_distortion.h"

void rf_normalize_point(float &x_norm, float &y_norm,
                        float x,       float y,
                        float width,   float height)
{
    float sum = width + height;
    x_norm = (x - width / 2) / sum;
    y_norm = (y - height / 2) / sum;
}

void rf_denormalize_point(float &x, float &y,
                        float x_norm,       float y_norm,
                        float width, float height)
{
    float sum = width + height;
    x = x_norm * sum + width / 2;
    y = y_norm * sum + height/ 2;
}

void rf_undistort_point(float &x, float &y, float &divider,
                               float i, float j,
                               const float *A1_row, const float *A2_row, const float *A3_row)
{

    float i2 = i*i;
    float j2 = j*j;
    float ij = i*j;

    divider = i2 * A3_row[0] + ij * A3_row[1] + j2 * A3_row[2] + i * A3_row[3] + j * A3_row[4] + 1;    // divider we might nead for debuging

    x = ( i2 * A1_row[0] + ij * A1_row[1] + j2 * A1_row[2] + i * A1_row[3] + j * A1_row[4] + A1_row[5] ) / divider;
    y = ( i2 * A2_row[0] + ij * A2_row[1] + j2 * A2_row[2] + i * A2_row[3] + j * A2_row[4] + A2_row[5] ) / divider;
}

void rf_distort_point(float &i, float &j, float x, float y,
	       const float *A1_row, const float *A2_row, const float *A3_row, int newton_iter_nb)
{

     i = x;
     j = y;

     for( int newton_iter = 0; newton_iter < newton_iter_nb; ++newton_iter )
     {
        // conpute F(i_pre, j_pre)
        /**
        F_vec(i,j) = [ x - ( A1_row * chi_row' ) / ( A3_row * chi_row' ) ]
 	          [ y - ( A2_row * chi_row' ) / ( A3_row * chi_row' ) ]
        **/

        float x_predict = 0;
        float y_predict = 0;
        float divider = 0;

        rf_undistort_point(x_predict, y_predict, divider, i, j, A1_row, A2_row, A3_row);

        float f11 = x - x_predict;
        float f21 = y - y_predict;

        // compute J(i, j)
        /**
        J(i,j) = [ - ( (A1_row*dchi_row/di') - x_predicted*(A3_row*dchi_row/di) ) / (A3_row*chi_row'),...
                   - ( (A1_row*dchi_row/dj') - x_predicted*(A3_row*dchi_row/dj) ) / (A3_row*chi_row');...
                   - ( (A2_row*dchi_row/di') - y_predicted*(A3_row*dchi_row/di) ) / (A3_row*chi_row'),...
                   - ( (A2_row*dchi_row/dj') - y_predicted*(A3_row*dchi_row/dj) ) / (A3_row*chi_row')]

        dchi_row/di = [2i  j  0   1 0 0]
        dchi_row/dj = [0   i  2j  0 1 0]
        **/
        float j11 = - ( ( 2*i*A1_row[0] + j*A1_row[1] + A1_row[3] ) - x_predict * ( 2*i*A3_row[0] + j*A3_row[1] + A3_row[3] ) ) / divider;
        float j12 = - ( ( i*A1_row[1] + 2*j*A1_row[2] + A1_row[4] ) - x_predict * ( i*A3_row[1] + 2*j*A3_row[2] + A3_row[4] ) ) / divider;
        float j21 = - ( ( 2*i*A2_row[0] + j*A2_row[1] + A2_row[3] ) - y_predict * ( 2*i*A3_row[0] + j*A3_row[1] + A3_row[3] ) ) / divider;
        float j22 = - ( ( i*A2_row[1] + 2*j*A2_row[2] + A2_row[4] ) - y_predict * ( i*A3_row[1] + 2*j*A3_row[2] + A3_row[4] ) ) / divider;

        // compute update
        /**

        [i_n, j_n]  = [i_n-1, j_n-1] - inv(J(i_n-1, j_n-1))*F(i_n-1, j_n-1);

                           1             [  J22 -J12 ] [ F11 ]   [  J22*F11 - J12*F21 ]
        inv(J)*F =  ------------------ * [ -J21  J11 ] [ F21 ] = [ -J21*F11 + J11*F21 ]
                    J11*J22 - J12*J21
        **/
        float di = - ( j22*f11 - j12*f21) / (j11*j22 - j12*j21);
        float dj = - (-j21*f11 + j11*f21) / (j11*j22 - j12*j21);
        i = i + di;
        j = j + dj;

    }
}




