% project stars to images
function [res, xx_pred]= stars2image_error(XX,xx,R,K)
    tmp = (K*R*XX')';
    xx_pred(:,1) = tmp(:,1)./tmp(:,3);
    xx_pred(:,2) = tmp(:,2)./tmp(:,3);
    res = xx_pred - xx;
end