function TrafficSignDetection(directory, pixel_method, th, filename, window_method, decision_method, str, str2)
    % TrafficSignDetection
    % Perform detection of Traffic signs on images. Detection is performed first at the pixel level
    % using a color segmentation. Then, using the color segmentation as a basis, the most likely window 
    % candidates to contain a traffic sign are selected using basic features (form factor, filling factor). 
    % Finally, a decision is taken on these windows using geometric heuristics (Hough) or template matching.
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
    global CANONICAL_W;        CANONICAL_W = 64;
    global CANONICAL_H;        CANONICAL_H = 64;
    global SW_STRIDEX;         SW_STRIDEX = 8;
    global SW_STRIDEY;         SW_STRIDEY = 8;
    global SW_CANONICALW;      SW_CANONICALW = 32;
    global SW_ASPECTRATIO;     SW_ASPECTRATIO = 1;
    global SW_MINS;            SW_MINS = 1;
    global SW_MAXS;            SW_MAXS = 2.5;
    global SW_STRIDES;         SW_STRIDES = 1.2;


    % Load models
    global circleTemplate;
    global givewayTemplate;   
    %global stopTemplate;      
    global rectangleTemplate; 
    global triangleTemplate;  
    
    %if strcmp(decision_method, 'TemplateMatching')
       load('Templates/TemplateCircles.mat');
       circleTemplate = TemplateCircles;
       load('Templates/TemplateGiveways.mat');
       givewayTemplate = TemplateGiveways;
       %stopTemplate      = load('Templates/TemplateStops.mat');
       load('Templates/TemplateRectangles.mat');
       rectangleTemplate = TemplateRectangles;
       load('Templates/TemplateTriangles.mat');
       triangleTemplate = TemplateTriangles;
    %end

    windowTP=0; windowFN=0; windowFP=0; windowDCO=0; % (Needed after Week 3)
    pixelTP=0; pixelFN=0; pixelFP=0; pixelTN=0;
    
    files = ListFiles(directory);
    tic;
    for i=1:size(files,1),
    %for i=23:23,
        
        % Read file
        im = imread(strcat(directory,'/',files(i).name));
        
        % Candidate Generation (pixel) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        pixelCandidates = CandidateGenerationPixel_Color(im, pixel_method, th);
        
        % Morphological Operations  %%%%%%%%%%%%%%%%%%%%%%%%%%%
%         pixelCandidates = imopen(imclose(pixelCandidates,str),str2);
        pixelCandidates = imfill(pixelCandidates,'holes');
%         subplot(1,2,1);
%         imshow(im);
%         subplot(1,2,2);
%         imshow(pixelCandidates*255);
        % Candidate Generation (window)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       windowCandidates = CandidateGenerationWindow(im, pixelCandidates, window_method, decision_method);

        % Accumulate pixel performance of the current image %%%%%%%%%%%%%%%%%
        disp(i);

        pixelAnnotation = imread(strcat(directory, '/mask/mask.', files(i).name(1:size(files(i).name,2)-3), 'png'))>0;

        %To delete every pixel which are not in the window
        mask = zeros(size(pixelAnnotation));
        for k = 1:size(windowCandidates,1)
            x1 = round(windowCandidates(k).x);
            y1 = round(windowCandidates(k).y);
            x2 = floor(windowCandidates(k).x+windowCandidates(k).w);
            y2 = floor(windowCandidates(k).y+windowCandidates(k).h);
            mask(y1:y2, x1:x2) = 1;
        end
        pixelAnnotation(~mask) = 0; 
        
        
        
        [localPixelTP, localPixelFP, localPixelFN, localPixelTN] = PerformanceAccumulationPixel(pixelCandidates, pixelAnnotation);
        pixelTP = pixelTP + localPixelTP;
        pixelFP = pixelFP + localPixelFP;
        pixelFN = pixelFN + localPixelFN;
        pixelTN = pixelTN + localPixelTN;
        
        %Accumulate object performance of the current image %%%%%%%%%%%%%%%%  (Needed after Week 3)
        windowAnnotations = LoadAnnotations(strcat(directory, '/gt/gt.', files(i).name(1:size(files(i).name,2)-3), 'txt'), pixelAnnotation, 1);
        [localWindowTP, localWindowFN, localWindowFP, localDCO] = PerformanceAccumulationWindow(windowCandidates, windowAnnotations, 1);
        windowTP = windowTP + localWindowTP;
        windowFN = windowFN + localWindowFN;
        windowFP = windowFP + localWindowFP;
        windowDCO = windowDCO + localDCO;
    end
    time = toc;
    time = time/size(files,1);
    
    % Plot performance evaluation
    [pixelPrecision, pixelAccuracy, pixelRecall, pixelFMeasure] = PerformanceEvaluationPixel(pixelTP, pixelFP, pixelFN, pixelTN);
    [windowPrecision, windowAccuracy, windowRecall, windowFMeasure] = PerformanceEvaluationWindow(windowTP, windowFN, windowFP);
    
    
    % Save performance to file
    f = [pixelPrecision, pixelAccuracy, pixelRecall, pixelFMeasure, pixelTP, pixelFP, pixelFN, time];
    fid=fopen(filename,'a');
    fprintf(fid,'%2.5f %2.5f %2.5f %2.5f %2.0f %2.0f %2.0f %2.5f \n', f);
    %fclose(fid);
    
    f = [windowPrecision, windowAccuracy, windowRecall, windowFMeasure, windowTP, windowFP, windowFN, time];
    %fid=fopen(filename,'a');
    fprintf(fid,'%2.5f %2.5f %2.5f %2.5f %2.0f %2.0f %2.0f %2.5f \n', f);
    fclose(fid);
    
    
    
    % [windowPrecision, windowAccuracy]
    
    
    
    %profile report
    %profile off
    % toc
