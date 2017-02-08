function exp = cassis_get_exp(subexp, xywh)

mask = false(2048,2048);
exp = zeros(2048,2048);

for nsubexp = 1:length(subexp)
    
    data = subexp{nsubexp};
    [x0,y0,w,h] = deal(xywh{nsubexp}(1), xywh{nsubexp}(2), xywh{nsubexp}(3), xywh{nsubexp}(4));
    exp(y0:y0+h-1, x0:x0+w-1) = data;
    mask(y0:y0+h-1, x0:x0+w-1) = true;
    
end
end