%Closing and resetting for new run
close all;

%1. Read and display image
loadedImage = imread("Flooded_house.jpg");

%2. Show Red, Green, and Blue bands
redChannel = loadedImage(:,:,1);
greenChannel = loadedImage(:,:,2);
blueChannel = loadedImage(:,:,3);
blackChannel = zeros(size(loadedImage, 1), size(loadedImage, 2), 'uint8');

redBand = cat(3, redChannel, blackChannel, blackChannel);
greenBand = cat(3, blackChannel, greenChannel, blackChannel);
blueBand = cat(3, blackChannel, blackChannel, blueChannel);

%3. Convert Image to YCbCr color space
ycbcr = rgb2ycbcr(loadedImage);

%4. Display Y, Cb, Cr Bands  
yChannel = ycbcr(:,:,1);
cbChannel = ycbcr(:,:,2);
crChannel = ycbcr(:,:,3);

%5. Subsample Cb and Cr using 4:2:0
cbSubsample = cbChannel;
crSubsample = crChannel;
for cols = 1:704
    for rows = 1:536
        %Cb subsample
        if mod(rows,2) ~= 0
            if(mod(cols,2) == 0)
                cbSubsample(rows,cols) = 0;
            end
        else 
            cbSubsample(rows,cols) = 0;
        end

        %Cr Subsample
        if mod(rows,2) ~= 0
            if(mod(cols,2) == 0)
                crSubsample(rows,cols) = 0;
            end
        else 
            crSubsample(rows,cols) = 0;
        end
    end
end

%6. Upsample and Display Cb and Cr bands

%6.1. Linear Interpolation
%Odd numbered row: missing pixel value from neighboring pixels in rows
%Even numbered row: missing pixel value from neightboring pixels in columns
cbUpsample1 = cbSubsample;
crUpsample1 = crSubsample;
for cols = 1:704
    for rows = 1:536
        %Cb Odd rows
        if(mod(rows,2) ~= 0)
            if(cols == 704)
                cbUpsample1(rows,cols) = cbUpsample1(rows, cols-1);
            else
                if(mod(cols,2) == 0)
                    tempArr = [cbUpsample1(rows,cols-1) cbUpsample1(rows,cols+1)];
                    avgPxVal = mean(tempArr);
                    cbUpsample1(rows, cols) = avgPxVal;
                end
            end
        end

        %Cr Odd rows
        if(mod(rows,2) ~= 0)
            if(cols == 704)
                crUpsample1(rows,cols) = crUpsample1(rows, cols-1);
            else
                if(mod(cols,2) == 0)
                    tempArr = [crUpsample1(rows,cols-1) crUpsample1(rows,cols+1)];
                    avgPxVal = mean(tempArr);
                    crUpsample1(rows, cols) = avgPxVal;
                end
            end
        elseif(mod(rows,2) == 0)   
            if (rows == 536)
                crUpsample1(rows, cols) = crUpsample1(rows-1, cols);
            else
                tempArr = [crUpsample1(rows-1, cols) crUpsample1(rows+1, cols)];
                avgPxVal = mean(tempArr);
                crUpsample1(rows, cols) = avgPxVal;
            end
        end
    end
end

for cols = 1:704
    for rows = 1:536
        %Cb even rows
        if(mod(rows,2) == 0)   
            if (rows == 536)
                cbUpsample1(rows, cols) = cbUpsample1(rows-1, cols);
            else
                tempArr = [cbUpsample1(rows-1, cols) cbUpsample1(rows+1, cols)];
                avgPxVal = mean(tempArr);
                cbUpsample1(rows, cols) = avgPxVal;
            end
        end
        
        %Cr even rows
        if(mod(rows,2) == 0)   
            if (rows == 536)
                crUpsample1(rows, cols) = crUpsample1(rows-1, cols);
            else
                tempArr = [crUpsample1(rows-1, cols) crUpsample1(rows+1, cols)];
                avgPxVal = mean(tempArr);
                crUpsample1(rows, cols) = avgPxVal;
            end
        end
    end
