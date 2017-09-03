% Function to compute the SFPCA solution
% L1 sparse penalties
% Nested selection of reg params via the BIC cirtierion
% Inputs:
% x				: n x p data matrix 
% K				: # of factors to extract
% lamus		: vector of sparsity parameters to consider for u
% lamvs		: vector of sparsity parameters to consider for v
% alphaus : vector of smoothness parameters to consider for u
% alphavs : vector of smoothness parameters to consider for v
% Omegu		: n x n positive semi-definite matrix for roughness penalty on u
% Omegv		: p x p positive semi-definite matrix for roughness penalty on v
% startu	: n x K matrix of starting values for U;  if startu=0, then
%						algorithm initialized to the rank-one SVD solution
% startv	: p x K matrix of starting values for V;  if startv=0, then
%						algorithm initialized to the rank-one SVD solution
% posu		: non-negativity indicator - posu = 1 imposes non-negative
%						constraints on u, posu = 0 otherwise
% posv		: non-negativity indicator - posv = 1 imposes non-negative
%						constraints on v, posv = 0 otherwise
% maxit		: maximum number of alternating regressions steps
% iterS		: number of iterations where nested evaluation of the BIC
%						criterion should be performed.  Setting iterS = 5 is typically
%						sufficient.
% Outputs:
% U			 : n x K left SFPCs
% V			 : p x K right SFPCs
% d			 : a K vector of associated singular values
% optaus : K vector of alphau parameters selected via the BIC criterion
% optavs : K vector of alphav parameters selected via the BIC criterion
% optlus : K vector of lamu parameters selected via the BIC criterion
% optlvs : K vector of lamv parameters selected via the BIC criterion
% Xhat	 : the deflated residual matrix
% bicu	 : final matrix of computed BIC values for u
% bicv	 : final matrix of computed BIC values for v

function[U,V,d,optaus,optavs,optlus,optlvs,Xhat,bicu,bicv] = sfpca_nested_bic(x,K,lamus,lamvs,alphaus,alphavs,Omegu,Omegv,startu,startv,posu,posv,maxit,iterS)
[n,p] = size(x);
ru = length(alphaus); rv = length(alphavs); 
rlu = length(lamus); rlv = length(lamvs); 
Lu = max(eig(speye(n)+n*max(alphaus)*Omegu)) + .01;
Lv = max(eig(speye(p)+p*max(alphavs)*Omegv)) + .01;
lamus = sort(lamus,'descend');
lamvs = sort(lamvs,'descend');
optaus = []; optavs = []; optlus = []; optlvs = [];
Xhat = x; 
for k=1:K
    bicu = zeros(ru,rlu); bicv = zeros(rv,rlv);
    if sum(startu)==0
        [u,dtmp,v] = svds(Xhat,1);
    else
        u = startu(:,k); v = startv(:,k);    
    end
    indo = 1; iter = 1; thr = 1e-6;
    while indo>thr & iter<min([iterS maxit])
        oldu = u; oldv = v;

        us = zeros(n,ru,rlu);
        for j=1:ru
            Su = speye(n) + alphaus(j)*n*Omegu;
            for i=1:rlu
                indiu = 1;
                while indiu>thr
                    oldui = us(:,j,i);
                    utild = us(:,j,i) + (Xhat*v - Su*us(:,j,i))/Lu;
                    us(:,j,i) = soft_thr(utild,lamus(i)/Lu,posu);
                    if norm(us(:,j,i))>0
                        us(:,j,i)  = us(:,j,i)/sqrt(us(:,j,i)'*Su*us(:,j,i));
                    else
                        us(:,j,i) = zeros(n,1);
                    end            
                    indiu = norm(us(:,j,i) - oldui)/norm(oldui);
                end
                actu = us(:,j,i)~=0;
                dfu = trace(inv( speye(sum(actu)) + n*alphaus(j)*Omegu(actu,actu)));
                bicu(j,i) = log( norm(Xhat*v - utild)^2/n ) + .5*log(n)*dfu/n;
            end
        end
        iu = bicu==min(min(bicu));
        [indau,indlu] = ind2sub([ru rlu],find(iu==1));
        optlu = lamus(indlu); optau = alphaus(indau);
        u = us(:,indau,indlu);
    
        vs = zeros(p,rv,rlv);
        for j=1:rv
            Sv = speye(p) + alphavs(j)*p*Omegv;
            for i=1:rlv
                indiv = 1;
                while indiv>thr
                    oldvi = vs(:,j,i);
                    vtild = vs(:,j,i) + (Xhat'*u - Sv*vs(:,j,i))/Lv;
                    vs(:,j,i) = soft_thr(vtild,lamvs(i)/Lv,posv);
                    if norm(vs(:,j,i))>0
                        vs(:,j,i)  = vs(:,j,i)/sqrt(vs(:,j,i)'*Sv*vs(:,j,i));
                    else
                        vs(:,j,i) = zeros(p,1);
                    end            
                    indiv = norm(vs(:,j,i) - oldvi)/norm(oldvi);
                end
                actv = vs(:,j,i)~=0;
                dfv = trace(inv( speye(sum(actv)) + p*alphavs(j)*Omegv(actv,actv)));
                bicv(j,i) = log( norm(Xhat'*u - vtild)^2/p ) + .5*log(p)*dfv/p;
            end
        end
        iv = bicv==min(min(bicv));
        [indav,indlv] = ind2sub([rv rlv],find(iv==1));
        optlv = lamvs(indlv); optav = alphavs(indav);
        v = vs(:,indav,indlv);
        
        iter = iter + 1;
        indo = norm(u - oldu)/norm(oldu) + norm(v- oldv)/norm(oldv);
    end
    clear vs; clear us;
    Su = speye(n) + n*optau*Omegu;
    Sv = speye(p) + p*optav*Omegv;
    while indo>thr & iter<maxit
        oldu = u; oldv = v;
        indiu = 1;
        while indiu>thr
            oldui = u;
            utild = u + (Xhat*v - Su*u)/Lu;
            u = soft_thr(utild,optlu/Lu,posu);
            if norm(u)>0
                u  = u/sqrt(u'*Su*u);
            else
                u = zeros(n,1);
            end            
            indiu = norm(u - oldui)/norm(oldui);
        end
        indiv = 1;
        while indiv>thr
            oldvi = v;
            vtild = v + (Xhat'*u - Sv*v)/Lv;
            v = soft_thr(vtild,optlv/Lv,posv);
            if norm(v)>0
                v  = v/sqrt(v'*Sv*v);
            else
                v = zeros(p,1);
            end            
            indiv = norm(v - oldvi)/norm(oldvi);
        end
        indo = norm(oldu - u)/norm(oldu) + norm(oldv - v)/norm(oldv);
        iter = iter + 1;
    end
    u = u/norm(u);
    v = v/norm(v);
    dd = u'*Xhat*v;
    Xhat = Xhat - dd*u*v';
    U(:,k) = u; V(:,k) = v; d(k) = dd;
    optavs(k) = optav; optlvs(k) = optlv;
    optaus(k) = optau; optlus(k) = optlu;
end

function[u] = soft_thr(a,lam,pos)
if pos==0
    u = sign(a).*max(abs(a) - lam,0);
else 
    u = max(a - lam,0);
end


    

