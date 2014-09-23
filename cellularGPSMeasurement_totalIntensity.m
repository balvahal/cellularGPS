function [myHandle] = cellularGPSMeasurement_totalIntensity(~)
myHandle = @subcellularGPSMeasurement_totalIntensity;
    function myMeasurement = subcellularGPSMeasurement_totalIntensity(I,~,ISeg)
        myMeasurement = regionprops(ISeg, I, 'PixelValue');
        myMeasurement = transpose(struct2cell(myMeasurement));
        myMeasurement = cellfun(@sum,myMeasurement);
    end
end