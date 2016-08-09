#ifndef RF_DISTORTION_H_INCLUDED
#define RF_DISTORTION_H_INCLUDED

void rf_normalize_point(float &x_norm, float &y_norm,
                        float x,       float y,
                        float width,   float height);

void rf_denormalize_point(float &x, float &y,
                        float x_norm,       float y_norm,
                        float width, float height);

void rf_undistort_point(float &x, float &y, float &divider,
                               float i, float j,
                               const float *A1_row, const float *A2_row, const float *A3_row);

void rf_distort_point(float &i, float &j, float x, float y,
	       const float *A1_row, const float *A2_row, const float *A3_row, int newton_iter_nb = 2);

#endif // RF_DISTORTION_H_INCLUDED
