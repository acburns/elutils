function [p,D]=bootlda(A,B,varargin)
% [p,D]=bootsigmoid(A,B,varargin)
% Takes two sets of data A and B with D columms and calculated fisher's linear
% discriminant and measures the roc between the data points in group A and B projected onto the LDA.
% Then we permute the rows of A and B to generate permuted data sets and
% perform roc on the permuated. Finally, the distance
% between A and B fits are compared to the distribution of distances
% generated by permuting A and B.


BOOTS=10000;

overridedefaults(who,varargin);

n_A=size(A,1);
n_B=size(B,1);


vAB=flda(A,B);

[aucv,aucp]=bootroc(A*vAB, B*vAB);

permAB=nan(BOOTS,1);

M=[A;B];

for bx=1:BOOTS
    
    rperm=randperm(n_A+n_B);
    rA=M(rperm(1:n_A),:);
    rB=M(rperm((n_A+1):end),:);
   
    rvAB=flda(rA,rB);
    
    permAB(bx)=auc(rA*rvAB,rB*rvAB);
    
end

p=get_p(aucv,permAB);

D.ld=vAB;
D.bootp=p;
D.aucv=aucv;
D.aucp=aucp;
D.permAB=permAB;
