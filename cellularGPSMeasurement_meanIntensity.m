function [myHandle] = cellularGPSMeasurement_meanIntensity(~)
myHandle = @subcellularGPSMeasurement_meanIntensity;
    function myMeasurement = subcellularGPSMeasurement_meanIntensity(I,~,ISeg)
        myMeasurement = regionprops(ISeg, I, 'MeanIntensity');
        myMeasurement = transpose([myMeasurement.MeanIntensity]);
    end
end