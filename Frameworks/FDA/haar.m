function basismat = haar(evalarg, nbasis)
%  HAAR  Computes the NDERIV derivative of the Haar basis
%    for NBASIS functions with period PERIOD, these being evaluated
%    at values in vector EVALARG.
%  Returns an N by NBASIS matrix BASISMAT of function values

if nargin < 2
	nbasis = floor(log2(length(evalarg))+1);
end

evalarg = evalarg(:)';
waveletAmount = log2(nbasis) + 1;
basismat = recurse_haar(1, [min(evalarg) max(evalarg)], waveletAmount, evalarg);

end
