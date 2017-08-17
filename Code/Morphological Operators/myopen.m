function image = myopen(inputImg, se)
    % myopen
    % Perform an opening, defined as an erosion followed by a dilation.
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
    %image = myopen(imread('00.001146.jpg'), strel('square', 5));
    
    %Convert the input image to grayscale.
    if size(inputImg,3) == 3
       inputImg = rgb2gray(inputImg)
    end
    
	%First erode the image
	erodedImage = myerode(inputImg, se);
	
	%Then dilate it
	image = mydilate(erodedImage, se);
end