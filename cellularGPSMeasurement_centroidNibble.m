function [myMeasurements] = cellularGPSMeasurement_centroidNibble(I,centroids,ISeg)
        
        mask = zeros(I);
        mask(centroids.) = validCells;
        mask = imdilate(mask, strel('disk', 15));
        measurements = regionprops(mask, YFP_background, 'MeanIntensity');
        
        measuredCells = ~isnan([measurements.MeanIntensity]);
end