import time
import numpy as np

from math import log, pi, sqrt, sin, cos
from numpy import arctan, interp
#from matplotlib import pylab as plt
#from matplotlib import mlab as mlab

from openmdao.main.api import Assembly, Component
from openmdao.lib.datatypes.api import Float, Bool, Str, Array
from openmdao.lib.drivers.api import CaseIteratorDriver, BroydenSolver, NewtonSolver
from openmdao.lib.casehandlers.api import BSONCaseRecorder, CaseDataset


class MotionEQ(Component):
    """Motion EQ calculates the falling speed of the gondola"""

    # inputs
    m = Float(100.0, units='kg', iotype='in', desc='mass of box')
    Cd = Float(0.8, iotype='in', desc='Coefficient of Drag http://www.engineeringtoolbox.com/drag-coefficient-d_627.html')
    A = Float(0.23, units='m**2', iotype='in', desc='cross sectional area')
    pitot_A = Float(7, iotype='in', desc='pitot tube cross area') #0.004516 m^2

    g = Float(9.81, units='m/s**2', iotype='in', desc='gravity')
    t_step = Float(0.01, iotype='in', desc='time step', low=0, high=0.1)
    max_alt = Float(36576, units='m',iotype='in', desc='starting altitude')

    # http://www.engineeringtoolbox.com/standard-atmosphere-d_604.html
    rho_table = np.array([12.25, 11.12, 10.07,9.093,8.194,7.364,6.601,5.9,5.258, \
        4.671,4.135,1.948,0.8891,0.4008,0.1841,0.03996])
    alt_table = np.array([0.0,1000.,2000.,3000.,4000.,5000.,6000.,7000.,8000.,9000., \
        10000.,15000.,20000.,25000.,30000., 40000.])
    temp_table = np.array([15,8.5,2,-4.49,-10.98,-17.47,-23.96,-30.45,-36.94,-43.42,-49.9,-56.5,-51.6,-46.64])

    alt2_table = np.array([0,11000.,20000.,30000.])
    SOS_table = np.array([340,295,295,301])

    # outputs
    rho = Float(0.0, iotype='out', desc='density of air')

    q = Float(0.0, iotype='out', desc='dynamic pressure')
    maxQ = Float(0.0, iotype='out', desc='max dynamic pressure')
    maxQ_a = Float(0.0, iotype='out', desc='alitutde at maxQ')
    maxV = Float(0.0, iotype='out', desc='max velocity')
    maxV_a = Float(0.0, iotype='out', desc='altitude at maxV')
    MN = Float(0.0, iotype='out', desc='Mach Number')
    maxMN = Float(0.0, iotype='out', desc='max Mach Number')
    maxMN_a = Float(0.0, iotype='out', desc='alt at Mach Number')


    F_drag = Float(0.0, iotype='out', desc='drag force')
    alt = Float(0.0, units='m', iotype='out', desc='altitude (position) of box')
    veloc = Float(0.0, iotype='out', desc='velocity of box')
    accel = Float(0.0, iotype='out', desc='acceleration of box')

    def execute(self):

        self.maxQ = self.q
        self.maxV = self.veloc
        self.alt = self.max_alt
        while(self.alt > 0): #march slowly in time.

            self.rho = interp(self.alt,self.alt_table, self.rho_table)
            self.q = 0.5*self.rho*(self.veloc**2)
            self.F_drag = self.q*self.Cd*self.A
            self.accel = ((self.g*self.m) - self.F_drag)/self.m
            self.veloc = self.veloc + self.accel*self.t_step
            self.alt = self.alt - self.veloc*self.t_step

            self.MN = self.veloc / np.interp(self.alt,self.alt2_table,self.SOS_table)

            #print self.alt, self.q, self.veloc, self.MN

            if (self.q > self.maxQ):
                self.maxQ = self.q
                self.maxQ_a = self.alt
            if (self.veloc > self.maxV):
                self.maxV = self.veloc
                self.maxV_a = self.alt
            if (self.MN > self.maxMN):
                self.maxMN = self.MN
                self.maxMN_a = self.alt


if __name__ == '__main__' and __package__ is None:

    meq = MotionEQ()

    #initial run to converge things
    meq.run()

    print "------- Results -------"
    print "MaxQ: ", meq.maxQ, " at altitude: ", meq.maxQ_a
    print "Max Velocity: ", meq.maxV, " at altitude: ", meq.maxV_a
    print "Max MN: ", meq.maxMN, " at altitude: ", meq.maxMN_a
    print
    print "Max psi on Pitot tube: ", meq.maxQ*0.000145037738
    print "Max lbf exerted on Pitot tube: ", meq.maxQ*0.000145037738*meq.pitot_A
