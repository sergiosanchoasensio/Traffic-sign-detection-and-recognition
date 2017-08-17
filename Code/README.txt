Block 5 deliverable, 15.11.2015.

Group 5: 
Sergi Sancho
Adriana Fern�ndez
Eric L�pez
Gerard Mart�


Annotations:
The system uses the data set images. Thus, one have to put: 
	train images in <DataSetDelivered/train> folder,
	test images in <DataSetDelivered/test> folder,
	gt in <DataSetDelivered/train or test/gt> folder,
	masks in <DataSetDelivered/train or test/mask> folder.
And attach every folder found in the .zip to the project.

In the following, we show a brief description of the system.

Folders to Add to path in order to make the function work properly:

    /circular_hough
    /evaluation
    /segmentatio_ihls
    /Templates

------------------------
TrafficSignDetection.m
------------------------

function TrafficSignDetection(directory, pixel_method, th, filename, window_method, decision_method, str, str2)
    % TrafficSignDetection
    % Perform detection of Traffic signs on images. Detection is performed first at the pixel level
    % using a color segmentation. Then, using the color segmentation as a basis, the most likely window 
    % candidates to contain a traffic sign are selected using basic features (form factor, filling factor). 
    % Finally, a decision is taken on these windows using geometric heuristics (Hough) or template matching.
    % Also, data about the efficiency of the color segmentation is written onto a file
    %
    %    Parameter name      Value
    %    --------------      -----
    %    'directory'         directory where the images to analize  (.jpg) reside
    %    'pixel_method'      Name of the color space: 'opp', 'normrgb', 'lab', 'hsv', etc. (Weeks 2-5)
    %    'th'                Vector that holds the thresholds for the color space
    %    'filename'          File where the output will be written
    %    'window_method'     'SegmentationCCL' or 'SlidingWindow' (Weeks 3-5)
    %    'decision_method'   'GeometricHeuristics' or 'TemplateMatching' (Weeks 4-5)
    %    'str'               Structuring element for first morphological operation
    %    'str2'              Structuring element for second morphological operation

Main file of the project, where the detection of the traffic signs is done.

------------------------
TestScript.m
------------------------

This script configure and call TrafficSignDetection.
Configuration:
	directory: test images path,
	pixel_method: col_enh or ihls,
	th: threshold,
	filename: output text file,
	window_method: SlidingWindow or SegmentationCCL,
	decision_method: corr, grayscale or chamfer,
	str and str2: structure element.
	

