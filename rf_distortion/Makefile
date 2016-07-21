all:
	g++ -Wall rf_distortion.cpp -o rf_distortion.so -fPIC -shared
	g++ -Wall TEST_rf_distortion.cpp rf_distortion.so -o TEST_rf_distortion
