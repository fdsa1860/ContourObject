function X = powerNormalization(X)

X = sign(X).*(abs(X).^0.5);

end