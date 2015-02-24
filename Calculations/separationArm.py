import time
import numpy as np
from scipy.interpolate import interp1d

from math import log, pi, sqrt, sin, cos
from numpy import arctan
#from matplotlib import pylab as plt
#from matplotlib import mlab as mlab

from openmdao.main.api import Assembly, Component
from openmdao.lib.datatypes.api import Float, Bool, Str
from openmdao.lib.drivers.api import CaseIteratorDriver, BroydenSolver, NewtonSolver
from openmdao.lib.casehandlers.api import BSONCaseRecorder, CaseDataset


class pendulum(Component):
    """ Calculate final angular velocity and tilt after t_diff """
    #--Inputs--
    bfs_height = Float(0.3556, units='m', iotype='in', desc="BFS height (y direction, pin to bottom of BFS)")
    bfs_width = Float(0.635, units='m', iotype='in', desc="BFS width (x direction)")

    # inputs
    t_diff = Float( units='s', iotype='in', desc="time between pin releases")
    g = Float(9.81, units='m/s**2', iotype='in', desc="gravity")
    n = Float(10000, iotype='in', desc="number of time steps")
    t_0 = Float(0, iotype='in', desc="number of time steps")
    alpha_0 = Float(0, units='rad/s**2', iotype='in', desc="initial angular acceleration")
    omega_0 = Float(0, units='rad/s**2', iotype='in', desc="initial angular velocity")
    
    # outputs
    inertia = Float(units='m**2',iotype='out',desc="moment of inertia divided by mass in kg")
    theta_0 = Float(units='rad', iotype='out', desc="initial angle", low=0, high=pi)
    R_pendulum = Float(units='m', iotype='out', desc="distance from CG to sep pin", low=0, high=4)
    t_step = Float(iotype='out', desc='time interval', low=0, high=0.1)
    alpha = Float(units='rad/s**2', iotype='out', desc="release angular acceleration")
    omega = Float(units='rad/s**2', iotype='out', desc="release angular velocity")
    theta = Float(units='rad', iotype='out', desc="release angle", low=-pi, high=pi)

    def execute(self):
        """Calculate Various Paramters"""
        #geom calcs
        self.theta_0 = arctan((self.bfs_width/2.)/self.bfs_height)
        self.R_pendulum = sqrt(self.bfs_width/2**2+self.bfs_height**2) #pythag theorem 

        #dynamics calcs
        #self.inertia = self.R_pendulum**2  #idealized pendulum
        #self.inertia = ((self.bfs_width**2 + self.bfs_height**2)/12) + ((self.bfs_width/2)+self.bfs_height) #rough calc
        self.inertia = 0.25 #see Tom Cressman's excel spreadsheet
        self.alpha = self.alpha_0 #initial conditions = 0
        self.omega = self.omega_0 #initial conditions = 0
        self.theta = self.theta_0 #initial conditions = 0
        self.t_step = (self.t_diff - self.t_0)/self.n

        #crude time marching, rather than RK4, 10000 time steps.
        while(self.t_0 < self.t_diff): #march slowly in time. alpha = (-gR/I)sin(theta)
            self.omega = self.omega + self.t_step*(-self.g*self.R_pendulum/self.inertia)*sin(self.theta) # update velocity
            self.theta = self.theta + self.omega*self.t_step # update position
            self.t_0 = self.t_0 + self.t_step # update time
               

