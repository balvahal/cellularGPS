%%
% the input should be of type uint16
function IM_normalized = cellularGPSSegment_imnormalizeUINT16(IM) %#codegen
    IM = double(IM);
    IM_normalized = (IM - min(IM(:))) / (max(IM(:)) - min(IM(:)));
end