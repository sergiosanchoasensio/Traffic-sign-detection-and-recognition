function image = mytophat(inputImg, se)
    % mytophat
    % Perform a top hat, defined as the difference between the input image and its opening.
	% Group 5.
    %
    %    Parameter name     Value
    %    --------------     -----
    %    'I'         		Input image
    %    'SE'      			Structuring element
    %    Return      		Value
    %    --------------     -----
    %    'image'         	Output image
    %E.g.:
    %image = mytophat(imread('00.001146.jpg'), strel('square', 2));
    
    inputImg = rgb2gray(inputImg);
    
	%First open the image
	openImage = myopen(inputImg, se);
    
	%Then calc. the difference between the input image and its opening.
	image = inputImg - openImage;
end