function [ img, imgSize, didResize ] = imageSizeCheck(img, windowPtr )
%IMAGECHECK Checks if image is fit for displaying on screen
%   If image is too big it will resize the image.

%% Initial settings
[width, height]=Screen('WindowSize', windowPtr );
[h, w, ~] = size(img);
imgSize = [w,h];
aspectRatioScreen = width/height;
aspectRatioImage  = w/h;
didResize = false;
%% Check and if too big, do resize. Keep aspect ratio
if (w>width || h>height)
    if (aspectRatioImage > aspectRatioScreen)
        img = imresize(img, [NaN width]);
    else
        img = imresize(img, [height NaN]);
    end
    didResize = true;
    [h, w, ~] = size(img);
    imgSize = [w,h];
end

end

