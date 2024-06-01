load wbarb;
whos;

% you can un-comment this to load a different image
%{
imageFile = 'dance Medium.png'; % Specify the image file name
X = imread(imageFile); % Read the image file into a matrix

% pre-process the image first
% If the image is in color (RGB), convert it to grayscale
if size(X, 3) == 3
    X = rgb2gray(X);
end

% Convert image to double precision and scale appropriately
X = double(X);

% Normalize the image to the range [0, 255] if it's not already
if max(X(:)) > 1
    X = X / 255;
end

whos;
%}

% choose the parameters
wavelet = 'db4';
level = 4;

% Wavelet decomposition
[C, S] = wavedec2(X, level, wavelet);

% ddencmp estimates the threshold and the type of 
% threshold automatically
[thr, sorh, keepapp] = ddencmp('cmp', 'wv', X);

% Perform wavelet compression
% Xcomp is the compressed image
% PERF0 = the percentage of thresholded coefficients that are equal to 0.
% PERFL2 = percentage of energe preserved 
[Xcomp, CXC, LXC, PERF0, PERFL2] = wdencmp('gbl', C, S, wavelet, level, thr, sorh, keepapp);

% Ensure compressed image is in the correct range
if max(Xcomp(:)) > 1
    Xcomp = Xcomp / 255;
end

% Display original and compressed images using imshow
figure;
subplot(121); imshow(X, []); title('Original Image', 'FontSize', 10);
axis square;
axis off;
annotation_str = sprintf('Compression score: %.2f%%\n Remaining Energy: %.4f%%', PERF0, PERFL2);
subplot(122); imshow(Xcomp, []); title(annotation_str, 'FontSize', 10);
axis square;
axis off;

print('basics', '-dpng');
% we can extract certain level 
% of details (wavelet) in different directions
% and of approximations (scaling)
% we plot a few below

% level 1
[H1,V1,D1] = detcoef2('all',C,S,1);
A1 = appcoef2(C,S,wavelet,1);

V1img = wcodemat(V1,255,'mat',1);
H1img = wcodemat(H1,255,'mat',1);
D1img = wcodemat(D1,255,'mat',1);
A1img = wcodemat(A1,255,'mat',1);

figure;
subplot(2,2,1)
imagesc(A1img)
colormap pink(255)
title('Approximation Coef. of Level 1')

subplot(2,2,2)
imagesc(H1img)
title('Horizontal Detail Coef. of Level 1')

subplot(2,2,3)
imagesc(V1img)
title('Vertical Detail Coef. of Level 1')

subplot(2,2,4)
imagesc(D1img)
title('Diagonal Detail Coef. of Level 1')
print('level1-details-and-approximation', '-dpng');

% of course we'll try level 2
[H2,V2,D2] = detcoef2('all',C,S,2);
A2 = appcoef2(C,S,wavelet,2);

V2img = wcodemat(V2,255,'mat',1);
H2img = wcodemat(H2,255,'mat',1);
D2img = wcodemat(D2,255,'mat',1);
A2img = wcodemat(A2,255,'mat',1);

figure
subplot(2,2,1)
imagesc(A2img)
colormap pink(255)
title('Approximation Coef. of Level 2')

subplot(2,2,2)
imagesc(H2img)
title('Horizontal Detail Coef. of Level 2')

subplot(2,2,3)
imagesc(V2img)
title('Vertical Detail Coef. of Level 2')

subplot(2,2,4)
imagesc(D2img)
title('Diagonal Detail Coef. of Level 2')
print('level2-details-and-approximation', '-dpng');
% lower levels are closer to the root of
% the decomposition tree
% level 1: LL,LH, HL, HH
% level 2 is a finer decomposition of LL
% thus more blurry

% the following is a shorter version of what we just did
%{
%Load ima
load wbarb;
%     % Define wavelet of your choice
wavelet = 'haar';
%     % Define wavelet decomposition level
level = 2;
%     % Compute multilevel 2D wavelet decomposition
[C, S] = wavedec2(X,level,wavelet);
%     % Define colormap and set rescale value
colormap(map); rv = length(map);
%     % Plot wavelet decomposition using square mode
plotwavelet2(C,S,level,wavelet,rv,'square');
title(['Decomposition at level ',num2str(level)]);
%}

% manual thresholding 
% load a different image, let's say Taylor Swift
imageFile = 'ts.JPG'; 
X = imread(imageFile); 
if size(X, 3) == 3
    X = rgb2gray(X);
end
X = double(X);

wavelet = 'db4';
level = 4;

[C, S] = wavedec2(X, level, wavelet);
Csort = sort(abs(C(:))); % sort C first by abs

figure;
counter = 1;
for keep = [.1 .01 .002 .0005]
    subplot(2,2,counter)
    thresh = Csort(floor((1-keep)*length(Csort)));
    ind = abs(C)>thresh;   % Threshold small indices
    Cfilt = C.*ind;

    % Plot Reconstruction
    ts=waverec2(Cfilt,S,wavelet);
    ts = mat2gray(ts);
    imshow(ts)  % Plot Reconstruction
    title(['', num2str(keep*100), '%'],'FontSize', 15)
    counter = counter + 1;
end
% set(gcf,'Position',[1750 100 1750 2000])
print('hard-thresholding', '-dpng');
