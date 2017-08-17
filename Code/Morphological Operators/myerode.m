function image = myerode(I, SE)
% mydilate
    % Perform a erosion, defined as the minimum of the gray levels below the strcturing element
	% Group 5.
    %
    %    Parameter name     Value
    %    --------------     -----
    %    'I'         		Input image
    %    'SE'      			Structuring element
    %    'dii'              displacement X pixels in i, left side
    %    'did'              displacement X pixels in i, right side 
    %    'dji'              displacement X pixels in j, left side
    %    'djd'              displacement X pixels in j, right side
    %
    %    Return      		Value
    %    --------------     -----
    %    'image'         	Output image
    %E.g.:
    %image = myerode(rgb2gray(imread('00.001146.jpg')), strel('square', 5));
    
if(isa(SE,'strel')) %convert type strel to double
    nhood = SE.getnhood;
    SE = double(nhood);
end
SE(SE == 0)= inf;
I = double(I);
X = size(SE,1);
Y = size(SE,2);
dii_init_value = floor((X-1)/2); %displacement X pixels in i, left side
did_init_value = round((X-1)/2); %displacement X pixels in i, right side 
dji_init_value = floor((Y-1)/2); %displacement X pixels in j, left side
djd_init_value = round((Y-1)/2); %displacement X pixels in j, right side

for i = 1:size(I,1)
    for j = 1:size(I,2)
        dii = dii_init_value; did = did_init_value;
        dji = dji_init_value; djd = djd_init_value;
        
        if( i-dii < 1 || i+did > size(I,1) || j-dji < 1 || j+djd > size(I,2))%Estudi the boundaries 
            if( i-dii < 1)
                dii = i - 1;
            end
            if( i+did > size(I,1))
                did = size(I,1) - i;
            end
            if( j-dji < 1)
                dji = j - 1;
            end
            if( j+djd > size(I,2))
                djd = size(I,2) - j;
            end
            SEn = SE(round(X/2)-dii:round(X/2)+did,round(Y/2)-dji:round(Y/2)+djd);%Reduce the str.element if we are in the boundaries.
            image(i,j) = min(min(I(i-dii:i+did, j-dji:j+djd).*SEn));%take max value of the pixels below the strc element
        else
            image(i,j) = min(min(I(i-dii:i+did, j-dji:j+djd).*SE));%take max value of the pixels below the strc element
        end
    end
end
image = uint8(image);
end