function IM_normalized = cellularGPSSegment_imnormalize(IM)
    IM = double(IM);
    IM_normalized = (IM - min(IM(:))) / (max(IM(:)) - min(IM(:)));
end