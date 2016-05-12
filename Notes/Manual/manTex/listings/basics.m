% Generate data and analyze
[toy_data,ss] = create_toy('periodic','rois',30,'shift',10);
[phases, eperms, slm, evals] = analyze_cyclicity(toy_data);

% Plot phases
figure;
subplot(121)
plot(phases{1}(ss));
subplot(122)
plot(phases{1}(eperms{1}));

% Plot evals