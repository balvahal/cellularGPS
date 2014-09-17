function LAPmatrix = cellularGPS_particleLinking(centroids, t0, t1, distanceCutoff)
[~, particles0] = centroids.getCentroids(t0);
[~, particles1] = centroids.getCentroids(t1);
LAPmatrix = Inf * ones(length(particles0) + length(particles1));
for i=1:length(particles0)
    currentCentroid = centroids.getCentroid(t0, particles0(i));
    [~, particlesInRange, distance] = centroids.getCentroidsInRange(t1, currentCentroid, distanceCutoff);
    if(~isempty(particlesInRange))
        LAPmatrix(i,particlesInRange) = distance;
        LAPmatrix(i,length(particles1) + i - 1) = max(distance) * 1.05;
    else
        LAPmatrix(i,length(particles1) + i - 1) = 0;
    end
end
for j=1:length(particles1)
    validDistances = LAPmatrix(~isinf(LAPmatrix(:,j)),j);
    if(~isempty(validDistances))
        LAPmatrix(length(particles0) + j - 1,j) = max(validDistances) * 1.05;
    else
        LAPmatrix(length(particles0) + j - 1,j) = 0;
    end
end
end