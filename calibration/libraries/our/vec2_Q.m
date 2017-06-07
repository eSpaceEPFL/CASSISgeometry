function Q = vec2_Q(vec)
    nb = floor(length(vec) / 4);
    for n = 1:nb
        Q(:,n) = vec((n-1)*4+1:(n*4));
    end
end