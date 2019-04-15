%Loads the image in and converts it to grey scale for image processing 
Original = rgb2gray(imread('Zebra.jpg'));

%Creates a vector for the resized image
Resized = uint8(zeros(1668,1836));

%Loads the dimensions of the original and the resized images into variables
[Orows, Ocolumns] = size(Original);
[Rrows, Rcolumns] = size(Resized);

%Calculates the scale
Scale = round(Rrows / Orows);

%Used to track where in the resized image it should be
Resizedrowcounter = 1;
Resizedcolcounter = 1;

%Puts pixels in each of the corners
for col = 1:Ocolumns
    for row = 1:Orows
        Resized((Resizedrowcounter), (Resizedcolcounter)) =  Original(row,col);
        Resizedrowcounter = Resizedrowcounter + Scale;
    end
    Resizedcolcounter = Resizedcolcounter + Scale;
    Resizedrowcounter = 1;
end


%Bilinear for the first row of each significant pixel
for col = 2:Scale:1834
    for row = 1:Scale:1666
           for Colcounter = 0:(Scale-2)
               %assigns variables for the equasion
                B = Scale;
                A = Scale - 2 + Colcounter;
                D = Scale - A;
                C = Resized(row, col + Scale - 1);
                E = Resized(row, col - 1);
                
                %Equasion so it's in an easy to read format
                Resized(row, col + Colcounter) = (A/B)*C + (D/B)*E;        
           end  
    end
end

%Completes bilinear for all of the missing columns
for col = 1:1834
    for row = 2:Scale:1666
           for Rowcounter = 0:(Scale-2)
               %assigns variables for the equasion
                B = Scale;
                A = Scale - 2 + Rowcounter;
                D = Scale - A;
                C = Resized(row + Scale - 1, col);
                E = Resized(row - 1, col);
                
                %Equasion so it's in an easy to read format
                Resized(row + Rowcounter, col) = (A/B)*C + (D/B)*E;        
           end
    end
end

%Used to display the image
axis on;
imshowpair(Original, Resized, 'montage');
title('Bilinear Interpolation');

figure;
[J, rect] = imcrop(Resized);
imshow(J);


%Writes the images to a PNG file