end
 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CandidateGeneration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [pixelCandidates] = CandidateGenerationPixel_Color(im, method, ~)
    switch method
        case 'col_enh'
            im= double(im);
            xR=im(:,:,1);
            xG=im(:,:,2);
            xB=im(:,:,3);   
            fR_1=max(0,min(xR-xG,xR-xB)./(xR+xG+xB));
            fR_2=max(0,min(xB-xG,xB-xR)./(xR+xG+xB));
            fR_1 = fR_1 > 0.12;
            fR_2 = fR_2 > 0.12;
            pixelCandidates = fR_1 + fR_2;
        case 'ihls'
            [In1] = normalize_segmentation(im,'red');
            [In2] = normalize_segmentation(im,'blue');
            pixelCandidates = logical(In1 + In2);
    otherwise
            error('Incorrect window method defined');
    end
end    
    
function [windowCandidates] = CandidateGenerationWindow(im, pixelCandidates, window_method, decision_method)
    switch window_method
        case 'SegmentationCCL'
            %1. Connected components detection
        %1.1 Obtain the connected components and their number of pixels.
        [connected_components, num] = bwlabel(pixelCandidates, 8);
        %Generate the bounding box
        bb = regionprops(connected_components, 'BoundingBox');

        %5. For each bounding box...
        candidates = [];
        numberOfCandidates = 1;
        windowCandidates = [];
        for indexBoundingBoxes=1:size(bb)
            %5.1 Obtain the properties (for each bounding box)
            crop = imcrop(pixelCandidates, bb(indexBoundingBoxes).BoundingBox);

            %Obtain the BB values.
            x = bb(indexBoundingBoxes).BoundingBox(1);
            y = bb(indexBoundingBoxes).BoundingBox(2);
            temp_w = bb(indexBoundingBoxes).BoundingBox(3);
            temp_h = bb(indexBoundingBoxes).BoundingBox(4);
            temp_fillingRatio = nnz(crop)/(size(crop,1) * size(crop,2));

            %Store the candidates
            if temp_fillingRatio >= 0.2901 && temp_fillingRatio <= 0.9866
                if temp_w >= 29.75 && temp_w <= 345.76
                    if temp_h >= 29.46 && temp_h <= 253.39
                        window = imcrop(pixelCandidates, [double(x) double(y) double(temp_w) double(temp_h)]);
                        if DecideCandidatesWindow(window, decision_method) 
                            candidates(numberOfCandidates) = indexBoundingBoxes;
                            numberOfCandidates = numberOfCandidates + 1;
                            windowCandidates = [windowCandidates; struct('x',double(x),'y',double(y),'w',double(temp_w),'h',double(temp_h))];   
                        end
                    end
                end
            end
        end
   
        case 'SlidingWindow'
            m = 91;
            n = 91;
            fun = @decideWindow;
            C = nlfilter(pixelCandidates, [m n], fun);
            windowCandidates = MergeWindows(pixelCandidates, C, decision_method);
            
            
        otherwise
            error('Incorrect window method defined');
    end
end  

function [windowCandidates] = MergeWindows(pixelCandidates, C, decision_method)
        s = regionprops(C,'centroid');
        centroids = cat(1, s.Centroid);
        windowCandidates = [];
        % Size of the sliding window, if dynamic then we should not
        % hardcode it 
        w = 91;
        h = 91;
        for i = 1:size(centroids,1)
            %x = centroids(i,1)-4*45;
            %y = centroids(i,2)-4*45;
            x = centroids(i,1)-45;
            y = centroids(i,2)-45;
            window = imcrop(pixelCandidates, [double(x) double(y) double(w) double(h)]);
            if DecideCandidatesWindow(window, decision_method) 
                windowCandidates = [windowCandidates; struct('x',double(x),'y',double(y),'w',double(w),'h',double(h))]; 
            end
        end
end

