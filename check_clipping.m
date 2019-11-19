function y = check_clipping(y)

if any(abs(y(:))>1)
    error('Clipping');
end