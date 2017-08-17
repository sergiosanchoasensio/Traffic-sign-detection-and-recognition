function [ masks ] = grayscaleTemplates( data, maskdir )
%Group 5, Block 4, Task 1
%Create a function to create grayscale models by averaging the training
%images. Different models should be created for the different signal shapes (circle,
%rectangle, triangle, giveaway, stop).
    mask_w = 346;
    type = {'Triangle','Circle','Square','InvTriangle'};
    masks = zeros(mask_w,mask_w, length(type));
    for i = 1:length(type)
        data_signals = strcmp(data(:,14),type{i});
        data_signals = data(data_signals == 1,:);
        mask_resize = zeros(mask_w,mask_w);
        for j =1:size(data_signals,1)
            mask = double(imread(strcat(maskdir,'mask',data_signals{j,1}(3:end-3),'png')));
            mask_signal = mask(floor(data_signals{j,2})+1:floor(data_signals{j,4}),floor(data_signals{j,3})+1:floor(data_signals{j,5}));
            mask_resize = mask_resize + imresize(mask_signal,[mask_w,mask_w]);
        end
        
        masks(:,:,i) = mask_resize/size(data_signals,1);
    end
end

