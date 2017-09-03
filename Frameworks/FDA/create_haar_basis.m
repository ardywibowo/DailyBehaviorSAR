function basisobj = create_haar_basis(rangeval, nbasis)
%CREATE_SPLINE_BASIS Creates a bspline functional data basis.
%  This function is identical to BSPLINE_BASIS.
%  Arguments ...
%  RANGEVAL ... an array of length 2 containing the lower and upper
%               boundaries for the rangeval of argument values.  If a
%               single value is input, it must be positive and the lower
%               limit of the range is set to 0.
%  NBASIS   ... the number of basis functions
%  NORDER   ... order of b-splines (one higher than their degree).  The
%                 default of 4 gives cubic splines.
%  BREAKS   ... also called knots, these are a strictly increasing sequence
%               of junction points between piecewise polynomial segments.
%               They must satisfy BREAKS(1) = RANGEVAL(1) and
%               BREAKS(NBREAKS) = RANGEVAL(2), where NBREAKS is the total
%               number of BREAKS.
%  There is a potential for inconsistency among arguments NBASIS, NORDER, 
%  and BREAKS.  It is resolved as follows:
%     If BREAKS is supplied, NBREAKS = length(BREAKS), and
%     NBASIS = NBREAKS + NORDER - 2, no matter what value for NBASIS is
%     supplied.
%     If BREAKS is not supplied but NBASIS is, 
%        NBREAKS = NBASIS - NORDER + 2,
%        and if this turns out to be less than 3, an error message results.
%     If neither BREAKS nor NBASIS is supplied, NBREAKS is set to 21.
%  DROPIND ... a set of indices in 1:NBASIS of basis functions to drop
%                when basis objects are arguments.  Default is [];
%  Returns
%  BASISOBJ  ... a functional data basis object

	type = 'haar';
	params = [];
	quadvals = [];
	values = {};
	basisvalues = {};
	dropind = [];
	
	basisobj = basis(type, rangeval, nbasis, params, ...
								 dropind, quadvals, values, basisvalues);

end