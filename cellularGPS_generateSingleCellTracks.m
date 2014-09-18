function CentroidsTracks = generateSingleCellTracks(CentroidsTracks, distanceRadius)
    currentTrack = 0;
    for t=1:(length(CentroidsTracks.singleCells))
        [track_id, cell_id] = CentroidsTracks.getValues(t);
        while(sum(track_id == 0) > 0)
            currentTrack = currentTrack + 1;
            query_id = cell_id(find(track_id == 0, 1, 'first'));
            CentroidsTracks.setCentroid(t, query_id, CentroidsTracks.getCentroid(t,query_id), currentTrack);
            CentroidsTracks = cellularGPS_propagateTrack(CentroidsTracks, t, query_id, distanceRadius);
            [track_id, cell_id] = CentroidsTracks.getValues(t);
        end
    end
    for t=1:(length(CentroidsTracks.singleCells))
        CentroidsTemp = CentroidsTracks.getCentroids(t);
        track_assignment = CentroidsTracks.getValues(t);
        CentroidsTracks.insertCentroids(t, zeros(size(CentroidsTracks.singleCells,1),2));
        newCentroids = zeros(size(CentroidsTracks.singleCells,1),2);
        newCentroids(track_assignment,:) = CentroidsTemp;
        CentroidsTracks.insertCentroids(t, newCentroids);
        CentroidsTracks.singleCells(t).value = zeros(length(CentroidsTracks.singleCells(t).value),1);
    end
    
end