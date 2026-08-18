function [sx,sy] = scalingValues(targetDim, image)
%SCALINGVALUES determines the scaling values needed based on target
%dimensions and the dimensions of the image
arguments (Input)
    targetDim
    image
end

arguments (Output)
    sx
    sy
end

[H,W] = size(image);
newH = targetDim(1);
newW = targetDim(2);
sx = newW / W;
sy = newH / H;

end