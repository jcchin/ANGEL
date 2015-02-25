t_diff = 0.0642  ;%units='s', iotype='in', desc="time between pin releases")
bfs_width = 0.635;%, units='m', iotype='in', desc="BFS width (x direction)")

%--------------------------

bfs_height = 0.3556;%, units='m', iotype='in', desc="BFS height (y direction, pin to bottom of BFS)")
g = 9.81;%, units='m/s**2', iotype='in', desc="gravity")
n = 10000;%, iotype='in', desc="number of time steps")
t_0 = 0;%, iotype='in', desc="number of time steps")
alpha_0 = 0;%, units='rad/s**2', iotype='in', desc="initial angular acceleration")
omega_0 = 0;%, units='rad/s**2', iotype='in', desc="initial angular velocity")

%%# outputs
%inertia = units='m**2',iotype='out',desc="moment of inertia divided by mass in kg")
%theta_0 = units='rad', iotype='out', desc="initial angle", low=0, high=pi)
%R_pendulum = units='m', iotype='out', desc="distance from CG to sep pin", low=0, high=4)
%t_step = iotype='out', desc='time interval', low=0, high=0.1)
%alpha = units='rad/s**2', iotype='out', desc="release angular acceleration")
%omega = units='rad/s**2', iotype='out', desc="release angular velocity")
%theta = units='rad', iotype='out', desc="release angle", low=-pi, high=pi)

%def execute(self):
%"""Calculate Various Paramters"""
%%#geom calcs
theta_0 = atan((bfs_width/2.)/bfs_height);
R_pendulum = sqrt((bfs_width/2)^2+(bfs_height)^2); %#pythag theorem 

%#dynamics calcs
%#inertia = R_pendulum**2  %#idealized pendulum
%#inertia = ((bfs_width**2 + bfs_height**2)/12) + ((bfs_width/2)+bfs_height) %#rough calc
inertia = 0.25; %%#see Tom Cressman's excel spreadsheet
alpha = alpha_0; %#initial conditions = 0
omega = omega_0; %#initial conditions = 0
theta = theta_0; %#initial conditions = 0
t_step = (t_diff - t_0)/n;

%#crude time marching, rather than RK4, 10000 time steps.
while(t_0 < t_diff) %#march slowly in time. alpha = (-gR/I)sin(theta)
    omega = omega + t_step*(-g*R_pendulum/inertia)*sin(theta); %# update velocity
    theta = theta + omega*t_step; %# update position
    t_0 = t_0 + t_step; %# update time
end

%#geometry
agu_height = 0.4826;%, units='m', iotype='in', desc="AGU Height (y direction, pin to top of drogue)")
agu_width = 0.4064;%, units='m', iotype='in', desc="AGU width (x direction)")
%#sep_length = 0.0381, units='m', iotype='in', desc="x-distance from pin to AGU")
bfs_width = 0.635;%, units='m', iotype='in', desc="BFS width (x direction)")
%#dynamic

%#outputs
%y_margin = %units='m', iotype='out', desc="y distance from drogue corner to sep at pin release", low=0, high=10)
%x_margin = %units='m', iotype='out', desc="x distance from drogue corner to sep at pin release", low=-1, high=1)
%k_theta_0 = %units='rad', iotype='out', desc="initial top angle", low=0, high=pi)
%k = %units='m', iotype='out', desc="x distance from drogue corner to pivot point",low=0, high=10)
%k_theta = %units='rad', iotype='out', desc="rotated top angle", low=-pi, high=pi)
%velocity = %units='m/s', iotype='out', desc="tangential velocity")
%x_veloc =  %units='m/s', iotype='out', desc="tangential velocity")
%t_drop = %units='s', iotype='out', desc="time to fully clear Y height (with just Y movement)")
%x_dist = %units='m', iotype='out', desc="x distance from drogue corner to sep at clearance point")

velocity = omega * R_pendulum;
x_veloc = velocity * sin(theta);
y_veloc = velocity * cos(theta);
v = y_veloc; %#vertical velocity

%#distance BFS pivot corner to opposite drogue corner
%#recalulate corner point relative to separation arm
k_theta_0 = atan(((bfs_width/2) + (agu_width/2)) / agu_height);
k = sqrt(((bfs_width/2) + (agu_width/2))^2 + (agu_height^2));
k_theta = k_theta_0 + (theta_0-theta);

x_margin = bfs_width - k*sin(k_theta);
y_margin = k*sin(k_theta);

%# free fall h = 1/2*g*t^2 + v_0t, solve for t, quadratic formula
%#t_drop = v-sqrt(v**2-(2*g*y_margin)/g)
t_drop = sqrt(2*y_margin/g);

x_dist =  (x_veloc * t_drop) + x_margin;

t_diff = 0.0642; %#modify here 0.0642 original
bfs_width = 0.635; %#modify here 0.635 original
bfs_width = bfs_width;


disp('-------   -------')
disp(['t_diff: ' num2str(t_diff) ' seconds'])
disp(['theta_0: ' num2str(theta_0)  'rad'])
disp(['theta : ' num2str(theta)  'rad'])
disp(['omega : ' num2str(omega)  'rad/s'])
disp(['inertia/m:' num2str(inertia)])

disp(['k_theta_0' num2str(k_theta_0) 'rad'])
disp(['y_margin: ' num2str(y_margin) 'm'])
disp(['x_margin: '   num2str(x_margin) 'm'])
disp(['x_veloc: '   num2str(x_veloc) 'm/s'])
disp(['t_drop: '   num2str(t_drop) 's'])
disp(['x_Dist: '   num2str(x_dist) 'm'])

actuator_speed = 0.00889; %#m/s
disp(['pin margin: ' num2str(actuator_speed*t_diff*1000) 'mm'])


