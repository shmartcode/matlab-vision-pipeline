function [pts3D,alphas,faces]=helper_backproject3D( pts2D,X,Faces,K )
% 
% This function backprojects 2D points from a render onto
% a 3D object, and retrieves corresponding 3D points
% 
% Author: Natasha Kholgade Banerjee
% Date: 02/11/2015
%
n_points=size( pts2D,2 );
pts3D=nan(3,n_points);
alphas=nan(3,n_points);
faces=nan(1,n_points);
for i=1:n_points
    xhat=[pts2D(:,i);1];
    if nargin>3
        xhat=K\xhat;
    end
    Xface1=X(:,Faces(:,1) );
    Xface2=X(:,Faces(:,2) );
    Xface3=X(:,Faces(:,3) );
    
    A1=Xface3-Xface1;
    A2=Xface3-Xface2;
    A3=repmat(xhat,1,size(A1,2));
    A11=A1(1,:); A12=A1(2,:); A13=A1(3,:);
    A21=A2(1,:); A22=A2(2,:); A23=A2(3,:);
    A31=A3(1,:); A32=A3(2,:); A33=A3(3,:);
    Denom=(A11.*A22.*A33 - A11.*A23.*A32 - A12.*A21.*A33 + A12.*A23.*A31 + A13.*A21.*A32 - A13.*A22.*A31);
    B=Xface3; B1=B(1,:); B2=B(2,:); B3=B(3,:);
    
    O1= (A21.*A32.*B3 - A21.*A33.*B2 - A22.*A31.*B3 + A22.*A33.*B1 + A23.*A31.*B2 - A23.*A32.*B1)./Denom;
    O2=-(A11.*A32.*B3 - A11.*A33.*B2 - A12.*A31.*B3 + A12.*A33.*B1 + A13.*A31.*B2 - A13.*A32.*B1)./Denom;
    lambda= (A11.*A22.*B3 - A11.*A23.*B2 - A12.*A21.*B3 + A12.*A23.*B1 + A13.*A21.*B2 - A13.*A22.*B1)./Denom;
    
    intersects=helper_geq( abs(Denom),0 ) & helper_geq( O1,0 ) & helper_geq( O2,0 ) & helper_leq( O1+O2,1 );
    
    if sum(intersects)~=0
        fintersects=find(intersects);
        lambdaintersects=lambda(intersects);
        O1intersects=O1(intersects);
        O2intersects=O2(intersects);
        [~,im]=min(abs(lambdaintersects));
        Xr=xhat*lambdaintersects(im);
        alphas(:,i)=[O1intersects(im);O2intersects(im);1-O1intersects(im)-O2intersects(im)];
        faces(i)=fintersects(im);
        pts3D(:,i)=Xr;
    end
end

end