%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hillslope model revisited
% hang deng feb 28 2016
% add channel incision 10mm/yr at the both edges of the hillslope
% added Hedge, run steps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
figure(1)
clf

%% initialize
% parameters used
rhos = 1600; % density of soil
rhor = 2700; % density of underlying rock 
w = 0.01; % release rate (m/yr) from rock to soil, constant soil
% production
zinc_channel = 0.01; % annual channel incision, 10mm/yr, exaggerated
kappa = 0.01; % transport coefficient
H0 = 1; % meter starting regolith
Hstar = 0.6; % soil production decay coefficient, meter

% time steps
tmax = 5E3; % maximum run 5000 years
dt = 10; % time step
t = 0:dt:tmax;

% x steps
xmax = 3000;
dx = 30;
x = -xmax:dx:xmax;

% initial topography, parabolic
zb = -(1e-4)*x.^2 + 1500;

% create arrays
H = zeros(size(x)); 
z = zb + H;

nplot = 50;
tplot = tmax/nplot;

%% loop
for i = 1:length(t)
    
    %interpolates ice thickness to cell edges
    Hedge = H(1:end-1)+0.5*diff(H); 
    dzdx = diff(z)/dx; % slope
    
    % discharge
    Q = -kappa*abs(dzdx).*(1-exp(-Hedge/Hstar));
    Q =[Q(1) Q Q(1)]; %takes care of boundary conditions 
    
    dqdx = diff(Q)/dx;
    
    %dHdt = (rhor/rhos)*w-(1/rhos)*dqdx;
    dHdt = (rhor/rhos)*w-(1/rhos)*abs(dqdx);
    % update soil thickness
    H =H + (dHdt*dt);

    % update bedrock elevation due to channel incision
    zb = zb - w*dt; %- zincision*dt;
    % channel incision at the edges of the hillslope
    zb(1) = zb(1)-zinc_channel*dt;
    zb(end) = zb(end)-zinc_channel*dt;
    %zb(1:3) = zb(1:3)-zinc_channel*dt;
    %zb(end-3:end) = zb(end-3:end)-zinc_channel*dt;
    % update total elevation
    z = zb + H; % total thickness = bedrock + soil

    
    % plotting
    if rem(t(i),tplot)==0
        disp(['Time: ' num2str(t(i))]);
        figure(1)
        %subplot(2,1,1)
        plot(x/1000,z,'r','linewidth',2);
        hold on
        plot(x/1000,zb,'g--','linewidth',1);
        xlabel('Distance (km)','Fontsize',12);
        ylabel('Elevation (m)','Fontsize',12);
        %ylim([0, 5000]);
        pause(0.1);
        hold off
        
        %subplot(2,1,2)
        %plot(x/1000,H,'b','linewidth',2);
       % hold on
        %xlabel('Distance (km)','Fontsize',12);
        %ylabel('Soil thickness (m)','Fontsize',12);
        %pause(0.1);
        %hold off
    
    end
end