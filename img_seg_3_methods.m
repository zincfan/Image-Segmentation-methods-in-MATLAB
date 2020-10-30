%combination of all 3 img seg methods%
[imgfile ,pathname] = uigetfile({'*.jpg';'*.bmp'},'Select image');
img=imread(imgfile);
[J,rect]=imcrop(img);
%rect = xmin ymin width height %
lazy_snapping_f(img,rect);
%cell_contrast(J);
%k_means(J);

function f1=lazy_snapping_f(RGB,rect)
xmin=rect(1);ymin=rect(2);width=rect(3);height=rect(4);
%figure,imshow(RGB);
[x,y]=size(RGB);
L=superpixels(RGB,500);
%f = drawrectangle(gca,'Position',[0.25*width+xmin 0.25*height+ymin 0.60*width 0.60*height],'Color','g');
f = drawrectangle(gca, 'Color','g');
foreground=createMask(f,RGB);
b1 = drawrectangle(gca,'Position',[0 0 x ymin],'Color','r');
b2 = drawrectangle(gca,'Position',[xmin+width ymin x-xmin+width height],'Color','r');
b3 = drawrectangle(gca,'Position',[0 ymin xmin height],'Color','r');
b4 = drawrectangle(gca,'Position',[0 ymin+height x y-ymin+height],'Color','r');
background = createMask(b1,RGB) + createMask(b2,RGB) + createMask(b3,RGB) + createMask(b4,RGB);
BW = lazysnapping(RGB,L,foreground,background);
figure,imshow(labeloverlay(RGB,BW,'Colormap',[0 1 0]))
maskedImage = RGB;
maskedImage(repmat(~BW,[1 1 3])) = 0;
imshow(maskedImage)
%maskedImage = RGB;
%maskedImage(repmat(~BW,[1 1 3])) = 0;
%imshow(maskedImage)
end

function f2=cell_contrast(I)
I = rgb2gray(I);
[~,threshold] = edge(I,'sobel');
fudgeFactor = 0.5;
BWs = edge(I,'sobel',threshold * fudgeFactor);
%imshow(BWs)
title('Binary Gradient Mask')
se90 = strel('line',3,90);
se0 = strel('line',3,0);
BWsdil = imdilate(BWs,[se90 se0]);
%imshow(BWsdil)
title('Dilated Gradient Mask')
BWdfill = imfill(BWsdil,'holes');
%imshow(BWdfill)
title('Binary Image with Filled Holes')
%optional to remove other objects%
BWnobord = imclearborder(BWdfill,4);
imshow(BWnobord)
title('Cleared Border Image')
seD = strel('diamond',1);
BWfinal = imerode(BWnobord,seD);
BWfinal = imerode(BWfinal,seD);
imshow(BWfinal)
title('Segmented Image');
figure,imshow(labeloverlay(I,BWfinal))
title('Mask Over Original Image')
end

function f3=k_means(he)
%imshow(he);
lab_he = rgb2lab(he);
ab = lab_he(:,:,2:3);
ab = im2single(ab);
nColors = 3;
% repeat the clustering 3 times to avoid local minima
pixel_labels = imsegkmeans(ab,nColors,'NumAttempts',4);
figure,imshow(pixel_labels,[])
title('Image Labeled by Cluster Index');
end

