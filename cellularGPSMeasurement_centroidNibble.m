function [myHandle] = cellularGPSMeasurement_centroidNibble(myParameters)
nibble = strel('disk',myParameters.radius);
myHandle = @subcellularGPSMeasurement_centroidNibble;
    function myMeasurement = subcellularGPSMeasurement_centroidNibble(I,centroidTable,Iseg)
        mask = false(size(I));
        ind = sub2ind(size(I),centroidTable.centroid_row,centroidTable.centroid_col);
        mask(ind) = true;
        mask = imdilate(mask, nibble);
        myMeasurement = regionprops(mask, I, 'MeanIntensity','Centroid');
        myMeasurement = transpose([myMeasurement.MeanIntensity]);
        %%%
        % make sure the measurements line up with the original centroid
        % values
        Iseg2 = bwlabel(Iseg);
        myMeasurement2 = regionprops(mask,Iseg2,'PixelValues');
        myMeasurement3 = transpose(cellfun(@median,{myMeasurement2.PixelValues}));
        myMeasurement = myMeasurement(myMeasurement3);
    end
end