function image = myclose(inputImg, se)
    % myclose
    % Perform a closing, defined as a dilation followed by an erosion.
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
    %image = myclose(rgb2gray(imread('00.001146.jpg')), strel('square', 5));
    
    %Convert the input image to grayscale.
    if size(inputImg,3) == 3
       inputImg = rgb2gray(inputImg)
    end
    
	%Dilate the image
	dilatedImage = mydilate(inputImg, se);
	
	%Then erode it
	image = myerode(dilatedImage, se);
end