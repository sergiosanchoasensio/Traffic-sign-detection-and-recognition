% Image thresholding
% Version: 27.10.15

% 1. Read the image
signal = imread('01.002619.jpg');
[In] = normalize_segmentation(signal,'red');

%% Plot the results
figure;
subplot(221); imshow(signal); title('Original image');
subplot(222); imshow(In); title('Seg. image');