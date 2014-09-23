function [myMeasurements] = cellularGPSMeasurement_totalIntensity(I,centroidTable,ISeg)
        
        mask = zeros(I);
        mask(centroids.) = validCells;
        mask = imdilate(mask, strel('disk', 15));
        measurements = regionprops(mask, YFP_background, 'MeanIntensity');
        
        measuredCells = ~isnan([measurements.MeanIntensity]);
end