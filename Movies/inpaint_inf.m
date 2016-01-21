function Z_taped = inpaint_inf(Z)
% Inpaints inf values in Z

times = (1:size(Z,2));
Z_taped = Z;
for i = 1:size(Z,1)
    mask = ~isinf(Z(i,:));
    Z_taped(i,~mask) = interp1(times(mask), Z(i,mask), times(~mask));
end