%B4 Task 2
function [IsCandidate] = DecideCandidatesWindow(candidate, decision_method)
% %%This function decides if a window contains a traffic signal or not by
% using different template comparing methods 
% candidate: the window, in a struct form, that needs evaluation
% decision_method: the decision method we are going to use
% IsCandidate: 1 if it contains a signal, 0 if not
    IsCandidate = 0;
    % PLACEHOLDER VALUES
    % FOR EACH TEMPLATE, THE ADECUATE THRESHOLD AND THE SIZE OF THE MATRIX
    global circleTemplate;
    global givewayTemplate;   
    global stopTemplate;      
    global rectangleTemplate; 
    global triangleTemplate; 
    
    %thresholds = [30000 30000 30000 30000 30000];
    nTemplates = 5;
    switch decision_method
        case 'grayscale'
            templates = cat(3,circleTemplate,givewayTemplate,stopTemplate,rectangleTemplate,triangleTemplate);
            % Simple grayscale substraction
            % For every template:
            i = 1;
            while i < nTemplates && (IsCandidate == 0)
                % n and m is the size of our template
                testing = imresize(candidate,[size(templates(:,:,i),1) size(templates(:,:,i),2)] );
                testing = templates(:,:,i) - testing;
                IsCandidate = (sum(sum(testing)) < 50); % < thresholds(i));
                i = i + 1;
            end
                  
        case 'chamfer'
            % Chamfer distance model of each set
            type = cat(3,triangleTemplate,circleTemplate,rectangleTemplate,givewayTemplate); 
            candidate = imresize(candidate,[size(type,1),size(type,2)]);
            i = 1;
            %M = inf;
            IsCandidate = 0;
            while(IsCandidate == 0 && i <= size(type,3))
                T = edge(type(:,:,i),'canny');
                B = edge(candidate,'canny'); %MASK
                D = bwdist(B);
                M = sum(sum(T*D));
                i = i + 1;
                IsCandidate = (M < 15000000);
            end    
            
        case 'corr'
            type = cat(3,triangleTemplate,circleTemplate,rectangleTemplate,givewayTemplate); 
            candidate = imresize(candidate,[size(type,1),size(type,2)]);
            i = 1;
            IsCandidate = 0;
            while(IsCandidate == 0 & i <= size(type,3))
                C=corr2(double(candidate),type(:,:,i));
                i = i + 1;
                IsCandidate = (C > 0.38);
            end    
            
        case 'HoughTransform'
        IsCandidate = 0;
        eIm = edge(candidate, 'canny');
        [H,theta,rho] = hough(eIm);
        maxLines = 10;
        P = houghpeaks(H,maxLines,'threshold',ceil(0.7*max(H(:))));
        if(P == 0)
            IsCandidate = 0;
            disp('P=0')
        else
            lines = houghlines(eIm,theta,rho,P,'FillGap',5,'MinLength',3);
            
            %Shape detection
            
            if (length(P) == maxLines) %(circen(1) < 100 && circen(2) < 100)
                if(size(candidate)>32)
                    %Hough Circle Transform
                    [accum, circen] = CircularHough_Grd(255*candidate,[0.45*min(size(candidate,1),size(candidate,2)) 0.5*min(size(candidate,1),size(candidate,2))]);
                    if(isempty(circen))
                        IsCandidate = 0;
                    else
                        IsCandidate = 1;
                    end                    
                else
                IsCandidate = 1;
                end
            else
                tolerance = 7;
                squarecondition = 0;
                trianglecondition = 0;
                for index = 1:size(lines,2)
                    %If there are a min. of three peaks with ~0? or ~90?. Obj: square.
                    if (abs(lines(index).theta) <= tolerance) ...
                            || (abs(abs(lines(index).theta) - 90) <= tolerance)
                        squarecondition = squarecondition + 1;
                    end
                    %If there are a min. of two peaks with ~25?. Obj: triangle.
                    if (abs(abs(lines(index).theta) - 30) <= tolerance)
                        trianglecondition = trianglecondition + 1;
                    end
                end
                if squarecondition > 3
                    IsCandidate = 1;
                else
                    if trianglecondition >= 2
                        IsCandidate = 1;
                    end
                end
            end
        end
        otherwise
            error('Incorrect decision method defined');
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Performance Evaluation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PerformanceEvaluationROC(scores, labels, thresholdRange)
    % PerformanceEvaluationROC
    %  ROC Curve with precision and accuracy
    
    roc = [];
	for t=thresholdRange,
        TP=0;
        FP=0;
        for i=1:size(scores,1),
            if scores(i) > t    % scored positive
                if labels(i)==1 % labeled positive
                    TP=TP+1;
                else            % labeled negative
                    FP=FP+1;
                end
            else                % scored negative
                if labels(i)==1 % labeled positive
                    FN = FN+1;
                else            % labeled negative
                    TN = TN+1;
                end
            end
        end
        
        precision = TP / (TP+FP+FN+TN);
        accuracy = TP / (TP+FN+FP);
        
        roc = [roc ; precision accuracy];
    end

    plot(roc);
end

