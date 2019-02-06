x = [1:0.01:64];
norm = normpdf(x,32,32);
plot(norm)
norm(32)
r = normrnd(32,16)