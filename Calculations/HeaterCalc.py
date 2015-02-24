import time
import numpy as np
from scipy.interpolate import interp1d

from math import log, pi, sqrt, e, isnan
#from matplotlib import pylab as plt
#from matplotlib import mlab as mlab

from openmdao.main.api import Assembly, Component
from openmdao.lib.datatypes.api import Float, Bool, Str
from openmdao.lib.drivers.api import CaseIteratorDriver, BroydenSolver, NewtonSolver
from openmdao.lib.casehandlers.api import BSONCaseRecorder, CaseDataset

class HeaterSystem(Assembly): 
    """ Solver Assembly """ 

    temp_boundary = Float(0, units = 'K', iotype="out", desc="final equilibirum tube wall temperature")
    temp_ambient = Float(322.0, units = 'K', iotype='in', desc='Average Temperature of the outside air')
    Nu_multiplier = Float(1, iotype='in', desc='fudge factor to switch convection on and off')

    def configure(self): 
        #Add Components
        self.add('heater', HeaterCalcs())
        driver = self.add('driver', NewtonSolver())
        driver.add_parameter('heater.temp_boundary',low=0.,high=500.)
        driver.add_constraint('heater.ss_temp_residual=0')
        driver.workflow.add(['heater'])

        #Boundary Input Connections
        self.connect('heater.temp_boundary','temp_boundary')
        self.connect('heater.temp_ambient','temp_ambient')
        self.connect('heater.Nu_multiplier','Nu_multiplier')

