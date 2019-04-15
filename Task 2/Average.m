clc;
clear;

%Loads the image in and converts it to grey scale for image processing 
Original = rgb2gray(imread('Noisy.png'));

Padded = padarray(Original,[2 2]);
meanImage = Padded;

%Loads the dimensions of the original and the resized images into variables
[rows, cols] = size(Padded);

%Creates an empty array to store the 5x5 mask in
Sum = [];

%Loops through each pixel. Then for each pixel loads the 5x5 mask into an
%array which the mean function is used to find the mean value of the
%mask. This value is then put into the pixel 2x2 in to account for padding
for col = 1:cols-4
    for row = 1:rows-4
        Sum = 0;
        for Countercols = 0:4
            for Counterrows = 0:4
                Sum = [int16(Padded((row+Counterrows), (col+Countercols))), Sum];
            end
        end
        meanImage((row+2), (col+2)) = mean(Sum);
    end
end

%Crops the image to remove padding
meanImageCropped = imcrop(meanImage,[3 3 cols-5 rows-5]);

%Shows all 4 of the images at key steps in the filtering process
figure;
subplot(2,2,1)
imshow(Original);
title('Original Image');

subplot(2,2,2)
imshow(Padded);
title('Padded Image');

subplot(2,2,3)
imshow(meanImage);
title('Padded Mean Image');

subplot(2,2,4)
imshow(meanImageCropped);
title('Mean Image');

