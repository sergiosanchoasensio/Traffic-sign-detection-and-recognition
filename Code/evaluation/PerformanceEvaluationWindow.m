function [precision, accuracy, recall, fMeasure] = PerformanceEvaluationWindow(TP, FN, FP)
    % PerformanceEvaluationWindow
    % Function to compute different performance indicators (Precision, accuracy, 
    % sensitivity/recall) at the object level
    %
    % [precision, sensitivity, accuracy] = PerformanceEvaluationPixel(TP, FN, FP)
    %
    %    Parameter name      Value
    %    --------------      -----
    %    'TP'                Number of True  Positive objects
    %    'FN'                Number of False Negative objects
    %    'FP'                Number of False Positive objects
    %
    % The function returns the precision, accuracy and sensitivity
   
    precision = TP / (TP+FP);
    accuracy = TP / (TP+FN+FP);
    recall = TP / (FN+TP);
    fMeasure = (2*TP) / (2*TP + FP + FN);
end
