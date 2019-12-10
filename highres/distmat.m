function [d, a] = distmat (p1, p2);% Compute squared distance matrix and energies.% Copyright (c) 2006-2009. Kevin C. McGill and others.% Part of EMGlab version 1.0.% This work is licensed under the Aladdin free public license.% For copying permissions see license.txt.% email: emglab@emglab.net	if nargin==1;		[l, n] = size(p1);		x = p1'*p1;		a = diag(x);		d = repmat (a, 1, n);		d = d + d' - 2*x;% + diag(inf*ones(n,1));	else		x = p2' * p1;		[l, n] = size(x);		a = diag(p2'*p2);		d = repmat (a, 1, n);		d = d + repmat (diag(p1'*p1)', l, 1);		d = d - 2*x;	end;	