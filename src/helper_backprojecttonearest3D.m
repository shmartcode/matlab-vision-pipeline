function [pts3D,nearestpts3D]=helper_backprojecttonearest3D( pts2D,X,K )
% 
% This function backprojects 2D points from a render onto
% a 3D object, and retrieves nearest 3D points
% 
% Author: Natasha Kholgade Banerjee
% Date: 02/11/2015
%
n_points=size( pts2D,2 );
pts3D=nan(3,n_points);
nearestpts3D=nan(3,n_points);

for i=1:n_points
    % nearest point is going to be a vertex
    % need to project vertex onto line from origin
    % P=lambda*xhat, X-P is perpendicular to xhat
    % (lambda*xhat-X)'*xhat = 0, % lambda*(xhat'*xhat)-X'*xhat=0
    % lambda=(X'*xhat)/(xhat'*xhat);
    xhat=[pts2D(:,i);1];
    if nargin>2
        xhat=K\xhat;
    end
    lambdas=(xhat'*X)/(xhat'*xhat);
    dists=sum((xhat*lambdas-X).^2,1);
    [~,im]=min(dists);
    Xr=xhat*lambdas(im);
    pts3D(:,i)=Xr;
    nearestpts3D(:,i)=X(:,im);
end
end