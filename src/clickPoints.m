function [impoints2D,objpoints3D]=clickPoints( im,objdir )
%
% Use this function to obtain correspondences between the image
% and the object
%
% Call the function as follows:
%
%   [impoints2D,objpoints3D]=clickPoints( imagename,objectdirectory );
%
% Inputs:
%   imagename:       Name of the image with the full path.
%   objectdirectory: Name of the directory containing object files
%                    (.obj, .mtl, mayarenders directory etc.). Should
%                    include full path.
% Outputs:
%   impoints2D:      N x 2 array of points on the image.
%   objpoints3D:     N x 3 array of points on the object.
%
% Alternatively, you can provide an image that you have read in
%
%   [impoints2D,objpoints3D]=clickPoints( I,objectdirectory );
%
%   I: image (either W x H grayscale or W x H x 3 color is fine).
%
% Example:
%   [impoints2D,objpoints3D]=clickPoints('image.jpg','dalekosaur');
%
% Another example:
%   I=imread('image.jpg');
%   [impoints2D,objpoints3D]=clickPoints(I,'dalekosaur');
%
% Author: Natasha Kholgade Banerjee
% Date: 09/12/2015

% If a name has been provided instead of the image,
% read in the image
if ischar(im)
    im=imread(im);
end

% get the list of multiview renders for showing the object
renderdir=[objdir,'/mayarenders/'];
renderlist=dir([renderdir,'/*.jpg']);

% read in the render from the standard viewpoint
i_standard=length(renderlist)/2;
renderidx=i_standard;
renname=renderlist(i_standard).name;
rennamefull=[renderdir,renname];
ren=imread(rennamefull);
num_el_ip_az=sscanf(renname,'out_%02d_%02d_%03d.jpg');
num_el=num_el_ip_az(1);
num_az=num_el_ip_az(3);

% Create a fingure window
figure; set(gcf,'WindowStyle','docked');

% Show the image, and the render from the standard viewpoint
subplot(1,2,1); imshow(im,'border','tight');
subplot(1,2,2); imshow(ren,'border','tight');

% The following code allows the user to provide 'u=up', 'd=down', 'l=left',
% and 'r=right' as commands to turn the object around and see alternate
% viewpoints. The code works by taking in 'u', 'd', 'l', or 'r' as
% keyboard inputs, and loading in a rendered image corresponding to the
% next view in the chosen direction. The user can quit the selection of
% view by pressing 'n'.
done=false;
prompt='Press a combination of ''u'', ''d'', ''l'' and ''r'' followed by enter to select nearest view,\nor ''n'' followed by enter to end view selection.\n';
startprompt=[prompt,'As an example, you can press ''ddrrr'' followed by enter to go down by two steps and to the right by three steps.\n'];
startprompt=[startprompt,'Or you can just press ''l'' followed by enter to go to the left by one step.\n'];

starting=true;
while ~done
    if starting
        keys=input(startprompt,'s');
    else
        keys=input(prompt,'s');
    end
    if isempty(keys)
        doturn=false;
    else
        doturn=true;
        for j=1:length(keys)
            if keys(j)~='u' && keys(j)~='d' && keys(j)~='l' && keys(j)~='r'
                doturn=false;
            end
            if ~doturn
                break;
            end
        end
    end    
    if doturn
        done=false;
        for j=1:length(keys)
            k=keys(j);
            if k(1)=='u'
                % if 'u' is pressed, elevate the object upwards
                num_el=num_el-1;
                if num_el<0
                    num_el=0;
                end
            elseif k(1)=='d'
                % if 'd' is pressed, lower the object downwards
                num_el=num_el+1;
                if num_el>12
                    num_el=12;
                end
            elseif k(1)=='r'
                % if 'r' is pressed, turn the object to the right
                % (i.e., next to the right in azimuth)
                num_az=num_az+1;
                if num_az==36
                    num_az=0;
                end
            elseif k(1)=='l'
                % if 'l' is pressed, turn the object to the left
                % (i.e., next to the right in elevation)
                num_az=num_az-1;
                if num_az==-1
                    num_az=35;
                end
            end
        end
        
        % load in the corresponding render and show it
        renname=sprintf('out_%02d_%02d_%03d.jpg',num_el,1,num_az);
        for renderidx=1:length(renderlist)
            if strcmp(renname,renderlist(renderidx).name)
                break;
            end
        end
        rennamefull=[renderdir,renname];
        ren=imread(rennamefull);
        imshow(ren,'border','tight');
    elseif ~isempty(keys) && keys(1)=='n'
        % End the view selection process if 'n' is pressed
        done=true;
    else
        % Any other key should just return the prompt without doing anything
        fprintf('Woops, wrong key combination\n');
    end
