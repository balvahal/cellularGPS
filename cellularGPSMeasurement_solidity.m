function [myHandle] = cellularGPSMeasurement_solidity(~)
myHandle = @subcellularGPSMeasurement_meanIntensity;
    function myMeasurement = subcellularGPSMeasurement_meanIntensity(~,~,ISeg)
        myMeasurement = regionprops(ISeg, 'Solidity');
        myMeasurement = transpose([myMeasurement.Solidity]);
    end
end