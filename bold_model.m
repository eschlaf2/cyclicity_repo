TR = 1; % REPETITION TIME
t = 1:TR:100; % MEASUREMENTS
h = gampdf(t,6) + -.5*gampdf(t,10); % HRF MODEL
h = h/max(h); % SCALE HRF TO HAVE MAX AMPLITUDE OF 1
 
trPerStim = [40 80 100]; % # TR PER STIMULUS
% nRepeat = 2; % # OF STIMULUS REPEATES
% nTRs = trPerStim*nRepeat + length(h);
nTRs = sum(trPerStim) + round(length(h)/2);
impulseTrain0 = zeros(1,nTRs);
 
% VISUAL STIMULUS
impulseTrainLight = impulseTrain0;
% impulseTrainLight(1:trPerStim:trPerStim*nRepeat) = 1;
impulseTrainLight(trPerStim + 1) = 1;
 
% AUDITORY STIMULUS
impulseTrainTone = impulseTrain0;
% impulseTrainTone(5:trPerStim:trPerStim*nRepeat) = 1;
impulseTrainTone(trPerStim + 5) = 1;
 
% SOMATOSENSORY STIMULUS
impulseTrainHeat = impulseTrain0;
% impulseTrainHeat(9:trPerStim:trPerStim*nRepeat) = 1;
impulseTrainHeat(trPerStim + 9) = 1;
 
% COMBINATION OF ALL STIMULI
impulseTrainAll = impulseTrainLight + impulseTrainTone + impulseTrainHeat;
 
% SIMULATE VOXELS WITH VARIOUS SELECTIVITIES
visualTuning = [4 0 0]; % VISUAL VOXEL TUNING
auditoryTuning = [0 2 0]; % AUDITORY VOXEL TUNING
somatoTuning = [0 0 3]; % SOMATOSENSORY VOXEL TUNING
noTuning = [1 1 1]; % NON-SELECTIVE
 
beta = [visualTuning', ...
        auditoryTuning', ...
        somatoTuning', ...
        noTuning'];
 
% EXPERIMENT DESIGN / STIMULUS SEQUENCE
D = [impulseTrainLight',impulseTrainTone',impulseTrainHeat'];
 
% CREATE DESIGN MATRIX FOR THE THREE STIMULI
X = conv2(D,h'); % X = D * h
X(nTRs+1:end,:) = []; % REMOVE EXCESS FROM CONVOLUTION
 
% DISPLAY STIMULUS AND DESIGN MATRICES
% subplot(121); imagesc(D); colormap gray;
% xlabel('Stimulus Condition')
% ylabel('Time (TRs)');
% title('Stimulus Train, D');
% set(gca,'XTick',1:3); set(gca,'XTickLabel',{'Light','Tone','Heat'});
%  
% subplot(122);
% imagesc(X);
% xlabel('Stimulus Condition')
% ylabel('Time (TRs)');
% title('Design Matrix, X = D * h')
% set(gca,'XTick',1:3); set(gca,'XTickLabel',{'Light','Tone','Heat'});

% SIMULATE NOISELESS VOXELS' BOLD SIGNAL
% (ASSUMING VARIABLES FROM ABOVE STILL IN WORKSPACE)
y0 = X*beta;
 
% figure;
% subplot(211);
% imagesc(beta); colormap hot;
% axis tight
% ylabel('Condition')
% set(gca,'YTickLabel',{'Visual','Auditory','Somato.'})
% xlabel('Voxel');
% set(gca,'XTick',1:4)
% title('Voxel Selectivity, \beta')
 
% subplot(212);
figure(1)
plot(y0,'Linewidth',2);
% legend({'Visual Voxel','Auditory Voxel','Somato. Voxel','Unselective'});
% xlabel('Time (TRs)'); ylabel('BOLD Signal');
xlabel('Time'); ylabel('Signal');
xlim([20 150]); ylim([-1 5]);
% title('Activity for Voxels with Different Stimulus Tuning')
set(gcf,'units','normalized','Position',[0 .5 1 .5])
set(gca,'xtick',[],'ytick',[],'box','off');
% subplot(211); colorbar

figure(2)
subplot(121);
plot(y0(40:60,1:2));
set(gca,'xtick',[],'ytick',[],'box','off');
xlabel('Time'); ylabel('Signal');
axis('tight')
ylim([-1 4.5])
% xlim([20,40])
subplot(122);
plot(y0(40:60,1),y0(40:60,2));
set(gca,'xtick',[],'ytick',[],'box','off');
xlabel('Trace 1'); ylabel('Trace 2');
