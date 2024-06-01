imageFile = 'ts.JPG'; 
X = imread(imageFile); 
if size(X, 3) == 3
    X = rgb2gray(X);
end
X = double(X);
wavelets = {'db1', 'db4', 'db8', 'haar'};
levels = {1, 2, 3, 4, 5};
% Display the menus and prompt the user to choose an option
wav_choice = menu(['We will compare wavelet packet and wavelet compression.' ...
    'Select a wavelet first:'], wavelets);
wavelet = wavelets{wav_choice};
level = menu('Please choose the decomposition level:', levels);

% we compare wavelet packet and basic wavelet
% just need set 'wp' in ddencmp
% and use wpdencmp instead of wdencmp
[thr, sorh, keepapp, crit] = ddencmp('cmp', 'wp', X);
[Xcomp_p, treed, PERF0_p, PERFL2_p] = wpdencmp(X, sorh, level, wavelet, crit, thr*2, keepapp);


[C, S] = wavedec2(X, level, wavelet);

[thr, sorh, keepapp] = ddencmp('cmp', 'wv', X);

[Xcomp_w, CXC, LXC, PERF0_w, PERFL2_w] = wdencmp('gbl', C, S, wavelet, level, thr, sorh, keepapp);


figure;
annotation_str = sprintf('Wavelet Packet at level %d using %s\n Compression score: %.2f%%\n Remaining Energy: %.4f%%', level, wavelet, PERF0_p, PERFL2_p);
subplot(121); imshow(Xcomp_p, []); title(annotation_str, 'FontSize', 10);
axis square;
axis off;
annotation_str = sprintf('Wavelet at level %d using %s \n Compression score: %.2f%%\n Remaining Energy: %.4f%%',level, wavelet, PERF0_w, PERFL2_w);
subplot(122); imshow(Xcomp_w, []); title(annotation_str, 'FontSize', 10);
axis square;
axis off;
% we can see that packet achieved a higher compression score
pic_name = sprintf('packet_compression_level_%d_using_%s', level, wavelet);
print(pic_name, '-dpng');

% similar to what we did in the basics
% manual thresholding 
% Load the image

T = wpdec2(X, level, wavelet);
plot(T)

pic_name = sprintf('wavelet_packet_tree_level_%d_using_%s', level, wavelet);
print(pic_name, '-dpng');
leavesNodes = leaves(T);

XREC = cell(1, 3);
titles = cell(1, 3);
counter = 0;
% Loop over each leaf node and modify the coefficients
for keep = [.8 .5 .2]
    counter = counter + 1;
    for i = 1:length(leavesNodes)
        % Read coefficients from the current leaf node
        leafIndex = leavesNodes(i);
        C = read(T, 'data', leafIndex);
        Csort = sort(abs(C(:))); % sort C first by abs
        thresh = Csort(floor((1-keep)*length(Csort)));
        ind = abs(C)>thresh;   % Threshold small indices
        Cfilt = C.*ind;
        % Modify the coefficients (example: zeroing out half of the coefficients)
        cfsModified = Cfilt;
    
        % Write the modified coefficients back to the tree
        T = write(T, 'data', leafIndex, cfsModified);
    end
    % Reconstruct the image from the modified wavelet packet tree
    xrec = wprec2(T);
    XREC{counter}= xrec;
    titles{counter} = ['', num2str(keep*100), '%'];
end

% Display the original and reconstructed images
figure;
subplot(2, 2, 1);
imshow(mat2gray(X)); % Normalize the original image for display
title('Original Image');

subplot(2, 2, 2);
imshow(mat2gray(XREC{1})); % Normalize the reconstructed image for display
title(titles{1},'FontSize', 15);

subplot(2, 2, 3);
imshow(mat2gray(XREC{2})); % Normalize the reconstructed image for display
title(titles{2},'FontSize', 15);

subplot(2, 2, 4);
imshow(mat2gray(XREC{3})); % Normalize the reconstructed image for display
title(titles{3},'FontSize', 15)
sgtitle('hard thresholding wavelet packet');

pic_name = sprintf('packet-all-leaves-hard-thresholding-level_%d_using_%s', level, wavelet);
print(pic_name, '-dpng');

%{
% hard thresh
sorh = 'h';
T1 = T;
% Returns a threshold close to 0. A typical THR value is median(abs(coefficients)).
thr = wthrmngr('wp2dcompGBL','rem_n0', T);
cfs = read(T,'data');
cfs = wthresh(cfs,sorh,thr);
T1  = write(T1,'data',cfs);

xrec = wprec(T1);
figure;
plot(xrec)
title('Packet Compression, Manual Thresholding')
%}