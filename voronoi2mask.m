
function [mask,border] = voronoi2mask(x,y,szImg)
%
% voronoi2mask Convert Voronoi cells to region mask
%
%   mask = voronoi2mask(x,y,szImg) computes a mask of the Voronoi cells
%   given points,'x' and 'y' and a 2d-image size 'szImg', which
%   the points are extracted from. The voronoi diagram is created
%   using Matlab's voronoi function.
%  
%     Example
%     -------
%
%         % get image from steve's blog at mathworks.com
%         if ~exist('nuclei.png','file')
%            img = imread('http://blogs.mathworks.com/images/steve/60/nuclei.png');
%            imwrite(img,'nuclei.png');
%         else
%            img = imread('/nuclei.png');  
%         end
%         img = double(img);
% 
%         % crop image
%         img = img(1:300,1:350);
% 
%         % "blur" image with imopen
%         se = strel('disk', 15);
%         imgo = imopen(img, se);
% 
%         % find regional max
%         imgPros = imregionalmax(imgo,4);
% 
%         % get centroids of regional max
%         objects = regionprops(imgPros,{'Centroid', 'BoundingBox','Image'});
% 
%         % save centroids to array
%         centroids = nan([numel(objects),2]);
%         for i = 1:numel(objects)
%             centroids(i,:) = objects(i).Centroid;
%         end
% 
%         % based on the centroids, create the voronoi diagram
%         % and transform the Voronoi cells to an image.
%         mask = voronoi2mask(centroids(:,1),centroids(:,2),size(img));
%         mask = label2rgb(mask, 'jet', 'c', 'shuffle');
%
%         % show results
%         subplot(2,1,1)
%         imagesc(img);colormap('gray');
%         hold on;
%         h = voronoi(centroids(:,1),centroids(:,2));
%         set(h(:),'Color',[0 1 0]);
%         axis image;
%         title('original image with voronoi diagram');
% 
%         subplot(2,1,2)
%         imshow(mask);
%         hold on;
%         h = voronoi(centroids(:,1),centroids(:,2));
%         set(h(:),'Color',[0 0 0]);
%         axis image;
%         title('output image with voronoi diagram');
%  
%     See also poly2mask, roipoly.
%
%
% $Created: 1.0 $ $Date: 2013/08/11 20:00$ $Author: Pangyu Teng $
%
if nargin < 3
    display('requires 3 inputs. (voronoi2mask.m)');
    return;
end
% format x, y to be column wise
if size(x,1) < size(x,2)
    x = x';
end
if size(x,1) < size(x,2)
    y = y';
end
% create voronoi diagram and get its finite vertices
[vx, vy] = voronoi(x,y);
% check if vertices points have at least on of points outside of the image
% range...if both within take the one that is closest to the boundary and
% extend it out of the image window
% bndim(1,:)=[1;1];
% bndim(2,:)=[1;szImg(1)];
% bndim(3,:)=[szImg(2);szImg(1)];
% bndim(4,:)=[szImg(2);1];
% for i=1:size(vx,2)
%    in=inpolygon(vx(:,i),vy(:,i),bndim(:,1),bndim(:,2)); 
%    if sum(in)==2
%        vy1=vy(1,i);
%        vx1=vx(1,i);
%        vy2=vy(2,i);
%        vx2=vx(2,i);
%        slope=(vy2-vy1)/(vx2-vx1);
%        intercept=vy2-slope*vx2;
%        vx2new=-intercept/slope;
%        vx(2,i)=vx2new;
%        vy(2,i)=0;
%    end
% end
% create a mask to draw the vertices
border = logical(false(szImg));
mask = zeros(szImg);
%% draw vertices on mask
for i = 1:size(vx,2)
    
    % create line function between 2 points
 
  
    
    f = makelinefun(vy(1,i),vx(1,i),vy(2,i),vx(2,i),2);
    
    % get distance between 2 points
    dist = round(1.5*sqrt(diff(vx(:,i)).^2+diff(vy(:,i)).^2));
    
    if dist~=Inf
    % create 'dist' points on the line 
    [vxLine, vyLine] = f(dist);  

    % round the line
    vxLine = round(vxLine);
    vyLine = round(vyLine);
    
    % contrain line to be within the image
    validInd = vxLine >= 1 & vxLine <= szImg(1) & vyLine >= 1 & vyLine <= szImg(2);
    vxLine = vxLine(validInd);
    vyLine = vyLine(validInd);
    
    % draw the line to an image
    newInd = sub2ind(szImg,vxLine,vyLine);
    border(newInd) = true;
    end
%     %imagesc(border)
%     figure
%     plot(x,y,'*')
%     hold on
%     plot(vy(1,i),vx(1,i),'ro')
%     hold on
%     plot(vy(2,i),vx(2,i),'go')
%     hold on
%     plot(vxLine,vyLine,'.m')
%     xlim([1 szImg(1)])
%     ylim([1 szImg(2)])
end
% round xs and yx
x = round(x);
y = round(y);
% number each region based on the index of the centroids
% (xs and ys are "flipped" ...)
for i = 1:numel(x)    
    
    bw = imfill(border,sub2ind(szImg,y(i),x(i)));
    bw2=bwmorph(bw,'thin',5);
    mask(bw2(:)==1) = i;        
end

mask(border(:)==1)=0;
%dfdfd