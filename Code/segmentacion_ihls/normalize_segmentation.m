function [In] = normalize_segmentation(I, color, hue_max, hue_min, sat_min)
% Converts the image to IHLS and does the segmentation
%
% INPUT
%    I      : image to process
%    color  : 'blue' or 'red'
%
% OUTPUT
%    In     : normalized and segmented image

if nargin == 2
    if strcmp(color, 'other')
        if hue_max > 255 || hue_max < 0 || hue_min > 255 || hue_min < 0 || sat_min > 255 || sat_min < 0
            hue_max = 11;
            hue_min = 230;
            sat_min = 30;
        end
    elseif strcmp(color, 'blue')
        hue_max = 163;
        hue_min = 134;
        sat_min = 39;
    elseif strcmp(color, 'red')
        hue_max = 11;
        hue_min = 230;
        sat_min = 30;
    end
end

%% Convert to IHLS and normalize hue-saturation
I2 = rgb2ihls(I);       % convert to IHLS

h = I2(:,:,1);          % take hue channel
h_norm = h*255/(2*pi);  % rearrange from 0:2*pi to 0:255
h_norm = uint8(h_norm); % convert to uint8

s = I2(:,:,3);          % take saturation channel
s_norm = uint8(s);      % convert to uint8

%% Color Segmentation
In = zeros(size(I,1), size(I,2)); % create image to store output
if strcmp(color, 'blue')
    %     p = find((h_norm>=134 & h_norm<163) & (s_norm>60 & s_norm<=215));
    p = find((h_norm > hue_min & h_norm < hue_max) & s_norm > sat_min);
elseif strcmp(color, 'red') || strcmp(color, 'other')
    %     p = find(s_norm>30 & h_norm>230 | s_norm>30 & h_norm<11);
    p = find((h_norm > hue_min | h_norm < hue_max) & s_norm > sat_min);
end
In(p) = 1; % write found pixels

end
