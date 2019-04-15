clc;
clear;

%Loads the image in
Image = imread('Starfish.jpg');

%Converts the image to greyscale
Image = rgb2gray(Image);

%Saturates the Image to make the objects in the image more defined
SaturatedImage = adapthisteq(histeq(imadjust(Image)));

%Applys median filter to the image to remove noise
SaturatedFilteredImage = medfilt2(SaturatedImage,[5 5]);

%Converts the image to a binary image using the threshholding number of
%0.44 (value > 112 = 255)
BinaryImage = ~ imbinarize(SaturatedFilteredImage, 0.44);

BinaryImage = medfilt2(BinaryImage,[5 5]);

%Used to find the connected components in the image. This serperates the images. Uses the desired
%connectivity of 8 however it doesn't make a difference if you use 8 or 4
cc = bwconncomp(BinaryImage,8);

%Gets all the properties of each of the connected images in the binary
%image and puts the stats about each of the images into an array
stats = regionprops(cc,'all');
statsRatios = regionprops(cc,'Eccentricity', 'Solidity', 'Extent');

%Used to store the image number of a starfish
potentialStarfishNumbers = [];

%Loops through each of the objects in the image
for objectNum = 1:cc.NumObjects
    %This is what is used to store the image of the seperated object we are
    %currently analysising
    seperateImage = false(size(BinaryImage));
    seperateImage(cc.PixelIdxList{objectNum}) = true;
    
    %This stores all of the co ordinates of the convex hull around the
    %image
    xy = stats(objectNum).ConvexHull;
    
    %Stores the dimensions of the images. This value should not change
    [r, c] = size(seperateImage);
    %Creates a mask using the convex hull that was previously defined
    mask = poly2mask(xy(:,1),xy(:,2),r, c);
    for no = 1:2:20
        ones(no);
        
        %Makes the mask smaller or erodes it in order to see if the object has
        %5 rays to make it a star fish
        maskErode = imerode(mask, ones(no));
        
        %store the region properties of the middle of the object
        rp = regionprops(maskErode,'all');
        
        %Sees if it can do the operation
        try
            xy = rp.ConvexHull;
        catch
            continue;
        end
        
        %Stores the coordinates for the convex hull
        xy = rp.ConvexHull;
        
        %Puts all of the seperated objects in another image on their own so they are ready
        %to be counted
        rays = seperateImage;
        rays(maskErode) = 0;
        
        %Stores the number of objects in the image
        [l, num] = bwlabel(rays);
        
        %Checks if has detected 5 serperate objects. If it does it will put it
        %in an array to be displayed later
        if num == 5
            potentialStarfishNumbers = [potentialStarfishNumbers, objectNum];
        end
    end
    
    %Clears the variables ready for use on the next loop
end

%Used to get the number of times an double appears in the
%potentialStarfishNumbers array
x = unique(potentialStarfishNumbers);
N = numel(x);
count = zeros(N,1);
for k = 1:N
    count(k) = sum(potentialStarfishNumbers==x(k));
end
values = [ x(:) count ];
[rows,cols] = size(values);
potentialStarfishNumbers = [];

%Checks how many times the potentialStarfishNumbers appear to get rid of
%outliers that could have been picked up
for x = 1:rows
    if values(x, 2) >= 2
        potentialStarfishNumbers = [potentialStarfishNumbers, values(x,1)];
    end
end

%Converts statsRatios into a useable format
statsRatios = struct2cell(statsRatios).';

%Used to get ratios of the potential starfish for analysing
eccentricity = cell2mat(statsRatios(:, 1));
solidity = cell2mat(statsRatios(:, 2));
extent = cell2mat(statsRatios(:, 3));
total = [];

%Loops through each potential starfish and stores the average of the ratios
%in a corisopoding array index
for x = 1:size(eccentricity,1)
    total = [total, (eccentricity(x) + solidity(x) + extent(x))/3];
end

%Inverts the array for use
total = total.';

%Gets Kmeans numbers into an array. 6 total clusters used
[IDX, nn] = kmeans(total, 6);

kmeansCoNumbers = [];
kmeansNumbers = [];

%Assigns each potential starfish with a kmean cluster number
for y = 1:length(potentialStarfishNumbers)
    kmeansNumbers = [kmeansNumbers, IDX(potentialStarfishNumbers(y))];
end

%Gets the most frequestly occuring cluster
kMeansMode = mode(kmeansNumbers);

starfishNumbers = [];

%Goes through each potentialStarfishNumbers and removes any that doesn't
%equal ther mode getting rid of outliers
for y = 1:length(potentialStarfishNumbers)
    if kMeansMode == kmeansNumbers(y)
        starfishNumbers = [starfishNumbers, potentialStarfishNumbers(y)];
    end
end

%Displays relevant images
figure;
subplot(3,2,1)
imshow(Image);
title('Greyscale Image');

subplot(3,2,2)
imshow(SaturatedImage);
title('Saturated Greyscale Image');

subplot(3,2,3)
imshow(SaturatedFilteredImage);
title('Saturated Greyscale Median Filtered Image');

subplot(3,2,4)
imshow(BinaryImage);
title('Binary Image');

%So I can display all of the starfish in one figure
seperateImage = false(size(BinaryImage));
subplot(3,2,5)

%Displays all of the starfish
for y = 1:length(starfishNumbers)
    seperateImage(cc.PixelIdxList{starfishNumbers(y)}) = true;
    imshow(seperateImage);
end

title('Image With Starfish Detected');

%This uses code before to show how we got the number of fins on a starfish
seperateImage = false(size(BinaryImage));
seperateImage(cc.PixelIdxList{5}) = true;
figure;
subplot(2,1,1)
imshow(seperateImage);
title('Convex Hull Examples');
xy = stats(5).ConvexHull;
line(xy(:,1), xy(:,2), 'Color', 'Yellow', 'LineWidth',1);
[r, c] = size(seperateImage);
mask = poly2mask(xy(:,1),xy(:,2),r, c);
ones(12);
maskErode = imerode(mask, ones(11));
rp = regionprops(maskErode,'all');
xy = rp.ConvexHull;
line(xy(:,1), xy(:,2), 'Color', 'Red', 'LineWidth',1);
rays = seperateImage;
rays(maskErode) = 0;
subplot(2,1,2)
imshow(rays);
title('Convex Hull Examples');