end
%6.2: Row Column Replication
%Complete Odd Rows then copy them to next even row
cbUpsample2 = cbSubsample;
crUpsample2 = crSubsample;
for cols = 1:704
    for rows= 1:536
        %Cb Upsample
        if (mod(rows, 2) ~= 0)
            if(mod(cols,2) == 0)
                cbUpsample2(rows,cols) = cbUpsample2(rows,cols - 1);
            end
        elseif(mod(rows,2) == 0)
            cbUpsample2(rows,cols) = cbUpsample2(rows-1, cols);
        end

        %Cr Upsample
        if (mod(rows, 2) ~= 0)
            if(mod(cols,2) == 0)
                crUpsample2(rows,cols) = crUpsample2(rows,cols - 1);
            end
        elseif(mod(rows,2) == 0)
            crUpsample2(rows,cols) = crUpsample2(rows-1, cols);
        end
    end
end

%7-8. Convert Image to RGB Format
linearInter = cat(3, yChannel, cbUpsample1, crUpsample1);
rbgLinear = ycbcr2rgb(linearInter);

rowReplicaton = cat(3, yChannel, cbUpsample2, crUpsample2);
rbgReplication = ycbcr2rgb(rowReplicaton);

%10. Linear Interpolation MSE
MSE = double(0);
for cols = 1:704
    for rows = 1:536
        MSE = MSE + double((loadedImage(rows, cols) - rbgLinear(rows, cols))^2);
    end
end
MSE = MSE * double(1/(704 * 536));
disp('Calculated MSE: ');
disp(MSE);

%Outputting to Figure
% 1 2 3 
% 4 5 6
% 7 8 9
%10 11 12
%13 14 15
%16 17 18

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%1___________________________________________________________
imshow(loadedImage);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2___________________________________________________________
%subplot(1,3,1), imshow(redBand);
%subplot(1,3,2), imshow(greenBand);
%subplot(1,3,3), imshow(blueBand);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%3___________________________________________________________
%imshow(ycbcr);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%4___________________________________________________________
%subplot(1,3,1), imshow(yChannel);
%subplot(1,3,2), imshow(cbChannel);
%subplot(1,3,3), imshow(crChannel);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%5___________________________________________________________
%subplot(1,2,1), imshow(cbSubsample);
%subplot(1,2,2), imshow(crSubsample);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%6___________________________________________________________
%subplot(2,2,1), imshow(cbUpsample1);
%subplot(2,2,2), imshow(crUpsample1);
%subplot(2,2,3), imshow(cbUpsample2);
%subplot(2,2,4), imshow(crUpsample2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%7-8_________________________________________________________
%subplot(1,2,1), imshow(rbgLinear);
%subplot(1,2,2), imshow(rbgReplication);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
9. 
From a first glance at the images completely unzoomed, it 
is nearly impossible to tell that they are different from the
original image. It is only when you look more closely at the 
individual pixels where you start to see the differences. Areas
of low frequency change tended to stay the most close to the 
original as it seems that both methods of upsampling relied on 
finding values of the missing chroma samples from the pixels 
surrounding it, whether that is finding that average or simply
dupllicating the adjacent values. To my eye, it seems that the 
linear interpolated sample was the one that held up the quality 
the best as the row replication upsampled image has some artifacts,
especially around hard lines and areas of high frequency change.
%}

%{
11. 
The theoretical compression ratio of a 4:2:0 subsampling is
theorectically 2:1. This makes sense for what had to be done in those
steps because for every 4 luma samples we took, we onlt took 1 chroma
sample. This results in a having the same amount of luma data, but
reducing each of the two chroma samples by half, which results in a 
total quarter each. This results in there being exactly half of the data
remaining after subsampling.
%}


