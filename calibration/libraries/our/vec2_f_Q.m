function [f,  Q] =  vec2_f_Q(vec, n)

[f, Q] = deal(vec(1),  vec(2:end));
Q = reshape(Q, n, 4);

end