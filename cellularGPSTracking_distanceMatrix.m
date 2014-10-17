%%
% Input: M and N are arrays where each row represents a datapoint and the
% number of dimensions are reflected in the number of columns.
%
%
% Output: D : is an m x n matrix where _m_ is the number of rows in M and
% _n_ is the number of rows in N.
function D = cellularGPSTracking_distanceMatrix(M,N) %#codegen
%%
% analyze inputs
[Mrows,Mcols] = size(M);
[Nrows,Ncols] = size(N);
if Mcols ~= Ncols
    error('cGPSTrackingDistMat:colDisagree','The number of columns in each input array must agree');
end
%%
%
D = zeros(Mrows,Nrows);
for i = 1:Mrows
    for j = 1:Nrows
        D(i,j) = norm(M(i,:)-N(j,:));
    end
end
end