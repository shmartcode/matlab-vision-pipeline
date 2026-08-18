function makePan (im1, im2, title)
% Takes in two images and a title The title is what the final panorama
% will be saved as.

points1 = detectSURFFeatures(im1);
points2 = detectSURFFeatures(im2);
features1 = extractFeatures(im1, points1);
features2 = extractFeatures(im2, points2);
indexPairs = matchFeatures(features1, features2, 'Unique', true);

matchedPoints1 = points1(indexPairs(:, 1));
matchedPoints2 = points2(indexPairs(:, 2));
im1_points = matchedPoints1.Location;
im2_points = matchedPoints2.Location;

%% Initial Transformation of image 2.
A = estimateTransformRANSAC(im1_points, im2_points);
im2_transformed = transformImage(im2, A,"homography"); 
nanlocations2 = isnan(im2_transformed);
im2_transformed(nanlocations2) = 0;
%% end transformation calling code.

%% Expanding Images 1 to match the size of the transformed image %%
[new_h, new_w] = size(im2_transformed); % get heigh and width dimension we need to match from transofmed image 2
[old_h, old_w] = size(im1); % get original h/w from image 1

bottom_zeros = zeros(new_h-old_h,old_w);  % make a matrix of zeroes to expand the image1 down with       
im1_expanded = [im1; bottom_zeros]; % Combine the original image with the bottom zeros

side_zeros = zeros(new_h,new_w-old_w); % make a matrix of zeroes to expand image1 to the side (width way).
im1_expanded = [im1_expanded, side_zeros]; % Combine the expanded image with the side zeros
%% End of expansion code. %%


%% Image blending code %%
imshow(im1_expanded);
[x_overlap,y_overlap]=ginput(2);
overlapleft = round(x_overlap(1));
overlapright = round(x_overlap(2));

num_points_overlapped = overlapright - overlapleft;
stepvalue = 1 / num_points_overlapped;  % calculate our stepvalue for the ramp

zeros_till_overlapleft = zeros(1, overlapleft-1); % matrix of 0s fill the left side of the second image. ie make it not visible
ones_till_overlapright = ones(1, new_w - overlapright); % matrix of ones to fill the right side of the second image

ramp = [zeros_till_overlapleft, 0 : stepvalue : 1, ones_till_overlapright]; % the ramp the gradually makees ponts visible as you leave the zero space left of the overlap
flip_ramp = 1 - ramp; % we can the complement of ramp to get the ramp we need to apply to image 1.

im2_blend = im2_transformed .* repmat(ramp,new_h,1); % create the blended image that makes points repective to the selected overlap lines visible, not visible, or in between
im1_blend = im1_expanded .* repmat(flip_ramp,new_h,1);

impanorama = im2_blend + im1_blend;
%% End of blending %%

imshow(impanorama);

imwrite(im2_blend, "im2_blend.jpg");
imwrite(im1_blend, "im1_blend.jpg");
imwrite(im2_transformed, "im2_transformed.jpg");
imwrite(im1_expanded, "im1_expanded.jpg");
imwrite(impanorama, title);

end