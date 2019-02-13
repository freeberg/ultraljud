clear all
load PostRF_Carotid.mat

postRF_Carotid = PostRF;

%Anv�nd post f�r att plotta RF data utan h�gpassfiltrering
%Ser ganska bra ut men en viss tendens till att sv�va,
% Plott igen efter egen h�gpassfiltrering 0.05
plot(postRF_Carotid.Signal(:,1))
y1 = highpass(postRF_Carotid.Signal(:,1),0.3);
y30 = highpass(postRF_Carotid.Signal(:,30),0.3);
figure
hold on
plot(y1)
plot(y30)
legend('y1','y30')
%G�r om 128 g�nger
%Sen har vi bilden
%%

%Get all 64 channel signal for all lines.
load PreRF_ImageB.mat
nrOfLines = 128;
theta = zeros(2048,64,nrOfLines);
focusDistace = zeros(2048,nrOfLines);
reflectedTravelTime = zeros(2048,64,nrOfLines);
numberOfSamplesDelay = zeros(2048,64,nrOfLines); 
reflectedTravelDistance = zeros(2048,64,nrOfLines);
newSignal = zeros(2048,nrOfLines);
for x= 1:nrOfLines
    
%     sampleDistance = preBeamformed.SoundVel/preBeamformed.SampleFreq;
%     focusDistace(1,x) = sampleDistance + 0.003;%+0.003 * preBeamformed.SoundVel;
%     for i= 2:2048
%         focusDistace(i,x) = (i-1)*sampleDistance+focusDistace(1,x);
%     end
    str = preBeamformed;
    sampleDistance = preBeamformed.SoundVel/preBeamformed.SampleFreq;
    focusDistace(1,x) = sampleDistance + str.DeadZone;
    for i= 2:2048
        focusDistace(i,x) = (i/str.SampleFreq) * str.SoundVel + str.DeadZone;
    end

    %Only need to go to 32? Since we're always it's a mirror reflection.
    for i=1:64
        for j= 1:2048
            reflectedTravelDistance(j,i,x) = sqrt(((32.5-i)*str.ElementWidth)^2 + focusDistace(j,x)^2);
            %Obtain the time it takes to travel the distance
            reflectedTravelTime(j,i,x) = reflectedTravelDistance(j,i,x) / preBeamformed.SoundVel;
            %Obtain the number of samples it takes to travel the distance
            %This is used later to know which samples we need to sum up.
            numberOfSamplesDelay(j,i,x) = round((reflectedTravelTime(j,i,x) * str.SampleFreq) );
        end
    end
    
    signal = preBeamformed.Signal(:,:,x);
    
    for i=1:2048
        sumSignal = 0;
        for j = 1:32
           j_rev = 64 + 1 - j; 
           %Difference of how many elements there are     
           %Obtain the number of samples it is delays, given how many
           %elements away it is and what focustarget (timestep, samplestep)
           %we are looking at.
           amountOfSampleDelay = numberOfSamplesDelay(i,j,x);
           
           %Catch if we try to get samples that are in the future, 
           %aka the one we are still waiting for echo but we ended the
           %sampling
           if(i+amountOfSampleDelay < 2049 && i+amountOfSampleDelay > 0)
            sumSignal = sumSignal + signal(i+amountOfSampleDelay,j);
           end
        end
        %sumSignal        
        newSignal(i,x) = sumSignal;

    end
end
%%
figure
plot(newSignal);
title('Summed signal')
newSignal_cut = newSignal(1:end,:);
newSignal_high = highpass(newSignal_cut,0.25);
figure
plot(newSignal_high);
title('Summed and highpassed signal')
Image = abs(hilbert(newSignal_high)); %where the ?postbeamformed?-variable is already filtered
figure; imagesc(Image); colormap(gray)

%%
%One line
Image = abs(hilbert(newSignal_high(:,1:10))); %where the ?postbeamformed?-variable is already filtered
figure; imagesc(Image); colormap(gray)
%%

