%{
run this file to explore how different threshold and entropy types affects the 
wavelet packet compression performance!
%}

imageFile = 'ts.JPG'; 
X = imread(imageFile); 
if size(X, 3) == 3
    X = rgb2gray(X);
end
X = double(X);
wavelet = 'db4';
level = 4;
keep = [.8 .5 .2];

entropyTypes = {'norm', 'shannon', 'threshold'};
thresholdTypes = {"hard", "soft"};
% Display the menus and prompt the user to choose an option
entropyType_choice = menu('Choose the entropy type: ', entropyTypes);
entropyType = entropyTypes{entropyType_choice};
thresholdType_choice = menu('Choose the threshold type: ', thresholdTypes);
thresholdType = thresholdTypes{thresholdType_choice};

% the following function will
% perform wavelet packet compression on X
% with the threshold type and entropy you picked 
% then output and store the figure
% it takes like 10 secs
thresholdWaveletPacketTree(X, level, wavelet, keep, entropyType, thresholdType);


function T = thresholdWaveletPacketTree(X, level, wavelet, keep, entropyType, thresholdType, varargin)
    % Function to threshold wavelet packet tree coefficient
    entropyP = 1;
    % Decompose the signal using wavelet packet decomposition
    T = wpdec2(X, level, wavelet, entropyType, entropyP);
    
    % Get the leaves of the wavelet packet tree
    leavesNodes = leaves(T);
    XREC = cell(1, 3);
    titles = cell(1, 3);
    counter = 0;
    for val = keep
    counter = counter + 1;
        % Loop through all leaves to apply thresholding
        for i = 1:length(leavesNodes)
            % Read coefficients from the current leaf node
            leafIndex = leavesNodes(i);
            C = read(T, 'data', leafIndex);
            Csort = sort(abs(C(:))); % sort C first by abs
            thresh = Csort(floor((1-val) * length(Csort)));
            
            % Apply the specified thresholding method
            if strcmp(thresholdType, 'hard')
                Cfilt = hardThreshold(C, thresh);
            else
                Cfilt = softThreshold(C, thresh);
            end
            
            % Write the modified coefficients back to the tree
            T = write(T, 'data', leafIndex, Cfilt);
        end
        % Reconstruct the image from the modified wavelet packet tree
        xrec = wprec2(T);
        XREC{counter}= xrec;
        titles{counter} = ['', num2str(val*100), '%'];
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
    titlename = sprintf('packet, %s entropy-type, %s thresholding', entropyType, thresholdType);
    sgtitle(titlename);
    
    pic_name = titlename;
    print(pic_name, '-dpng');
end


function y = softThreshold(x, thresh)
    y = sign(x) .* max(abs(x) - thresh, 0);
end

function y = hardThreshold(x, thresh)
    ind = abs(x)>thresh;
    y = x.* ind;
end
