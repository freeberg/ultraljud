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

%Get all 64 channel signal for all lines.
theta = zeros(2048,64,128);
focusDistace = zeros(2048,128);
reflectedTravelTime = zeros(2048,64,128);
numberOfSamplesDelay = zeros(2048,64,128); 
newSignal = zeros(2048,128);
for x= 1:128
   
    focusDistace(1,x) = preBeamformed.SoundVel/preBeamformed.SampleFreq;
    for i= 2:2048
        focusDistace(i,x) = focusDistace(i-1,x)+focusDistace(1,x);
    end
   

    distanceBetweenElements = 0;
    for i=1:64
        for j= 1:2048
            theta(j,i,x) = atand(distanceBetweenElements/focusDistace(j,x));
        end
        distanceBetweenElements = distanceBetweenElements + preBeamformed.Pitch;
    end

    %Only need to go to 32? Since we're always it's a mirror reflection.
    reflectedTravelDistance = zeros(2048,64,x);
    distanceBetweenElements = 0;
    for i=1:64
        for j= 1:2048
            reflectedTravelDistance(j,i,x) = sqrt(distanceBetweenElements^2 + focusDistace(j,x)^2);
        end
        distanceBetweenElements = distanceBetweenElements + preBeamformed.Pitch;
    end

    
    for i=1:64
        for j= 1:2048
            reflectedTravelTime(j,i,x) = reflectedTravelDistance(j,i,x) / preBeamformed.SoundVel;
        end
    end

    
    for i=1:64
        for j= 1:2048
            numberOfSamplesDelay(j,i,x) = round(reflectedTravelTime(j,i,x) /reflectedTravelTime(1,1,x))-j;
        end
    end
    signal = preBeamformed.Signal(:,:,x);
    
    for i=1:2048
        sumSignal = 0;
        for j = 1:64
           %Difference of how many elements there are     
           elementDiff = abs(j-32)+1;
           amountOfSampleDelay = numberOfSamplesDelay(i,elementDiff,x);
           if(i+amountOfSampleDelay < 2049)
            sumSignal = sumSignal + signal(i+amountOfSampleDelay,j);
           end
        end
        %sumSignal        
        newSignal(i,x) = sumSignal;

    end
end
figure
plot(newSignal);
title('Summed signal')
%%
newSignal_high = highpass(newSignal(:,:),0.3);
figure
plot(newSignal);
title('Summed and highpassed signal')
Image = abs(hilbert(newSignal)); %where the ?postbeamformed?-variable is already filtered
figure; imagesc(Image); colormap(gray)
