CubeSat Two-Body Orbit Propagator and Deployment Sensitivity Study
A six-state orbit propagator built from the two-body equations of motion in Simulink, verified against closed-form orbital mechanics, and used to quantify how a fraction-of-a-percent tangential velocity error at CubeSat deployment propagates into perigee, apogee, eccentricity, and orbital period.

Author: Saaketh Sriram · Purdue University, Aeronautical & Astronautical Engineering Tools: MATLAB / Simulink R2026a
Repository contents
File
Purpose
init_orbital.m
Constants, initial conditions, and the dvFrac study parameter
CubeSatOrbitSensitivity.slx
Simulink model — six-state two-body propagator
analyze_orbit.m
Extracts orbital elements, runs verification checks, generates plots
run_sweep.m
Automates the dvFrac sweep and writes sweep_results.csv
figures/
Exported plots referenced above




Problem statement
A CubeSat dispenser cannot deploy a spacecraft at exactly the intended velocity. Spring-based deployers have tolerances, and the host vehicle itself has insertion error. This project asks a specific question:

If a CubeSat intended for a 400 km circular orbit leaves the dispenser with a small tangential velocity error, how much does the resulting orbit differ from the target?

The answer is used to build intuition for why Δv budgeting dominates mission planning: a velocity error applied at one point on an orbit produces almost no change there, and its full effect on the opposite side.


Model
The propagator integrates the two-body equations of motion in an Earth-centered inertial frame:

ṙ = v

v̇ = −μ r / ‖r‖³

where

Symbol
Meaning
Value / units
μ
Earth standard gravitational parameter (GM)
3.986004418 × 10¹⁴ m³/s²
Rₑ
Earth equatorial radius (WGS-84)
6378.137 km
r
Position vector, Earth center to spacecraft
m
v
Inertial velocity vector
m/s
dvFrac
Fractional tangential velocity error at deployment
dimensionless


The Simulink model is a single closed loop: one Integrator carries all six states [x y z vx vy vz]ᵀ, a MATLAB Function block computes the state derivative, and the derivative feeds back to the Integrator input. A To Workspace block logs the state history.

Solver configuration

Setting
Value
Solver type
Variable-step
Solver
ode45
Stop time
tFinal (6000 s, ≈ 1.08 orbits)
Max step size
10 s
Relative tolerance
1e-10
Absolute tolerance
1e-6


The tightened relative tolerance matters. Position states are on the order of 7 × 10⁶ m, so Simulink's default RelTol of 1e-3 admits kilometres of numerical drift per orbit and makes the energy conservation check meaningless.


Verification
The two-body problem conserves specific orbital energy and specific angular momentum exactly, so any drift in either is pure integration error. Three independent checks were run on the nominal case:

Check
Result
Interpretation
Orbital period vs. closed-form 2π√(a³/μ)
92.56 min
Matches analytic value
Specific energy drift over one orbit
6.957 × 10⁻¹¹ %
Negligible
Specific angular momentum drift
3.477 × 10⁻¹¹ %
Negligible
Eccentricity, nominal circular case
0.00000
Circular orbit stays circular


A vis-viva cross-check (v² = μ(2/r − 1/a)) is included in analyze_orbit.m and agrees with the propagated speed to within numerical precision.


Results
Circular velocity at 400 km altitude is 7668.6 m/s, so a 0.25 % error is approximately 19 m/s.

Case
Δvₜ
Perigee (km)
Apogee (km)
Eccentricity
Period (min)
Nominal
0 %
400.0
400.0
0.00000
92.56
Fast insertion
+0.25 %
400.0
468.2
0.00501
93.26
Slow insertion
−0.25 %
332.6
400.0
0.00499
91.87
Fast insertion
+0.50 %
400.0
537.3
0.01003
93.97
Slow insertion
−0.50 %
266.1
400.0
0.00998
91.19
Fast insertion
+1.0 %
400.0
678.1
0.02010
95.42
Slow insertion
−1.0 %
135.5
400.0
0.01990
89.87


Limitations
Sensitivity is roughly linear in Δvₜ for errors of this magnitude, since the orbit remains near-circular and the perturbation is small compared to circular velocity.
The slow case has an operational consequence this model does not capture. A depressed perigee sweeps denser atmosphere once per revolution, accelerating orbital decay and shortening mission lifetime — a real effect at 400 km that requires a drag model to quantify.
