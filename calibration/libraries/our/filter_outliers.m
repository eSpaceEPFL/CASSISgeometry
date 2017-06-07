function mask = filter_outliers(xx, err, K, th)
    
    [IDX, ~] = knnsearch(xx, xx, 'K', K);
    nb_points = size(xx,1);
    
    for n = 1:nb_points
        errCur = err(IDX(n,:));
        zCur = zscore([err(n); errCur]);
        if abs(zCur(1)) > th
            mask(n) = false;
        else
            mask(n) = true;
        end
    end
    
    
end