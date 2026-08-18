addpath(fullfile('src'))

% Script to setup matrices and call the functions necessary for the
% assignment transformations 1-7.

% read all images and convert them to doubles and to grayscale
im1 = imread('image1.png');
im1 = im2double(im1);
im1 = im2gray(im1);

im2 = imread('image2.png');
im2 = im2double(im2);
im2 = im2gray(im2);

im3 = imread('image3.png');
im3 = im2double(im3);
im3 = im2gray(im3);

% 2.1 scaling images to 1080x1920
scaledDims = [1080,1920];

[sx,sy] = scalingValues(scaledDims,im1);
scaleM = [sx,0,0;0,sy,0;0,0,1];
TransformedImage1 = transformImage(im1,scaleM,'scaling');
imwrite(TransformedImage1,"image1_2.1.jpeg");

[sx,sy] = scalingValues(scaledDims,im2);
scaleM = [sx,0,0;0,sy,0;0,0,1];
TransformedImage2 = transformImage(im2,scaleM,'scaling');
imwrite(TransformedImage2,"image2_2.1.jpeg");

[sx,sy] = scalingValues(scaledDims,im3);
scaleM = [sx,0,0;0,sy,0;0,0,1];
TransformedImage3 = transformImage(im3,scaleM,'scaling');
imwrite(TransformedImage3,"image3_2.1.jpeg");

% 2.2 Reflecting in the y direction
reflectyM = [1,0,0;0,-1,0;0,0,1];
TransformedImage1_reflected = transformImage(im1, reflectyM, 'reflection');
TransformedImage2_reflected = transformImage(im2, reflectyM, 'reflection');
TransformedImage3_reflected = transformImage(im3, reflectyM, 'reflection');
imwrite(TransformedImage1_reflected,"image1_2.2.jpeg");
imwrite(TransformedImage2_reflected,"image2_2.2.jpeg");
imwrite(TransformedImage3_reflected,"image3_2.2.jpeg");

% 2.3 rotate the image clockwise 30 degrees
rotationAngle = 30; % angle in degrees
rotationM = [cosd(rotationAngle), -sind(rotationAngle), 0; sind(rotationAngle), cosd(rotationAngle), 0; 0, 0, 1];
TransformedImage1_rotated = transformImage(im1, rotationM, 'rotation');
TransformedImage2_rotated = transformImage(im2, rotationM, 'rotation');
TransformedImage3_rotated = transformImage(im3, rotationM, 'rotation');
imwrite(TransformedImage1_rotated, "image1_2.3.jpeg");
imwrite(TransformedImage2_rotated, "image2_2.3.jpeg");
imwrite(TransformedImage2_rotated, "image2_2.3.jpeg");

% 2.4 shear the iamge in x direction so amount added to each x value is 0.5
% times the y
shearM = [1,.5,0;0,1,0;0,0,1];
TransformedImage1_sheared = transformImage(im1, shearM, 'shear');
TransformedImage2_sheared = transformImage(im2, shearM, 'shear');
TransformedImage3_sheared = transformImage(im3, shearM, 'shear');
imwrite(TransformedImage1_sheared,"image1_2.4.jpeg");
imwrite(TransformedImage2_sheared,"image2_2.4.jpeg");
imwrite(TransformedImage3_sheared,"image3_2.4.jpeg");

% 2.5 translate by 300 in x, 500 in y, then rotate counterclockwise 20
% degrees, then scale to half size. note: apply transforming image once
[h,w] = size(im1);

translateM = [1, 0, 300; 0, 1, 500; 0, 0, 1];
rotAngle = -20; % counterclockwise rotation
rotation20M = [cosd(rotAngle), -sind(rotAngle), 0; sind(rotAngle), cosd(rotAngle), 0; 0, 0, 1];
halfscaleM = [0.5, 0, 0; 0, 0.5, 0; 0, 0, 1];

% create the composition matrix by multiplying 
finalM = halfscaleM * rotation20M * translateM;

translateRotateScale_image1 = transformImage(im1,finalM,'affine');
translateRotateScale_image2 = transformImage(im2,finalM,'affine');
translateRotateScale_image3 = transformImage(im3,finalM,'affine');
imwrite(translateRotateScale_image1,"image1_2.5.jpeg");
imwrite(translateRotateScale_image2,"image2_2.5.jpeg");
imwrite(translateRotateScale_image3,"image3_2.5.jpeg");

% 2.6 affine transforms
affineM1 = [1, .4, .4 ; .1, 1, .3 ; 0 , 0, 1];
affineM2 = [2.1, -.35, -.1 ; -.3, .7, .3 ; 0, 0, 1];

TransformedAffine1Image1 = transformImage(im1,affineM1, 'affine');
TransformedAffine1Image2 = transformImage(im2,affineM1, 'affine');
TransformedAffine1Image3 = transformImage(im3,affineM1, 'affine');
imwrite(TransformedAffine1Image1, "image1_2.6.1.jpeg");
imwrite(TransformedAffine1Image2, "image2_2.6.1.jpeg");
imwrite(TransformedAffine1Image3, "image3_2.6.1.jpeg");

TransformedAffine2Image1 = transformImage(im1,affineM2, 'affine');
TransformedAffine2Image2 = transformImage(im2,affineM2, 'affine');
TransformedAffine2Image3 = transformImage(im3,affineM2, 'affine');
imwrite(TransformedAffine2Image1, "image1_2.6.2.jpeg");
imwrite(TransformedAffine2Image2, "image2_2.6.2.jpeg");
imwrite(TransformedAffine2Image3, "image3_2.6.2.jpeg");

% 2.7 homography transforms
homM1 = [.8, .2, .3 ; -.1, .9, -.1 ; .0005, -.0005, 1];
homM2 = [29.25, 13.95, 20.25 ; 4.95, 35.55, 9.45 ; .045, .09, 45];

TransformedHomM1Image1 = transformImage(im1,homM1,'homography');
TransformedHomM1Image2 = transformImage(im2,homM1,'homography');
TransformedHomM1Image3 = transformImage(im3,homM1,'homography');
imwrite(TransformedHomM1Image1, "image1_2.7.1.jpeg");
imwrite(TransformedHomM1Image2, "image2_2.7.1.jpeg");
imwrite(TransformedHomM1Image3, "image3_2.7.1.jpeg");


TransformedHomM2Image1 = transformImage(im1,homM2,'homography');
TransformedHomM2Image2 = transformImage(im2,homM2,'homography');
TransformedHomM2Image3 = transformImage(im3,homM2,'homography');
imwrite(TransformedHomM2Image1, "image1_2.7.2.jpeg");
imwrite(TransformedHomM2Image2, "image2_2.7.2.jpeg");
imwrite(TransformedHomM2Image3, "image3_2.7.2.jpeg");