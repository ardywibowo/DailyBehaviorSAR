function [outputSequence] = TopNinMatrix(A, TopN)
%TOPNINMATRIX Finds the top N values in matrix.
% [outputSequence] = TopNinMatrix(A, TopN)
%
% Inputs:
% A    : Input matrix
% TopN : The number of values to find (N)
%
% Outputs:
% outputSequence : A sorted matrix with each row having 3 elements:
% the top value, the row index, and column index of the top value

[M, N] = size(A);

CAr = round(linspace(1,M,M));
CAc = round(linspace(1,N,N));
MAr = repmat(CAr',1,N);
MAc = repmat(CAc,M,1);
MapRow = MAr(:);
MapCol = MAc(:);

InA(:,1) = A(:);
InA(:,2) = MapRow;
InA(:,3) = MapCol;

seq=sortrows(InA,1);
rseq=seq(end:-1:1,:);
mark = find(rseq(:,1)>0);
if ~isempty(mark)
	if TopN >= mark(end)
		outputSequence = rseq(1:mark(end),:);
		%disp('m');
	else
		outputSequence = rseq(1:TopN, :);
		%disp('T');
	end
else
	outputSequence = [];
end

end

