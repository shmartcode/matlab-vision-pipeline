function A = estimateTransform( p, pp )
% p for points which is image points 1
% pp for points prime which is image points 2


% TODO: 
% Set up design matrix P
% P is of size 2N x 9
% P = [-x -y -1 0 0 0 x*xprime y*xprime xprime
%      0 0 0 -x -y -1 x*yprime y*yprime yprime
% ... (populate 2N such rows)

N = length(p);
P = zeros(2*N,9);

for i=1 : N

    x = p(i,1);
    xp = pp(i,1);
    y = p(i,2);
    yp = pp(i,2);
    
    corr_top = [-x -y -1 0 0 0 xp*x xp*y xp];
    corr_bot = [0 0 0 -x -y -1 yp*x yp*y yp];

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
% Reshape q properly to form A
% The reshape is NOT simply A = reshape(q,3,3)
A = reshape(q,3,3)'; % transpose result so first rows are a,b,c etc rather than a,d,g

end