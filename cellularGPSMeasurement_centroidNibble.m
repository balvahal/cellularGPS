function [myHandle] = cellularGPSMeasurement_centroidNibble(myParameters)
nibble = strel('disk',myParameters.radius);
myHandle = @subcellularGPSMeasurement_centroidNibble;

    function myMeasurement = subcellularGPSMeasurement_centroidNibble(I,centroidTable,~)
        mask = false(size(I));
        ind = sub2ind(size(I),centroidTable.centroid_row,centroidTable.centroid_col);
        mask(ind) = true;
        mask = imdilate(mask, nibble);
        myMeasurement = regionprops(mask, I, 'MeanIntensity');
        myMeasurement = transpose([myMeasurement.MeanIntensity]);
    end
end