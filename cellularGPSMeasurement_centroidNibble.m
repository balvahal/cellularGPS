function [myHandle] = cellularGPSMeasurement_centroidNibble(myParameters)
nibble = strel('disk',myParameters.radius);
nibble = getnhood(nibble);
nibble = nibble/(sum(sum(nibble)));
myHandle = @subcellularGPSMeasurement_centroidNibble;
    function myMeasurement = subcellularGPSMeasurement_centroidNibble(I,centroidTable,~)
        IFilter = imfilter(double(I),nibble,'replicate');
        %ind = sub2ind(size(I),centroidTable.centroid_row,centroidTable.centroid_col);
        %myMeasurement = IFilter(ind);
        myMeasurement = IFilter(centroidTable);
    end
end