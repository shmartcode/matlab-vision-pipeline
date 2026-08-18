# matlab-vision-pipeline
Summary: Computer Vision and Image Processing project in Matlab that implements transform functions from scratch, panoramic image creation, and camera calibration.

## 📂 Project Structure

The project is organized into core reusable functions (`src/`) and standalone runner scripts (`scripts/`):
Within src this list of files/functions are the ones created by me, all others not listed here are helper functions supplied by the professor:
- scalingValues.m
- transformImage.m
- estimateTransform.m
- estimateTransformRANSAC.m
- makePan.m
- estimateCameraProjectionMatrix.m

🚀 Key Modules

    Part 1: Geometric Transformations (transforms_script.m): Custom implementation of affine and projective transformations to warp, scale, and rotate images.               
    Part 2: Panoramic Image Stitching (panorama_script.m): Feature matching, homography estimation via RANSAC, and blending multiple images into a seamless panoramic view.

    Part 3: Camera Calibration, Pose Estimation, & 3D Projection: Calibrated a pinhole camera model using chessboard patterns to compute intrinsic and extrinsic parameters, enabling accurate 3D object mesh projection onto 2D input images.


💻 How to Run

    Clone the repository and open MATLAB.

    Set your Current Folder to the root project directory (matlab-vision-pipeline).

    Open any script inside the scripts/ folder (e.g., scripts/run_part3_stitching.m) and hit Run.
    Notes: The scripts automatically add the src/ directory to the MATLAB path. You will need to add sample images to the directory and possible rename image variables in the scripts/functions.

    Note: Only a few sample input and output images have been provided to minimize repository size and adhere to storage best practices. To test the pipeline, supply your own local image directories.
    Part 1 : input takes 1 image and the script will run multiple functions to transform the image and provide multiple outputs.
    Part 2: input takes 2 images and outputs 1 panoramic image
    Part 3: input takes 1 image and outputs 1 image with the 'dalekosaur' lego mesh projected onto it.
