clc,clear;

directory = 'DataSetDelivered/train/gt'; %Path of your dataset

files = ListFilesTXT(directory);

j=1;
data = cell(size(files,1),14); %Information signals all images
for i=1:size(files,1),
    
    fileID = fopen(strcat(directory,'/',files(i).name),'r');%Open the file
    tline = fgetl(fileID); %Takes the first line
    while ischar(tline)
        read = strread(tline,'%s')'; %Reads the first line
        data{j,1}=files(i).name;
        for m = 1:4;
            data{j,m+1}=strread(read{m},'%f'); %coord y1 x1 y2 x2
        end
        data{j,6}=(data{j,4}-data{j,2})*(data{j,5}-data{j,3}); %Area (px^2)
        data{j,7}=(data{j,4}-data{j,2})/(data{j,5}-data{j,3}); %Form ratio
        data{j,9}=strcat(read{5:size(read,2)}); %Name signal
        data{j,10}=data{j,9}(1); %First Letter Signal
        data{j,11}=data{j,4}-data{j,2}; %w
        data{j,12}=data{j,5}-data{j,3}; %h
        %Type of signal
        if(~strcmp(data{j,9}(1),'A') && ~strcmp(data{j,9}(1),'B') && ...
                ~strcmp(data{j,9}(1),'C') && ~strcmp(data{j,9}(1),'D') &&...
                ~strcmp(data{j,9}(1),'E') && ~strcmp(data{j,9}(1),'F'))
            data{j,13} = 'Other';
            data{j,14} = 'Other';
        else
            if strcmp(data{j,9},'B21') == 1 || ...
                    strcmp(data{j,9}(1:1),'D') == 1 || ...
                    strcmp(data{j,9}(1:2),'E9') == 1 || ...
                    strcmp(data{j,9}(1:1),'F') == 1
                data{j,13}='Blue';
            else
                data{j,13}='Red';
            end
            if strcmp(data{j,9},'B21') == 1 || ...
                    strcmp(data{j,9}(1:2),'E9') == 1 || ...
                    strcmp(data{j,9}(1:1),'F') == 1
                data{j,14}='Square';
            elseif strcmp(data{j,9}(1:1),'A') == 1 || ...
                    strcmp(data{j,9},'B17') == 1
                
                data{j,14}='Triangle';
            else if(strcmp(data{j,9}(1:2),'B1') == 1 || strcmp(data{j,9}(1:2),'B3') == 1)
                    data{j,14}='InvTriangle';
                else
                    data{j,14}='Circle';
                end
            end
        end
        j=j+1;
        tline = fgetl(fileID);
    end
    fclose(fileID);
    
end

name = 'Primero';
for i=1:size(data,1);
    %Open or not a new file
    if ~strcmp(data{i,1}, name);
        I = imread(strcat('DataSetDelivered/train/mask/mask.',data{i,1}(4:end-3),'png'));
    end
    
    crop = imcrop(I, [floor(data{i,3}) ceil(data{i,2}) floor(data{i,11}) ceil(data{i,12})]);
    data{i,8} = nnz(crop)/(size(crop,1) * size(crop,2)); %Filling ratio
    
    name = data{i,1};
end

%Collect all of the information

type_signals = ['A', 'B', 'C', 'D', 'E','F'];
%maximum & minimum
signal = zeros(6,9); %Filas 'ABCDEF', Columnas 'max h, max w, min h, min w, max form, min form, max fillr, min fillr, freq'
num_others = sum(strcmp(data(:,13),'Other'));

for i = 1:size(signal,1)
    data_signals = strcmp(data(:,10),type_signals(i));
    data_signals = data(data_signals == 1,:);
    [val, ind] = max(cell2mat(data_signals(:,6)));
    signal(i,1) = data_signals{ind,12}; %max h
    signal(i,2) = data_signals{ind,11}; %max w
    [val, ind] = min(cell2mat(data_signals(:,6)));
    signal(i,3) = data_signals{ind,12}; %max h
    signal(i,4) = data_signals{ind,11}; %max w
    [val, ind] = max(cell2mat(data_signals(:,7)));
    signal(i,5) = data_signals{ind,7}; %form max
    [val, ind] = min(cell2mat(data_signals(:,7)));
    signal(i,6) = data_signals{ind,7}; %form min
    [val, ind] = max(cell2mat(data_signals(:,8)));
    signal(i,7) = data_signals{ind,8}; %filling max
    [val, ind] = min(cell2mat(data_signals(:,8)));
    signal(i,8) = data_signals{ind,8}; %filling min
    signal(i,9) = size(data_signals,1)/(size(data,1)-num_others); %form min
end

save('dataset','data');
save('datasignal','signal');