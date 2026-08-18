function [dd,bb,mbb]=helper_bbox(X)
% This function gets the bounding box of a set of 2D or 3D points, the
% length of the diagonal, and the center of the bounding box.
%
% Author: Natasha Kholgade Banerjee
% Date: 06/12/2014
%
if size(X,1)==3    
    bb=[min(X(1,:)),max(X(1,:)),min(X(2,:)),max(X(2,:)),min(X(3,:)),max(X(3,:))];
    dd=sqrt( (bb(2)-bb(1)).^2 + (bb(4)-bb(3)).^2 + (bb(6)-bb(5)).^2 );        
else
    bb=[min(X(1,:)),max(X(1,:)),min(X(2,:)),max(X(2,:))];
    dd=sqrt( (bb(2)-bb(1)).^2 + (bb(4)-bb(3)).^2 );    
end
mbb=mean(reshape(bb',2,[]))';

end