end

% Create placeholder arrays for the points on the image, and the
% points on the object
impoints2D=zeros(2,100);
objpoints3D=zeros(3,100);

% The following few lines read in the 3D model and transform it
% according to the render of the nearest view selected by the user
Transforms=dlmread([objdir,'/transforms.txt']);
T=reshape( Transforms( renderidx,: )',4,4 );

modelname=[objdir,'/object.mat'];
load( modelname,'Xo','Faces' );
Xtransf=T(1:3,:)*[Xo;ones(1,size(Xo,2))];

imageheight=size(ren,1);
imagewidth=imageheight;
mayacamaperture=1; mayacamfocallength=35;
f=mayacamfocallength*imageheight/(mayacamaperture*25.4);
Kren=[f,0,imagewidth/2;0,f,imageheight/2;0,0,1];

% The first point should be marked in the image. Use ginput() to get the
% first point, and plot it back on the image using plot()
fprintf('Now mark 6 or more correspondences in the image and on the object.\nFirst click one point in the image on left...\n');
subplot(1,2,1);
[x11,y11]=ginput(1);
impoints2D(:,1)=[x11;y11];
mymarkersize=7;
hold on; plot(x11,y11,'o','markersize',mymarkersize,'markerfacecolor','b','markeredgecolor','n');

% The second point should be marked on the object. Use ginput() to get the
% second point, and plot it back on the render of the object using plot()
fprintf('Now click one point on the object on the right...\n');
subplot(1,2,2);
[x21,y21]=ginput(1);
x3D=helper_backproject3D([x21;y21],Xtransf,Faces,Kren);
if isnan(x3D(1))
    [~,x3D]=helper_backprojecttonearest3D([x21;y21],Xtransf,Kren);
end
objpoints3D(:,1)=x3D;
x2D=Kren*x3D; x2D=x2D/x2D(end);
hold on; plot(x2D(1),x2D(2),'o','markersize',mymarkersize,'markerfacecolor','b','markeredgecolor','n');

% The loop in the next few lines of code get in additional points for both the image
% and the object, by using ginput(), checking if left click is used, and
% augmenting impoints2D during odd iterations and objpoints3D during even
% iterations. If left click is not used (i.e., b~=1), the loop quits.
fprintf('Continue in this manner, and do a right click to end\n');
done=false;
isleftimage=true;
count=1;
while ~done
    if isleftimage
        subplot(1,2,1);
    else
        subplot(1,2,2);
    end
    [x,y,b]=ginput(1);
    done=b~=1;
    if b==1
        if isleftimage
            plot(x,y,'o','markersize',mymarkersize,'markerfacecolor','b','markeredgecolor','n');
            impoints2D(:,count+1)=[x;y];
        else
            x3D=helper_backproject3D([x;y],Xtransf,Faces,Kren);
            if isnan(x3D(1))
                [~,x3D]=helper_backprojecttonearest3D([x;y],Xtransf,Kren);
            end
            objpoints3D(:,count+1)=x3D;            
            x2D=Kren*x3D; x2D=x2D/x2D(end);
            plot(x2D(1),x2D(2),'o','markersize',mymarkersize,'markerfacecolor','b','markeredgecolor','n');
            
        end
        if ~isleftimage
            count=count+1;
        end
        isleftimage=~isleftimage;
    end
end

% Truncate impoints2D and renpoints3D to contain only as many points as the
% user clicked
impoints2D(:,count+1:end)=[];
objpoints3D(:,count+1:end)=[];

% objpoints3D=helper_backproject3D(renpoints2D,Xtransf,Faces,Kren);
% nans=isnan(objpoints3D(1,:));
% objpoints3D(:,nans)=helper_backprojecttonearest3D(renpoints2D(:,nans),Xtransf,Kren);

impoints2D=impoints2D';
objpoints3D=T\[objpoints3D;ones(1,size(objpoints3D,2))];
objpoints3D=objpoints3D(1:3,:)';