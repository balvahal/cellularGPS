function [myHandle] = cellularGPSMeasurement_centroidNibble(myParameters)
nibble = strel('disk',myParameters.radius);
myHandle = @subcellularGPSMeasurement_centroidNibble;

    function myMeasurement = subcellularGPSMeasurement_centroidNibble(I,centroidTable,~)
        
        mask = false(size(I));
        mask(centroidTable.row) = true;
        mask = imdilate(mask, nibble);
        measurements = regionprops(mask, YFP_background, 'MeanIntensity');
        
        measuredCells = ~isnan([measurements.MeanIntensity]);
    end
end