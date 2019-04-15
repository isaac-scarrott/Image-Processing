%Loads the image in and converts it to grey scale for image processing 
Original = rgb2gray(imread('Zebra.jpg'));

%Creates a vector for the resized image
Resized = uint8(zeros(1668,1836));

%Loads the dimensions of the original and the resized images into variables
[Orows, Ocolumns] = size(Original);
[Rrows, Rcolumns] = size(Resized);

%Calculates the scale
Scale = Rrows / Orows;

%Used to track where in the resized image it should be
Resizedrowcounter = 1;
Resizedcolcounter = 1;

%Linear Interpolation Algorithm 
%Loops through ever column and then will fill in the nearest neighbour
%pixels with the correct values going column  by column. Is scaleable
for col = 1:Ocolumns
    for row = 1:Orows
        for Colcounter = 0:Scale-1
           for Rowcounter = 0:Scale-1
              Resized((Resizedrowcounter+Rowcounter), (Resizedcolcounter+Colcounter)) =  Original(row,col);
           end
        end
        Resizedrowcounter = Resizedrowcounter + Scale;
    end
    %Used as a counter for the pixels that need filling in
    Resizedcolcounter = Resizedcolcounter + Scale;
    Resizedrowcounter = 1;
end

%Used to display the image
axis on;
imshowpair(Original, Resized, 'montage');
title('Nearest Neighbour Interpolation');

figure;
[J, rect] = imcrop(Resized);
imshow(J);
