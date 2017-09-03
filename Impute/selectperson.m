function [ train,ntrain,test,ntest ] = selectperson( d,v,nv,person )
%
    vlen = d(person+1) - d(person);
    %data = v(d(person)+1:d(person)+vlen,:);
    %va = var(data(:,7));
    l_training = floor(vlen/2);
    %l_testing = vlen-l_training;
    train = v(d(person)+1:d(person)+l_training,:);
    ntrain = nv(d(person)+1:d(person)+l_training,:);
    test = v(d(person)+l_training+1:d(person)+vlen,:);
    ntest = nv(d(person)+l_training+1:d(person)+vlen,:);

end

