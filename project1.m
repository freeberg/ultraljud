clear all
load PostRF_Carotid.mat

postRF_Carotid = PostRF;

%Anvönd post för att plotta RF data utan högpassfiltrering
%Ser ganska bra ut men en viss tendens till att sväva,
% Plott igen efter egen högpassfiltrering 0.05
plot(postRF_Carotid.Signal(:,1))
y1 = highpass(postRF_Carotid.Signal(:,1),0.3);
y30 = highpass(postRF_Carotid.Signal(:,30),0.3);
figure
hold on
plot(y1)
plot(y30)
legend('y1','y30')
%plot(postRF_Carotid.Signal(1,:),postRF_Carotid.Signal(:,1),'.')
%Avbilda en linje
%64 linjer använder den sig av 2048*64 
%Räkna ut gångvägar, tid och samplingsfrekvenser
load preRF_ImageA.mat
postRF_ImageA = PostRF;
%plot(postRF_ImageA.Signal(:,1))
%Varje punkt summering av 64 
%Gör om 128 gånger
%Sen har vi bilden
%%
focusDistace = zeros(2048,1);
focusDistace(1) = preBeamformed.SoundVel/preBeamformed.SampleFreq;
for i= 2:2048
    focusDistace(i) = focusDistace(i-1)+focusDistace(1);
end
theta = zeros(2048,64);

distanceBetweenElements = 0;
for i=1:64
    for j= 1:2048
        theta(j,i) = atand(distanceBetweenElements/focusDistace(j));
    end
    distanceBetweenElements = distanceBetweenElements + preBeamformed.Pitch;
end

%Only need to go to 32? Since we're always it's a mirror reflection.
reflectedTravelDistance = zeros(2048,64);
distanceBetweenElements = 0;
for i=1:64
    for j= 1:2048
        reflectedTravelDistance(j,i) = sqrt(distanceBetweenElements^2 + focusDistace(j)^2);
    end
    distanceBetweenElements = distanceBetweenElements + preBeamformed.Pitch;
end

reflectedTravelTime = zeros(2048,64);
for i=1:64
    for j= 1:2048
        reflectedTravelTime(j,i) = reflectedTravelDistance(j,i) / preBeamformed.SoundVel;
    end
end
 
numberOfSamplesDelay = zeros(2048,64); 
for i=1:64
    for j= 1:2048
        numberOfSamplesDelay(j,i) = round(reflectedTravelTime(j,i) /reflectedTravelTime(1,1)-j);
    end
end
%Get all 64 channel signal for one line.
signal = preBeamformed.Signal(:,:,1);
newSignal = zeros(2048,1);
for i=1:2048
    sumSignal = 0;
    for j = 1:64
       %Difference of how many elements there are     
       elementDiff = abs(j-32)+1;
       amountOfSampleDelay = numberOfSamplesDelay(i,elementDiff);
       if(i+amountOfSampleDelay < 2049)
        sumSignal = sumSignal + signal(i+amountOfSampleDelay,j);
       end
    end
    newSignal(i) = sumSignal;
    
end
figure
plot(newSignal);
title('Summed signal')
