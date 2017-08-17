function [TP,FN,FP,DCO] = PerformanceAccumulationWindow(detections, annotations, dco_scoring)
    % PerformanceAccumulationWindow
    % Function to compute different performance indicators (True Positive, 
    % False Positive, False Negative) at the object level.
    %
    % Objects are defined by means of rectangular windows circumscribing them.
    % Window format is [ struct(x,y,w,h) ; struct(x,y,w,h) ; ... ] in detections and 
    % [ struct(x,y,w,h,DCO,sign) ; struct(x,y,w,h,DCO,sign) ; ... ] in annotations.
    %
    % An object is considered to be detected correctly if detection and annotation 
    % windows overlap by more of 50%
    %
    %   function [TP,FN,FP] = PerformanceAccumulationWindow(detections, annotations)
    %
    %    Parameter name      Value
    %    --------------      -----
    %    'detections'        List of windows marking the candidate detections
    %    'annotations'       List of windows with the ground truth positions of the objects
    %    'dco_scoring'       If not zero, scoring considers that annotations can be DCO's (Do not Care Objects)
    %                        Neither detecting nor missing these objects penalize the scores
    %                        If 0, all annotations are considered when computing TP, FN and FP
    %
    % The function returns the number of True Positive (TP), False Positive (FP), 
    % False Negative (FN) objects

    detectionsUsed = zeros(1,size(detections,1));
    annotationsUsed = zeros(1,size(annotations,1));
    DCO = 0;

    if dco_scoring > 0

       % Check if the DCO field is present (see LoadAnnotations.m)
       assert(isfield(annotations, 'DCO') || length(annotations) == 0, 'Error: DCO field should be present in annotions');

       % Matrix to store the overlappings between any combination of hypothesis / annotation
       score = zeros(size(annotations,1), size(detections,1));

       % Vector of DCO annotations
       isdco = false(size(annotations,1),1);

       for i=1:size(annotations,1),
           % vector marking DCO annotations
           isdco(i,1) = annotations(i).DCO;

           % Compute the Jaccard index for every combination annotation/hypothesis
           for j=1:size(detections,1),
               score(i,j) = RoiOverlapping(annotations(i), detections(j));
           end
       end

       % Count the number of DCO's
       DCO = sum(isdco);

       % For each _detection_, leave only the correspondent annotation with maximum Jaccard index 
       [msd,row] = max(score,[], 1);
       col = 1:size(detections,1);

       % Case when a detection does not match any annotation

       mark_zeros = zeros(1,length(row));
       for i=1:length(row)
           if score(row(i),col(i)) == 0
              mark_zeros(i)=1;
           end
       end       
       row(find(mark_zeros))=[];
       col(find(mark_zeros))=[];


       % Keep only the scores at the maxima positions
       maxpos = zeros (size(score));
       if size(row,1) > 0 && size(col,1) > 0
          maxpos(sub2ind(size(score), row, col)) = 1;
       end
       score = score .* maxpos;
       
       % For each _annotation_, leave only the correspondent detection with maximum Jaccard index 
       [msa,col] = max(score,[], 2);
       row = 1:size(col,1);
       row=row';

       % Keep only the scores at the maxima positions
       maxpos = zeros (size(score));
       if size(row,2) > 0 && size(col,2) > 0
          maxpos(sub2ind(size(score), row, col)) = 1;
       end
       score = score .* maxpos;

       % Consider only cases where Jaccard index is above threshold
       score = score > 0.5;

       % Annotations without any correspondent detection are False Negatives

       TP = 0;
       FN = length(annotations) - DCO;
       FP = length(detections);

       % If there is a valid matching ...
       if min(size(score)) > 0

          % 
          FN = length(find(max(score,[], 2)+isdco == 0));

          % Detections without any correspondent annotation are FP
          FP = length(find(max(score,[], 1) == 0)); 

          % Matches that are not DCO are the TP
          TP = length(find(max(score,[], 2).*(~isdco)) ~= 0);
       end
    else
        % Old scoring method, without DCOs
    TP = 0;
    for i=1:size(annotations,1),
        for j=1:size(detections,1),
            if detectionsUsed(j)==0 && RoiOverlapping(annotations(i), detections(j)) > 0.5
                TP = TP+1;
                detectionsUsed(j) = 1;
                   annotationsUsed(i) = annotationsUsed(i) + 1;
            end
        end
    end
    FN = length(find(annotationsUsed==0));
    FP = length(find(detectionsUsed==0));
end
end
