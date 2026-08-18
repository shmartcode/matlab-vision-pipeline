function M = estimateCameraProjectionMatrix( impoints2D,objpoints3D )

p = impoints2D;
pp = objpoints3D ;
N = length(impoints2D);
P = zeros(2*N,12);

for i=1 : N

    x = p(i,1);
    y = p(i,2);
    xp = pp(i,1); % Xo
    yp = pp(i,2); % Yo
    zp = pp(i,3); % Zo

    % corr_top = [-x -y -z -1 0 0 0 0 xp*x xp*y xp];
    % corr_bot = [0 0 0 -x -y -1 yp*x yp*y yp];

    % Mirroring assignment two but adding another dimension for Z
    corr_top = [-xp -yp -zp -1 0 0 0 0 xp*x yp*x x*zp x];
    corr_bot = [0 0 0 0 -xp -yp -zp -1 xp*y yp*y zp*y y];

    P(2*i-1, :) = corr_top;
    P(2*i, :) = corr_bot;
end


% Assuming your design matrix is set up...
if size(P,1) < size(P,2)
    [~,~,V] = svd(P);
else
    [~,~,V] = svd(P,'econ');
end

q = V(:,end);

% TODO: 
% Reshape q properly to form M
% The reshape is NOT simply A = reshape(q,3,4)
M = reshape(q,4,3)'; % transpose result so first rows are a,b,c etc rather than a,d,g

end