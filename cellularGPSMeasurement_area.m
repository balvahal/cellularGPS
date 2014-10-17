function [myHandle] = cellularGPSMeasurement_area(~)
myHandle = @subcellularGPSMeasurement_meanIntensity;
    function myMeasurement = subcellularGPSMeasurement_meanIntensity(~,~,ISeg)
        myMeasurement = regionprops(ISeg, 'Area');
        myMeasurement = transpose([myMeasurement.Area]);
    end
end