class HeaterCalcs(Component):
    """ Heat Balance """

    #--Inputs--
    desired_temp = Float(300, units='K', iotype='in')
    batt_area = Float(.145,units='m**2',iotype='in', desc='battery surface area') #.16 = 225in^2
    emissivity = Float(0.5, iotype="in", desc='Emmissivity of the box') #
    waste_heat = Float(0.5, units='W', iotype='out', desc='Waste heat from the electronics')
    temp_ambient = Float(304.0, units = 'K', iotype='in', desc='Average Temperature of the outside air') #304K = 87.5F
    
    heater_power = Float(14, units='W', iotype='out', desc='Power draw of the heater')
    sb_constant = Float(0.00000005670373, iotype="in", units = 'W/((m**2)*(K**4))', desc='Stefan-Boltzmann Constant') #
    Nu_multiplier = Float(1, iotype='in', desc='fudge factor to switch convection on and off')

    #--Outputs--
    temp_boundary = Float(321.0, units = 'K', iotype='in', desc='Average Temperature of the battery wall') 
    char_length = Float(0.01, units = 'm', iotype='out', desc='Characteristic length')
    #Required for Natural Convection Calcs
    GrDelTL3 = Float(1946216.7, units = '1/((ft**3)*F)', iotype='out', desc='Heat Radiated to the outside') #
    Pr = Float(0.707, iotype='out', desc='Prandtl') #
    Gr = Float(12730351223., iotype='out', desc='Grashof #') #
    Ra = Float(8996312085., iotype='out', desc='Rayleigh #') #
    Nu = Float(232.4543713, iotype='out', desc='Nusselt #') #
    k = Float(0.02655, units = 'W/(m*K)', iotype='out', desc='Thermal conductivity') #
    h = Float(0.845464094, units = 'W/((m**2)*K)', iotype='out', desc='Heat Radiated to the outside') #
    alpha = Float(2.487*(10**(-5)), units = '(m**2)/s', iotype='out', desc='Thermal diffusivity') #
    k_visc = Float(1.798*(10**(-5)), units = '(m**2)/s', iotype='out', desc='Kinematic viscosity') #
    film_temp = Float(310, units = 'K', iotype='out', desc='Film temperature') #

    #Natural Convection
    area_convection = Float(1.5, units = 'm**2', iotype='out', desc='Convection Area') #
    q_per_area_nat_conv = Float(7.9, units = 'W/(m**2)', iotype='out', desc='Heat Radiated per Area to the outside') #
    total_q_nat_conv = Float(286900419., units = 'W', iotype='out', desc='Total Heat Radiated to the outside via Natural Convection') #
    
    #Radiated Out
    q_rad_per_area = Float(31.6, units = 'W/(m**2)', iotype='out', desc='Heat Radiated to the outside') #
    q_rad_tot = Float(106761066.5, units = 'W', iotype='out', desc='Heat Radiated to the outside') #

    #Total Heating
    q_total_out = Float(286900419., units = 'W', iotype='out', desc='Total Heat Released via Radiation and Natural Convection') #
    q_total_in = Float(286900419., units = 'W', iotype='out', desc='Total Heat Absorbed/Added via powered electronics') #
    #Residual (for solver)
    ss_temp_residual = Float(units = 'K', iotype='out', desc='Residual of T_released - T_absorbed')
  
    def execute(self):
        """Calculate Various Paramters"""

        self.q_total_in = self.heater_power + self.waste_heat

        #Radiation Out
        self. q_rad_per_area = self.sb_constant*self.emissivity*((self.temp_boundary**4) - (self.temp_ambient**4))
        self.q_rad_tot = self.batt_area * self.q_rad_per_area

        #Characteristic length is a single side length for a cube
        self.char_length = (self.batt_area/6)**0.5

        self.film_temp = (self.temp_ambient + self.temp_boundary)/2.

        #Convection Out (1 atm)
        if(self.Nu_multiplier > 0):
            if(self.film_temp < 400):
                 self.GrDelTL3 = 41780000000000000000*((self.film_temp)**(-4.639)) #SI units (https://mdao.grc.nasa.gov/publications/Berton-Thesis.pdf pg51)
            else:
                 self.GrDelTL3 = 4985000000000000000*((self.film_temp)**(-4.284)) #SI units (https://mdao.grc.nasa.gov/publications/Berton-Thesis.pdf pg51)
            
            #Prandtl Number
            #Pr = viscous diffusion rate/ thermal diffusion rate = Cp * dyanamic viscosity / thermal conductivity
            #Pr << 1 means thermal diffusivity dominates
            #Pr >> 1 means momentum diffusivity dominates
            if (self.film_temp < 400):
                self.Pr = 1.23*(self.film_temp**(-0.09685)) #SI units (https://mdao.grc.nasa.gov/publications/Berton-Thesis.pdf pg51)
            else:
                self.Pr = 0.59*(self.film_temp**(0.0239))
            #Grashof Number
            #Relationship between buoyancy and viscosity
            #Laminar = Gr < 10^8
            #Turbulent = Gr > 10^9
            self.Gr = self.GrDelTL3*abs(self.temp_boundary-self.film_temp)*((self.char_length)**3) 
            #Rayleigh Number 
            #Buoyancy driven flow (natural convection)
            self.Ra = self.Pr * self.Gr
            if (self.Ra<=10**12): #valid in specific flow regime
                self.Nu = ((0.6 + 0.387*self.Ra**(1./6.)/(1 + (0.559/self.Pr)**(9./16.))**(8./27.))**2) #3rd Ed. of Introduction to Heat Transfer by Incropera and DeWitt, equations (9.33) and (9.34) on page 465
            else: 
                self.Nu = 0.01

            #h = k*Nu/Characteristic Length
            self.h = (self.k * self.Nu)/ self.char_length
            #Convection Area = Surface Area
            self.area_convection = (self.batt_area*5/6) 
            #Determine heat radiated per square meter (Q)
            self.q_per_area_nat_conv = self.h*(self.temp_boundary-self.temp_ambient)
            #Determine total heat radiated over entire tube (Qtotal)
            self.total_q_nat_conv = self.q_per_area_nat_conv * self.area_convection
        else:
            self.total_q_nat_conv = 0 #no convection at high altitude!

        self.q_total_out = self.q_rad_tot + self.total_q_nat_conv

        self.ss_temp_residual = (self.q_total_out - self.q_total_in)/1e6


if __name__ == '__main__' and __package__ is None:

    hs = HeaterSystem()

    #initial run to converge things
    hs.run()

    print "------- Ground Temp -------"
    print "Heater Temp: ", (1.8*(hs.heater.temp_boundary-273.15))+32, "degF"
    print "Heater Temp: ", (hs.heater.temp_boundary-273), "degC"
    print

    hs.heater.Nu_multiplier = 0
    hs.heater.temp_ambient = 213
    hs.run()
    print "------- Space Temp -------"
    print "Heater Temp: ", (1.8*(hs.heater.temp_boundary-273.15))+32, "degF"
    print "Heater Temp: ", (hs.heater.temp_boundary-273), "degC"


