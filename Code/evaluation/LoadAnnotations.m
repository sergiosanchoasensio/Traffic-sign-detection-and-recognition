function [annotations Signs] = LoadAnnotations(file, mask, dco_scoring)
    % LoadAnnotations
    % Load text annotations files for the M1 project
    %
    %   [annotations Signs] = LoadAnnotations(file, mask)
    %
    %    Parameter name      Value
    %    --------------      -----
    %    'file'              Annotations text file
    %    'mask'              Ground truth mask file (image) 
    %    'dco_scoring'       If not zero, scoring considers that annotations can be DCO's (Do not Care Objects)
    %                        Neither detecting nor missing these objects penalize the scores
    %                        If '1' will only consider DCOs the objects whose code does not start by a letter in the [A-F] range
    %                        If '2', objects without a valid mask are also considered DCOs.
    %                        If '0', there are no DCOs. All annotations are considered when computing TP, FN and FP
    %
    %  Each line in the annotation file contains  the coordinates of the top-left corner, the width and height of the window, plus the object type:
    %  248.850000 275.260000 289.720000 315.170000 D7
    %
    % The function returns a vector of windows (annotations) and a vector of object types (Signs)
    
    annotations = [];
    fid = fopen(file, 'r');
    BBs=[]; Signs=[];
    tline = fgetl(fid);
    while ischar(tline)
        [A,c,e,ni]=sscanf(tline,'%f %f %f %f',4);
        Ai = floor(A);
        Ai = max(Ai,[1 1 1 1]');

        sign_code = tline(ni+1:end);

        %
        % Annotations without valid mask or not in the [ABCDEF] range are considered DCOs
        %

        isDCO = false;  % Do not Care Objects (neither detecting nor missing these objects penalize the scores)
        if (dco_scoring ~= 0 && length(regexp(sign_code(1), '[ABCDEF]')) == 0)
           isDCO = true;
        end
        if (dco_scoring > 1 && sum(sum(mask(Ai(1):Ai(3),Ai(2):Ai(4)))) == 0)
           isDCO = true;
        end


        annotations = [annotations ; struct('x', A(2), 'y', A(1), 'w', A(4)-A(2), 'h', A(3)-A(1), 'DCO', isDCO, 'sign', sign_code)];
        Signs=[Signs {sign_code}];

        %  Show the annotations in the range [A..F] without valid mask
        %  NOTE: Mask is not used in the window based evaluation 
        if (sum(sum(mask(Ai(1):Ai(3),Ai(2):Ai(4)))) == 0)
           if (regexp(sign_code(1), '[ABCDEF]') == 1)
               sprintf('%s : %s', file, tline(ni+1:end))
           end
        end
        tline = fgetl(fid);
    end
    fclose(fid);
end
