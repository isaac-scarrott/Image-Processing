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

%Used to store the boundies of each image
[B,L,N,A] = bwboundaries(BinaryImage);

%Used to store details about each object
ObjectPerth = {};
ObjectPerr = {};
ObjMean = {};
ObjStd = {};

%Gets each of the connected components
cc = bwconncomp(BinaryImage,8);

%Loops through each object in the binary image
for cnt = 1:N
    %Gets the boundary of the image
    boundary = B{cnt};
    %Creates a polar graph of the radius from the centroid of the selected
    %image
    [th, r]=cart2pol(boundary(:,2)-mean(boundary(:,2)), ...
        boundary(:,1)-mean(boundary(:,1)));
    axis([-pi pi 0 50]);
    xlabel('radian');ylabel('r');
    %     title(['Object ', num2str(cnt)]);
    %
    %Used to store the values of the graph
    ObjectPerth{end+1} = th;
    ObjectPerr{end+1} = r;
end

peaks = [];
troths = [];
potentialStarfish = [];

%Loops through each object to find the objects
for cnt = 1:N
    %Used to filterout objects too small 
    if numel(ObjectPerth{1,cnt}) > 4
        %Smooths the graph to get rid of outliers
        tempth = smooth(ObjectPerth{1,cnt});
        tempr = smooth(ObjectPerr{1,cnt});
        
        %Finds peaks with a defined peak based on the size of the object
        peaks = [peaks, (numel(findpeaks(tempr, 'MINPEAKHEIGHT', max(ObjectPerr{:,1})*0.4)))];
        %Checks if peaks is 5 to make it a potential starfish
        if peaks(cnt) == 5
            potentialStarfish = [potentialStarfish, cnt];
        end
        %Because it's a polar graph peaks might appear exactly on thr graph
        %boundry so this will detect any peaks that find peaks function
        %won't detect due to it being a polar graph
        if (tempr(2) < tempr(1)) && (tempr(end-1) < tempr(1)) && (tempr(end) == tempr(1)) && (peaks(cnt) == 4)
            potentialStarfish = [potentialStarfish, cnt];
        end
    else
        peaks = [peaks, 0];
    end
end

distances = [];
%Finds and store the difference between the distance inbetween the peaks
 for cnt = 1:length(potentialStarfish)
     tempth = smooth(ObjectPerth{1,potentialStarfish(cnt)});
     tempr = smooth(ObjectPerr{1,potentialStarfish(cnt)});
     figure;
     plot(tempth, tempr);
     [peaks,index] = findpeaks(tempr, 'MINPEAKHEIGHT', max(ObjectPerr{:,1})*0.4);
     %distances
     distances = [distances, mean(diff(index))];
 end
 
distances = distances';
 
%Uses K means again to cluster similar values together (Same method as in task 4)
[IDX, nn] = kmeans(distances, 2);
kmeansNumbers = [];
for y = 1:length(potentialStarfish)
    kmeansNumbers = [kmeansNumbers, IDX(y)];
end

kMeansMode = mode(kmeansNumbers);

starfishNumbers = [];

%Stores the star fish to be displayed
for y = 1:length(potentialStarfish)
    if kMeansMode == kmeansNumbers(y)
        starfishNumbers = [starfishNumbers, potentialStarfish(y)];
    end
end

%So I can display all of the starfish in one figure
seperateImage = false(size(BinaryImage));
figure;

%Displays all of the starfish
for y = 1:length(starfishNumbers)
    seperateImage(cc.PixelIdxList{starfishNumbers(y)}) = true;
    imshow(seperateImage);
end

title('Image With Starfish Detected');
