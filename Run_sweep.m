% Sweep tangential-velocity error and tabulate orbital elements.
% Requires init_orbit.m and CubeSatOrbitSensitivity.slx on the path.

model = 'CubeSatOrbitSensitivity';
load_system(model);

fracs = [-0.01 -0.005 -0.0025 0 0.0025 0.005 0.01];
n = numel(fracs);

perigee_km = zeros(n,1);
apogee_km  = zeros(n,1);
ecc        = zeros(n,1);
period_min = zeros(n,1);

init_orbital;   % loads mu, Re, r0, vCircular, tFinal into base workspace

for i = 1:n
    % Rebuild the initial state for this case
    v0 = [0; vCircular*(1 + fracs(i)); 0];
    x0 = [r0; v0];                          %#ok<NASGU> used by the model
    assignin('base','x0',x0);

    simOut = sim(model, 'StopTime', num2str(tFinal));

    D = squeeze(simOut.stateOut.Data);
    if size(D,1) == 6, X = D.'; else, X = D; end

    r = X(:,1:3);  v = X(:,4:6);
    rMag = vecnorm(r,2,2);  vMag = vecnorm(v,2,2);

    energy = vMag.^2/2 - mu./rMag;
    hVec = cross(r,v,2);
    eVec = cross(v,hVec,2)/mu - r./rMag;

    e = vecnorm(eVec,2,2);
    a = -mu ./ (2*energy);

    ecc(i)        = e(1);
    perigee_km(i) = (a(1)*(1-e(1)) - Re)/1000;
    apogee_km(i)  = (a(1)*(1+e(1)) - Re)/1000;
    period_min(i) = 2*pi*sqrt(a(1)^3/mu)/60;
end

results = table(fracs(:)*100, perigee_km, apogee_km, ecc, period_min, ...
    'VariableNames', {'dv_percent','perigee_km','apogee_km', ...
    'eccentricity','period_min'});
disp(results);
writetable(results, 'sweep_results.csv');

% Sensitivity plot: apsis altitudes vs. velocity error
figure;
plot(fracs*100, perigee_km, '-o', 'LineWidth',1.5); hold on;
plot(fracs*100, apogee_km,  '-s', 'LineWidth',1.5);
grid on;
xlabel('Tangential velocity error, %');
ylabel('Altitude, km');
title('Apsis Sensitivity to Deployment Velocity Error');
legend('Perigee','Apogee','Location','best');
