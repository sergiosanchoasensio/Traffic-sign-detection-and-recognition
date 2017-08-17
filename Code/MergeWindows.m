function [windowCandidates] = MergeWindows(C)
        s = regionprops(C,'centroid');
        centroids = cat(1, s.Centroid);
        windowCandidates = [];
        for i = 1:length(centroids)
            x = centroids(i,1)-45;
            y = centroids(i,2)-45;
            windowCandidates = [windowCandidates; struct('x',double(x),'y',double(y),'w',double(91),'h',double(91)) ];        
        end
end

