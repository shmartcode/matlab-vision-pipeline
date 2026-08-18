addpath(fullfile('src'))

InputImage = imread("lego.jpg");    % read input lego image in
load dalekosaur/object.mat % load variables for the dalekosaur model

% view 3d model of the dalekosaur
figure; hold on;
patch('vertices', Xo', 'faces', Faces, 'facecolor', 'w', 'edgecolor', 'k');
axis vis3d;
axis equal;
xlabel('Xo-axis'); ylabel('Yo-axis'); zlabel('Zo-axis');

ObjectDirectory = 'dalekosaur';
[impoints, objpoints3D] = clickPoints( InputImage, ObjectDirectory );
%[impoints, objpoints3D] = Copy_of_clickPoints( InputImage, ObjectDirectory );

% click all the points

figure;
imshow(InputImage); hold on;
plot( impoints(:,1), impoints(:,2), 'b.','MarkerSize', 15); % plot clicked points onto the lego image. Added marker size 15 for larger points in jpg.

figure; hold on;
patch('vertices', Xo', 'faces', Faces, 'facecolor', 'w', 'edgecolor', 'k'); % show lego mesh in figure
axis vis3d;
axis equal;
plot3( objpoints3D(:,1), objpoints3D(:,2), objpoints3D(:,3), 'b.', 'MarkerSize', 15); % plot clicked points on lego mesh figure. Added marker size 15 for larger points in jpg.


% Section 1.2

% Basically the same function as assignment 2's estimating transforms. With
% adjustments made for adding the Z dimension
M = estimateCameraProjectionMatrix(impoints, objpoints3D);


% Section 1.3

% we know that M can be separated into A and b. we know that C is obtained
% from A times A transposed.
A = M(1:3,1:3);
b = M(1:3,4);
C = A*A';
K = zeros(3);

% Lambda and lambda squared
lambda = 1/sqrt(C(3,3));
lambda2 = 1/C(3,3);

% We obtain our xc, yc, fy,fx, and alpha by using our upper right triangles values/equations KK^T = lambda^2 * C^T 
xc = lambda2 * C(1,3);
yc = lambda2 * C(2,3);
fy = sqrt((lambda^2)*C(2,2)-yc^2);
alpha = (1/fy)*(lambda2 * C(1,2) - xc*yc);
fx = sqrt(lambda2*C(1,1) - alpha^2 - xc^2);

% After solving we can fill in K.
K(1,1) = fx;
K(1,2) = alpha;
K(1,3) = xc;
K(2,2) = fy;
K(2,3) = yc;
K(3,3) = 1;


% Check the value of R using positive and negative lambda. keep value that
% makes det(R) positive
R1 = lambda * K^-1 * A;
R2 = -lambda * K^-1 * A;
if det(R1) > 0
    R = R1;
elseif det(R2) > 0
    R = R2;
    lambda = -lambda;
end

t = lambda * K^-1 * b;


% Section 1.4

% Making objpoints3D homogeneous
N = size(objpoints3D, 1);
X = [objpoints3D, ones(N,1)];

% Get the estimated points by applying M to X. need to transpose X to make
% it a long vector, apply transformation with M, and then transpose back to
% get coords layout
x_proj = (M*X')';
imgpoints2D_estim = x_proj(:,1:2) ./ x_proj(:,3); % normalize by dividing by last row
figure(1)
plot(imgpoints2D_estim(:,1), imgpoints2D_estim(:,2), 'ro')  % estimated (red circles)

% sum squared error
% Calculate the sum of squared distance between the estimated and actual image points
squaredErrors = sum((imgpoints2D_estim - impoints).^2,2);
ssd = sum(squaredErrors);
disp(['Total Sum of Squared Distance: ', num2str(ssd)]);

% mean squared error
meanSquaredDistance = ssd / N;
disp(['Mean Squared Distance ', num2str(meanSquaredDistance)]);
disp(['Mean Distance ', num2str(sqrt(meanSquaredDistance))]);

% 2D mesh from 3D
% make homogeneous. then project. then normalize
mesh2dHom = [Xo; ones(1,size(Xo,2))];
mesh2d = M * mesh2dHom;
mesh2d = mesh2d(1:2,:) ./ mesh2d(3,:);

% visualize on image.
figure;
imshow(InputImage); hold on; % 'hold on' holds the image to draw more content
% Added edgealpha value of 0.2 to make edges partially transparent,
% allowing more underyling lego color to show through.
patch('vertices', mesh2d', 'faces', Faces, 'facecolor', 'n', 'edgecolor', 'b', 'edgealpha', .2); 


% SECTION 2. Camera Calibration. 

% Focal length (fc) - usually in pixels
fc = cameraParams.FocalLength;  % Returns [fx, fy]

% Principal point / camera center (cc)
cc = cameraParams.PrincipalPoint;  % Returns [cx, cy]

% OR get the full intrinsic matrix K
K_checker = cameraParams.IntrinsicMatrix';

alpha_c = K_checker(2,2);



% SECTION 3 IMAGE 1 FRONT PORCH 

im1 = imread("frontporch.jpg");    % read in image 1, the front porch

% no transforms. only original lego mesh inserted
mesh2dHom = [Xo; ones(1,size(Xo,2))];
mesh2d = M * mesh2dHom;
mesh2d = mesh2d(1:2,:) ./ mesh2d(3,:);

figure(Name = "orig");
imshow(im1); hold on; % 'hold on' holds the image to draw more content
patch('vertices', mesh2d', 'faces', Faces, 'facecolor', 'n', 'edgecolor', 'b');


% PORCH FIRST INSERT

thetx = -19; % rotation in degrees
Rotx = [1 0 0 ; 0 cosd(thetx) -sind(thetx) ; 0 sind(thetx) cosd(thetx)]; % basic rotation matrix x axis
thety = 30;
Roty = [cosd(thety) 0 sind(thety); 0 1 0; -sind(thety) 0 cosd(thety)]; % basic rotation matrix for y axis
thetz = 10; % rotation in degrees
Rotz = [cosd(thetz) -sind(thetz) 0; sind(thetz) cosd(thetz) 0; 0 0 1]; % basic rotation matrix for z axis

X_transformed = Rotx * Roty * Rotz * Xo; % rotate the object (object coords)
X_transformed = R * X_transformed + t; % transforming to camera coords (transforming to camera coords with R and t
cam_t = [1.3; -.8; 3]; % translation matrix for use in camera coords
X_transformed = X_transformed + cam_t; % translating image in camera coords

% USING K 
mesh2dHom =  K* X_transformed;
mesh2d = mesh2dHom(1:2,:) ./ mesh2dHom(3,:);

% project
title = num2str("K:"+ thetx + "," + thety + "," + thetz);
figure(Name = title);
imshow(im1); hold on;
patch('vertices', mesh2d', 'faces', Faces, 'facecolor', 'n', 'edgecolor', 'b');

% Using K_checker from the matlab calibration tool
mesh2dHom =  K_checker* X_transformed;
mesh2d = mesh2dHom(1:2,:) ./ mesh2dHom(3,:);

title = num2str("K_checker:"+ thetx + "," + thety + "," + thetz);
figure(Name = title);
imshow(im1); hold on;
patch('vertices', mesh2d', 'faces', Faces, 'facecolor', 'n', 'edgecolor', 'b');


% PORCH SECOND INSERT

thetx = -200; % rotation in degrees
Rotx = [1 0 0 ; 0 cosd(thetx) -sind(thetx) ; 0 sind(thetx) cosd(thetx)]; % basic rotation matrix x axis
thety = -25;
Roty = [cosd(thety) 0 sind(thety); 0 1 0; -sind(thety) 0 cosd(thety)]; % basic rotation matrix for y axis
thetz = -8; % rotation in degrees
Rotz = [cosd(thetz) -sind(thetz) 0; sind(thetz) cosd(thetz) 0; 0 0 1]; % basic rotation matrix for z axis

X_transformed = Rotx * Roty * Rotz * Xo; % rotate and scale to half size (object coords)
X_transformed = R * X_transformed + t; % transforming to camera coords (transforming to camera coords with R and t
cam_t = [.9; -6.5 ; 5.5]; % translation matrix for use in camera coords
X_transformed = X_transformed + cam_t; % translating image in camera coords

% USING K 
mesh2dHom =  K* X_transformed;
mesh2d = mesh2dHom(1:2,:) ./ mesh2dHom(3,:);

% project
title = num2str("K:"+ thetx + "," + thety + "," + thetz);
figure(Name = title);
imshow(im1); hold on;
patch('vertices', mesh2d', 'faces', Faces, 'facecolor', 'n', 'edgecolor', 'b');


% Using K_checker from the matlab calibration tool
mesh2dHom =  K_checker* X_transformed;
mesh2d = mesh2dHom(1:2,:) ./ mesh2dHom(3,:);

title = num2str("K_checker:"+ thetx + "," + thety + "," + thetz);
figure(Name = title);
imshow(im1); hold on;
patch('vertices', mesh2d', 'faces', Faces, 'facecolor', 'n', 'edgecolor', 'b');


% PORCH THIRD INSERT

thetx = 0; % rotation in degrees
Rotx = [1 0 0 ; 0 cosd(thetx) -sind(thetx) ; 0 sind(thetx) cosd(thetx)]; % basic rotation matrix x axis
thety = -54;
Roty = [cosd(thety) 0 sind(thety); 0 1 0; -sind(thety) 0 cosd(thety)]; % basic rotation matrix for y axis
thetz = 5; % rotation in degrees
Rotz = [cosd(thetz) -sind(thetz) 0; sind(thetz) cosd(thetz) 0; 0 0 1]; % basic rotation matrix for z axis

X_transformed = Rotx * Roty * Rotz * Xo; % rotate and scale to half size (object coords)
X_transformed = R * X_transformed + t; % transforming to camera coords (transforming to camera coords with R and t
cam_t = [7; 11 ; 55]; % translation matrix for use in camera coords
X_transformed = X_transformed + cam_t; % translating image in camera coords

% USING K 
mesh2dHom =  K* X_transformed;
mesh2d = mesh2dHom(1:2,:) ./ mesh2dHom(3,:);

% project
title = num2str("K:"+ thetx + "," + thety + "," + thetz);
figure(Name = title);
imshow(im1); hold on;
patch('vertices', mesh2d', 'faces', Faces, 'facecolor', 'n', 'edgecolor', 'b');


% Using K_checker from the matlab calibration tool
mesh2dHom =  K_checker* X_transformed;
mesh2d = mesh2dHom(1:2,:) ./ mesh2dHom(3,:);

title = num2str("K_checker:"+ thetx + "," + thety + "," + thetz);
figure(Name = title);
imshow(im1); hold on;
patch('vertices', mesh2d', 'faces', Faces, 'facecolor', 'n', 'edgecolor', 'b');




% SECTION 3 IMAGE 2 PLAYSET/SLIDE

im2 = imread("slide.jpg");    % read in image 2, the slide set.

% no transforms. only original lego mesh inserted
mesh2dHom = [Xo; ones(1,size(Xo,2))];
mesh2d = M * mesh2dHom;
mesh2d = mesh2d(1:2,:) ./ mesh2d(3,:);

figure(Name = "orig");
imshow(im2); hold on; % 'hold on' holds the image to draw more content
patch('vertices', mesh2d', 'faces', Faces, 'facecolor', 'n', 'edgecolor', 'b');


% PLAYSET FIRST INSERT

thetx = -10; % rotation in degrees
Rotx = [1 0 0 ; 0 cosd(thetx) -sind(thetx) ; 0 sind(thetx) cosd(thetx)]; % basic rotation matrix x axis
thety = -120;
Roty = [cosd(thety) 0 sind(thety); 0 1 0; -sind(thety) 0 cosd(thety)]; % basic rotation matrix for y axis
thetz = -10; % rotation in degrees
Rotz = [cosd(thetz) -sind(thetz) 0; sind(thetz) cosd(thetz) 0; 0 0 1]; % basic rotation matrix for z axis

X_transformed = Rotx * Roty * Rotz * Xo; % rotate and scale to half size (object coords)
X_transformed = R * X_transformed + t; % transforming to camera coords (transforming to camera coords with R and t
cam_t = [40; -11; 84]; % translation matrix for use in camera coords
X_transformed = X_transformed + cam_t; % translating image in camera coords

% USING K 
mesh2dHom =  K* X_transformed;
mesh2d = mesh2dHom(1:2,:) ./ mesh2dHom(3,:);

% project
title = num2str("K:"+ thetx + "," + thety + "," + thetz);
figure(Name = title);
imshow(im2); hold on;
patch('vertices', mesh2d', 'faces', Faces, 'facecolor', 'n', 'edgecolor', 'b');

% Using K_checker from the matlab calibration tool
mesh2dHom =  K_checker* X_transformed;
mesh2d = mesh2dHom(1:2,:) ./ mesh2dHom(3,:);

title = num2str("K_checker:"+ thetx + "," + thety + "," + thetz);
figure(Name = title);
imshow(im2); hold on;
patch('vertices', mesh2d', 'faces', Faces, 'facecolor', 'n', 'edgecolor', 'b');


% PLAYSET SECOND INSERT

thetx = 10; % rotation in degrees
Rotx = [1 0 0 ; 0 cosd(thetx) -sind(thetx) ; 0 sind(thetx) cosd(thetx)]; % basic rotation matrix x axis
thety = -70;
Roty = [cosd(thety) 0 sind(thety); 0 1 0; -sind(thety) 0 cosd(thety)]; % basic rotation matrix for y axis
thetz = 0; % rotation in degrees
Rotz = [cosd(thetz) -sind(thetz) 0; sind(thetz) cosd(thetz) 0; 0 0 1]; % basic rotation matrix for z axis

X_transformed = Rotx * Roty * Rotz * Xo; % rotate and scale to half size (object coords)
X_transformed = R * X_transformed + t; % transforming to camera coords (transforming to camera coords with R and t
cam_t = [4.6; 4 ; 9]; % translation matrix for use in camera coords
X_transformed = X_transformed + cam_t; % translating image in camera coords

% USING K 
mesh2dHom =  K* X_transformed;
mesh2d = mesh2dHom(1:2,:) ./ mesh2dHom(3,:);

% project
title = num2str("K:"+ thetx + "," + thety + "," + thetz);
figure(Name = title);
imshow(im2); hold on;
patch('vertices', mesh2d', 'faces', Faces, 'facecolor', 'n', 'edgecolor', 'b');


% Using K_checker from the matlab calibration tool
mesh2dHom =  K_checker* X_transformed;
mesh2d = mesh2dHom(1:2,:) ./ mesh2dHom(3,:);

title = num2str("K_checker:"+ thetx + "," + thety + "," + thetz);
figure(Name = title);
imshow(im2); hold on;
patch('vertices', mesh2d', 'faces', Faces, 'facecolor', 'n', 'edgecolor', 'b');


% PLAYSET THIRD INSERT

thetx = -5; % rotation in degrees
Rotx = [1 0 0 ; 0 cosd(thetx) -sind(thetx) ; 0 sind(thetx) cosd(thetx)]; % basic rotation matrix x axis
thety = 20;
Roty = [cosd(thety) 0 sind(thety); 0 1 0; -sind(thety) 0 cosd(thety)]; % basic rotation matrix for y axis
thetz = -2; % rotation in degrees
Rotz = [cosd(thetz) -sind(thetz) 0; sind(thetz) cosd(thetz) 0; 0 0 1]; % basic rotation matrix for z axis

X_transformed = Rotx * Roty * Rotz * Xo; % rotate and scale to half size (object coords)
X_transformed = R * X_transformed + t; % transforming to camera coords (transforming to camera coords with R and t
cam_t = [-36; -41 ; 90]; % translation matrix for use in camera coords
X_transformed = X_transformed + cam_t; % translating image in camera coords

% USING K 
mesh2dHom =  K* X_transformed;
mesh2d = mesh2dHom(1:2,:) ./ mesh2dHom(3,:);

% project
title = num2str("K:"+ thetx + "," + thety + "," + thetz);
figure(Name = title);
imshow(im2); hold on;
patch('vertices', mesh2d', 'faces', Faces, 'facecolor', 'n', 'edgecolor', 'b');


% Using K_checker from the matlab calibration tool
mesh2dHom =  K_checker* X_transformed;
mesh2d = mesh2dHom(1:2,:) ./ mesh2dHom(3,:);

title = num2str("K_checker:"+ thetx + "," + thety + "," + thetz);
figure(Name = title);
imshow(im2); hold on;
patch('vertices', mesh2d', 'faces', Faces, 'facecolor', 'n', 'edgecolor', 'b');