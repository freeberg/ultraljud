% Beamforming_script
clear variables

% Loading variables
A = load('PreRF_ImageA.mat');
A = A.preBeamformed;
B = load('PreRF_ImageB.mat');
B = B.preBeamformed;
C = load('PreRF_ImageC.mat','preBeamformed');
C = C.preBeamformed;
Carotid = load('PostRF_Carotid.mat');
Carotid = Carotid.PostRF;
Phantom = load('PostRF_Phantom.mat');
Phantom = Phantom.PostRF
A_imread = imread('Image A.png');
B_imread = imread('Image B.png');

%% Beamformed data eval:
figure(1)
subplot(1,3,2)
% example code
Image = abs(hilbert(Phantom.Signal));
imagesc(Image); colormap(gray)
subplot(1,3,1)
imagesc(B_imread)
[Bf,Af] = butter(9,.05,'high');
Y = zeros(size(Phantom.Signal));
[Bf2,Af2] = butter(9,.3,'Low');
for i = 1:128
    Y(:,i) = filtfilt(Bf,Af,double(Phantom.Signal(:,i)));
    Y(:,i) = filtfilt(Bf2,Af2,double(Y(:,i)));
end
subplot(1,3,3)
Image = abs(hilbert(Y));
imagesc(Image); colormap(gray)


figure(2)
hold off
plot(Phantom.Signal(:,56))
hold on
plot(Y(:,56));


%% prebeamformed eval
figure(3)
subplot(1,3,1)

ThreeToTwo=squeeze(sum(A.Signal,2));
Image2=abs(hilbert(ThreeToTwo));
imagesc(Image2); colormap(gray)
title('A no processing')
figure(3)
subplot(1,3,2)

ThreeToTwo=squeeze(sum(B.Signal,2));
Image2=abs(hilbert(ThreeToTwo));
imagesc(Image2); colormap(gray)
title('B no processing')
figure(3)
subplot(1,3,3)

ThreeToTwo=squeeze(sum(C.Signal,2));
Image2=abs(hilbert(ThreeToTwo));
imagesc(Image2); colormap(gray)
title('C no processing')

%%

J = 2048;% nmbr of samples
I = 64; % number of elements
Lines = zeros(size(squeeze(A.Signal(:,1,:))));
cou = 0;
for k = 1:128 %line number
    
    t_off = A.DeadZone/A.SoundVel;
    % z = focal point distance
    z0= A.DeadZone;
    z = @(j) z0 + (j/A.SampleFreq)*A.SoundVel;
    % x = base of line <-> element distance
    x = @(i) (I/2+.5-i)*A.ElementWidth;
    % r = reflected distance (focal point to element i)
    r = @(i,j) sqrt(x(i).^2 + z(j).^2);
    % dist = total traveleled distance of wave hitting focal point then element.
    dist = @(i,j) z(j)+r(i,j);
    
    for j=1:J
        for i = 1:I/2
            i_rev = I+1-i;
            t = dist(i,j)/A.SoundVel - 2*t_off;
            j_new = ceil( (t*A.SampleFreq));
            if j_new <2049
                Lines(j,k) = Lines(j,k) + A.Signal(j_new,i,k) + A.Signal(j_new,i_rev,k);
                if j > 950
                    j_new;
                end
            end
        end
    end

end

figure(4)
title('Unfiltered signal')
Image = abs(hilbert(Lines));
imagesc(Image); colormap(gray)
%Filtering
for i = 1:128
    Y(:,i) = filtfilt(Bf,Af,double(Phantom.Signal(:,i)));
    Y(:,i) = filtfilt(Bf2,Af2,double(Y(:,i)));
end

