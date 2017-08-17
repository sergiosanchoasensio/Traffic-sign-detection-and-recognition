function [ C ] = decideWindow( x )
%decideWindow It decides if there is a signal in the region
% Half filling ratio: [0.432433527936620]
% Max: 0.9684
% Min: 0.2901
    Fr = nnz(x)/numel(x(:));
    C = (Fr > 0.25);% & Fr < 0.96);
end

