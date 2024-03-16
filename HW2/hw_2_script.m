%Closing and resetting for new run
close all;

%Read and display image
loadedImage = imread("Flooded_house.jpg");
%figure(1)
%imshow(loadedImage);

%Convert Image to YCbCr color space
ycbcr = rgb2ycbcr(loadedImage);

%Display Y, Cb, Cr Bands  
yChannel = ycbcr(:,:,1);
cbChannel = ycbcr(:,:,2);
crChannel = ycbcr(:,:,3);

%Output data
%subplot(1,3,1), imshow(yChannel);
%subplot(1,3,2), imshow(cbChannel);
%subplot(1,3,3), imshow(crChannel);

%Isolate the first 2 blocks on the 6th row
startRow = 6;
blockSize = 8;
rowPixels = yChannel(startRow : startRow + blockSize - 1, :);

block1 = rowPixels(:, 1: blockSize);
figure(1);

block2 = rowPixels(:, blockSize + 1: 2 * blockSize);
figure(2);

figure(1);
subplot(1,2,1), imshow(block1);
title('Y channel 1st Block');
subplot(1,2,2), imshow(block2);
title('Y channel 2nd Block');

%Calculate 8x8 DCT Transform Coefficient
pDCT = @dct2;
firstBlockDCT = blkproc(block1, [8,8], pDCT);
secondBlockDCT = blkproc(block2, [8,8], pDCT);

firstBlockDCT = fix(firstBlockDCT);
secondBlockDCT = fix(secondBlockDCT);

figure(2);
subplot(1,2,1), imshow(firstBlockDCT);
title('1st Block DCt Coefficient');
subplot(1,2,2), imshow(secondBlockDCT);
title('2nd Block DCT Coefficient');

%Quantize the DCT Coefficient 

%Quantization Matrix from Quality Level 50
luminanceQuantizer = [16, 11, 10, 16, 24, 40, 51, 61;
                      12, 12, 14, 19, 26, 58, 60, 55;
                      14, 13, 16, 24, 40, 57, 69, 56;
                      14, 17, 22, 29, 51, 87, 80, 62;
                      18, 22, 37, 56, 68, 109, 103, 77;
                      24, 35, 55, 64, 81, 104, 113, 92;
                      49, 64, 78, 87, 103, 121, 120, 101;
                      72, 92, 95, 98, 112, 100, 103, 99];

chrominanceQuantizer = [17, 18, 24, 47, 99, 99, 99, 99;
                        18, 21, 26, 66, 99, 99, 99, 99;
                        24, 26, 56, 99, 99, 99, 99, 99;
                        47, 66, 99, 99, 99, 99, 99, 99;
                        99, 99, 99, 99, 99, 99, 99, 99;
                        99, 99, 99, 99, 99, 99, 99, 99;
                        99, 99, 99, 99, 99, 99, 99, 99;
                        99, 99, 99, 99, 99, 99, 99, 99;];

quantizedBlock1 = round(firstBlockDCT ./ qBlock);
quantizedBlock2 = round(secondBlockDCT ./ qBlock);

disp(quantizedBlock1);
disp(quantizedBlock2);




