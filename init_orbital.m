% Earth and orbit constants
mu = 3.986004418e14;      % Earth gravitational parameter, m^3/s^2
Re = 6378.137e3;          % Earth equatorial radius, m

% Nominal CubeSat deployment conditions
h0 = 400e3;               % Initial altitude, m
r0 = [Re + h0; 0; 0];     % Initial position vector, m

vCircular = sqrt(mu / norm(r0));

% Change this value during the sensitivity study
dvFrac = 0.00;             % Fractional tangential-velocity error

% Tangential velocity: nominal orbit moves in +y direction
v0 = [0; vCircular*(1 + dvFrac); 0];

% Six-state initial condition: [x y z vx vy vz]'
x0 = [r0; v0];

tFinal = 6000;            % About one 400 km orbit, seconds