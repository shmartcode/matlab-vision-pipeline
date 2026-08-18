addpath(fullfile('src'))

im1 = imread('image1.jpg');
im1 = im2double(im1);
im1 = im2gray(im1);

im2 = imread('image2.jpg');
im2 = im2double(im2);
im2 = im2gray(im2);

im3 = imread("cliffleft.jpg");
im3 = im2double(im3);
im3 = im2gray(im3);

im4 = imread("cliffright.jpg");
im4 = im2double(im4);
im4 = im2gray(im4);

im5 = imread("closebridgeleft.jpg");
im5 = im2double(im5);
im5 = im2gray(im5);

im6 = imread("closebridgeright.jpg");
im6 = im2double(im6);
im6 = im2gray(im6);


makePan(im1, im2, "Professor_images_pana.jpg");

makePan(im3, im4, "CliffPana.jpg");

makePan(im5, im6, "BridgePana.jpg");