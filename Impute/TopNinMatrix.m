function [ out_seq ] = TopNinMatrix( A, TopN )
%input is any matrix
%output is Top N elements and their postions
[M,N]=size(A);

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
            out_seq = rseq(1:mark(end),:);
            %disp('m');
        else
            out_seq = rseq(1:TopN, :);
            %disp('T');
        end
    end
    


end

