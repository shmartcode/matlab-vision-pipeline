function keep=isinfront( X,Faces )
%
% Given a mesh of 3D points with faces connecting them,
% this function provides the points that are in front, i.e., that face the
% camera. Call as
%
% pointsInFront=isinfront( X,Faces );
%
% Inputs:
%   X:      set of 3D points (3 x N)
%   Faces:  set of faces connecting the points (N_faces x 3)
% Output:
%   pointsInFront: 1 x N vector with 'true' for points seen by the camera,
%                  and false otherwise.
%  camera is expected to be at 0 with rotation identity.
%
% Author: Natasha Kholgade Banerjee
% Date: 10/16/2015
if size(X,2)==3
    X=X';
end
n_points=size(X,2);
keep=true(1,n_points);
for i=1:n_points
    fprintf('%d/%d...',i,n_points);
    if mod(i,10)==0
        fprintf('\n');
    end
    Xface1=X(:,Faces(:,1) );
    Xface2=X(:,Faces(:,2) );
    Xface3=X(:,Faces(:,3) );
    
    A1=Xface3-Xface1;
    A2=Xface3-Xface2;
    A3=repmat(X(:,i),1,size(A1,2));
    A11=A1(1,:); A12=A1(2,:); A13=A1(3,:);
    A21=A2(1,:); A22=A2(2,:); A23=A2(3,:);
    A31=A3(1,:); A32=A3(2,:); A33=A3(3,:);
    Denom=(A11.*A22.*A33 - A11.*A23.*A32 - A12.*A21.*A33 + A12.*A23.*A31 + A13.*A21.*A32 - A13.*A22.*A31);
    B=Xface3; B1=B(1,:); B2=B(2,:); B3=B(3,:);
    
    O1= (A21.*A32.*B3 - A21.*A33.*B2 - A22.*A31.*B3 + A22.*A33.*B1 + A23.*A31.*B2 - A23.*A32.*B1)./Denom;
    O2=-(A11.*A32.*B3 - A11.*A33.*B2 - A12.*A31.*B3 + A12.*A33.*B1 + A13.*A31.*B2 - A13.*A32.*B1)./Denom;
    lambda= (A11.*A22.*B3 - A11.*A23.*B2 - A12.*A21.*B3 + A12.*A23.*B1 + A13.*A21.*B2 - A13.*A22.*B1)./Denom;
    
    intersects=helper_geq( abs(Denom),0 ) & helper_geq( O1,0 ) & helper_geq( O2,0 ) & helper_leq( O1+O2,1 ) &...
        helper_geq( lambda,0 );
    
    if sum(intersects)~=0
        lambdaintersects=lambda(intersects);
        keep(i)=abs(min(lambdaintersects)-1)<1e-6;
    end
end
fprintf('\n');

end