class swing(Component):
    #geometry
    agu_height = Float(0.4826, units='m', iotype='in', desc="AGU Height (y direction, pin to top of drogue)")
    agu_width = Float(0.4064, units='m', iotype='in', desc="AGU width (x direction)")
    #sep_length = Float(0.0381, units='m', iotype='in', desc="x-distance from pin to AGU")
    bfs_width = Float(0.635, units='m', iotype='in', desc="BFS width (x direction)")
    #dynamic
    omega = Float(units='rad/s**2', iotype='in', desc="release angular velocity")
    theta = Float(units='rad', iotype='in', desc="release angle")
    R_pendulum = Float(units='m', iotype='in', desc="distance from CG to sep pin")
    g = Float(9.81, units='m/s**2', iotype='in', desc="gravity")
    
    theta_0 = Float(pi/4, units='rad', iotype='in', desc="initial angle")

    #outputs
    y_margin = Float(units='m', iotype='out', desc="y distance from drogue corner to sep at pin release", low=0, high=10)
    x_margin = Float(units='m', iotype='out', desc="x distance from drogue corner to sep at pin release", low=-1, high=1)

    k_theta_0 = Float(units='rad', iotype='out', desc="initial top angle", low=0, high=pi)
    k = Float(units='m', iotype='out', desc="x distance from drogue corner to pivot point",low=0, high=10)
    k_theta = Float(units='rad', iotype='out', desc="rotated top angle", low=-pi, high=pi)

    velocity = Float(units='m/s', iotype='out', desc="tangential velocity")
    x_veloc = Float( units='m/s', iotype='out', desc="tangential velocity")
    t_drop = Float(units='s', iotype='out', desc="time to fully clear Y height (with just Y movement)")
    x_dist = Float(units='m', iotype='out', desc="x distance from drogue corner to sep at clearance point")

    def execute(self):
        """Calculate Various Paramters"""

        self.velocity = self.omega * self.R_pendulum
        self.x_veloc = self.velocity * sin(self.theta)
        self.y_veloc = self.velocity * cos(self.theta)
        v = self.y_veloc #vertical velocity

        #distance BFS pivot corner to opposite drogue corner
        #recalulate corner point relative to separation arm
        self.k_theta_0 = arctan(((self.bfs_width/2) + (self.agu_width/2)) / self.agu_height)
        self.k = sqrt(((self.bfs_width/2) + (self.agu_width/2))**2 + (self.agu_height**2))
        self.k_theta = self.k_theta_0 + (self.theta_0-self.theta)

        self.x_margin = self.bfs_width - self.k*sin(self.k_theta)
        self.y_margin = self.k*sin(self.k_theta)

        # free fall h = 1/2*g*t^2 + v_0t, solve for t, quadratic formula
        #self.t_drop = v-sqrt(v**2-(2*self.g*self.y_margin)/self.g)
        self.t_drop = sqrt(2*self.y_margin/self.g)

        self.x_dist =  (self.x_veloc * self.t_drop) + self.x_margin

class system(Assembly):

    def configure(self): 
        #Add Components
        self.add('swing', swing())
        self.add('pendulum', pendulum())
        driver = self.add('driver', BroydenSolver())
        #driver.add_parameter('pendulum.t_diff',low=0.,high=10.)
        #driver.add_constraint('swing.x_dist=0')

        driver.workflow.add(['pendulum', 'swing'])

        #Boundary Input Connections
        self.connect('pendulum.theta_0','swing.theta_0')
        self.connect('pendulum.theta','swing.theta')
        self.connect('pendulum.omega','swing.omega')
        #self.connect('pendulum.alpha','swing.alpha')
        self.connect('pendulum.R_pendulum','swing.R_pendulum')


if __name__ == '__main__' and __package__ is None:

    #top = system()
    pen = pendulum()
    pen.t_diff = 0.0642 #modify here 0.0642 original
    bfs_width = 0.635 #modify here 0.635 original
    pen.bfs_width = bfs_width

    #initial run to converge things
    pen.run()

    print "-------   -------"
    print "t_diff: ", pen.t_diff , "seconds"
    print "theta_0: ", pen.theta_0 , "rad"
    print "theta : ", pen.theta , "rad"
    print "omega : ", pen.omega , "rad/s"
    print "inertia/m:", pen.inertia

    sw = swing()
    #sw.sep_length = 0.03
    sw.theta_0 = pen.theta_0
    sw.theta = pen.theta
    sw.omega = pen.omega
    sw.R_pendulum = pen.R_pendulum
    sw.bfs_width = bfs_width
    sw.run()

    print "k_theta_0", sw.k_theta_0, 'rad'
    print  "y_margin: ", sw.y_margin, 'm'
    print "x_margin: " ,  sw.x_margin, 'm'
    print "x_veloc: " ,  sw.x_veloc, 'm/s'
    print "t_drop: " ,  sw.t_drop, 's'
    print "x_Dist: " ,  sw.x_dist, 'm'

    actuator_speed = 0.00889 #m/s
    print
    print "pin margin: ", actuator_speed*pen.t_diff*1000, "mm"


