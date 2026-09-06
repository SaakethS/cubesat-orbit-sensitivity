% Extract Simulink output
stateOut = out.stateOut;      % lowercase s, both places

t = stateOut.Time;            % capital T
D = squeeze(stateOut.Data);   % capital D

% Make sure rows correspond to time samples
if size(D,1) == 6
    X = D.';
else
    X = D;
end

r = X(:,1:3);
v = X(:,4:6);

rMag = vecnorm(r,2,2);    % orbital radius, m
vMag = vecnorm(v,2,2);    % speed, m/s

altitude_km = (rMag - Re)/1000;

% Specific orbital energy (energy per unit mass), J/kg
energy = vMag.^2/2 - mu./rMag;

% Specific angular momentum and eccentricity vector
hVec = cross(r,v,2);
eVec = cross(v,hVec,2)/mu - r./rMag;
eccentricity = vecnorm(eVec,2,2);

% Orbital parameters
a  = -mu ./ (2*energy);              % semi-major axis, m
rp = a .* (1 - eccentricity);        % perigee radius, m
ra = a .* (1 + eccentricity);        % apogee radius, m

perigee_km = (rp(1) - Re)/1000;
apogee_km  = (ra(1) - Re)/1000;
period_min = 2*pi*sqrt(a(1)^3/mu)/60;

fprintf("Eccentricity:     %.5f\n", eccentricity(1));
fprintf("Perigee altitude: %.1f km\n", perigee_km);
fprintf("Apogee altitude:  %.1f km\n", apogee_km);
fprintf("Orbital period:   %.2f min\n", period_min);

% --- Added: numerical quality metrics -------------------------
energyDrift = abs((energy(end)-energy(1))/energy(1))*100;   % percent
hDrift = abs((vecnorm(hVec(end,:),2,2)-vecnorm(hVec(1,:),2,2)) ...
    / vecnorm(hVec(1,:),2,2))*100;
fprintf("Energy drift:     %.3e %%\n", energyDrift);
fprintf("Ang. mom. drift:  %.3e %%\n", hDrift);
% --------------------------------------------------------------

% Orbit plot
theta = linspace(0,2*pi,300);

figure;
plot(Re/1000*cos(theta), Re/1000*sin(theta),'k','LineWidth',1.5);
hold on;
plot(r(:,1)/1000, r(:,2)/1000,'b','LineWidth',1.5);
axis equal; grid on;
xlabel('x, km'); ylabel('y, km');
title('CubeSat Two-Body Orbit Propagation');
legend('Earth','CubeSat trajectory','Location','best');

% Altitude history
figure;
plot(t/60,altitude_km,'LineWidth',1.5);
grid on;
xlabel('Time, min'); ylabel('Altitude, km');
title('CubeSat Altitude vs. Time');

% Energy check
figure;
plot(t/60,energy,'LineWidth',1.5);
grid on;
xlabel('Time, min'); ylabel('Specific orbital energy, J/kg');
title('Numerical Energy Check');
% Vis-viva cross-check at the final sample
vVisViva = sqrt(mu*(2/rMag(end) - 1/a(end)));
relErr   = abs(vVisViva - vMag(end))/vMag(end);
fprintf("Vis-viva speed:   %.6f m/s (sim: %.6f, rel err %.2e)\n", ...
    vVisViva, vMag(end), relErr);

% Closed-form period cross-check
fprintf("Analytic period:  %.4f min\n", 2*pi*sqrt(a(end)^3/mu)/60);
