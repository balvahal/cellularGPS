function CentroidsTracks = cellularGPS_propagateTrack(CentroidsTracks, t, cell_id, distanceRadius)
    if(t == length(CentroidsTracks.singleCells))
        return;
    end
    queryCentroid = CentroidsTracks.getCentroid(t, cell_id);
    currentTrack = CentroidsTracks.getValue(t, cell_id);
    [nextCentroid, nextCell] = CentroidsTracks.getClosestCentroid(t + 1, queryCentroid, distanceRadius);
    if(~isempty(nextCell))
        [~, reciprocalCell] = CentroidsTracks.getClosestCentroid(t, nextCentroid, distanceRadius);
        if(reciprocalCell == cell_id)
            CentroidsTracks.setCentroid(t+1, nextCell, CentroidsTracks.getCentroid(t+1,nextCell), currentTrack);
            CentroidsTracks = cellularGPS_propagateTrack(CentroidsTracks, t+1, nextCell, distanceRadius);
        else
            return;
        end
    else
        return;
    end
end