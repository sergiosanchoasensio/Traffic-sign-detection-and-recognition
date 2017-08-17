% Parameters
directory = 'DataSetDelivered/test';
%window_method = 'SlidingWindow';
window_method = 'SegmentationCCL';
decision_method = 'corr';
%decision_method = 'greyscale';
%decision_method = 'chamfer';
%decision_method = 'hough';
filename = 'results.txt';
pixel_method = 'col_enh';

str = strel('disk',7);
str2 = strel('disk',5);
TrafficSignDetection(directory, pixel_method, [0.92 0.01 0.55 0.72], filename, window_method, decision_method, str,str2);