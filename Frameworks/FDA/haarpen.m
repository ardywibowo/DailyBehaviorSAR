function penaltymat = haarpen(basisobj, Lfdobj)
%FOURIERPEN computes the fourier penalty matrix for penalty LFD.
%  Arguments:
%  BASISOBJ ... a basis object
%  LFDOBJ   ... a linear differential operator object
%  Returns: 
%  PENALTYMAT ... the penalty matrix.

%  check BASIS
	
	penaltymat = inprod(basisobj, basisobj, Lfdobj, Lfdobj);
	
end