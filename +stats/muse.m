function Y=muse(X,dim)

if nargin==1
    dim=1;
end

mu=nanmean(X,dim);
se=stats.nanstderr(X,dim);

Y=[mu(:) se(:)];


