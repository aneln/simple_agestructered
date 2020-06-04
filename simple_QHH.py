#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jun  4 18:02:16 2020

@author: anelnurtay
"""

run_locally = False

import sys

import os
import pandas as pd
from random import randint
from COVID19.model import Model, Parameters, ModelParameterException
import COVID19.simulation as simulation
import numpy as np
from datetime import datetime
import utilities as utils

path = os.getcwd()

app_uptake_multiplier = float(sys.argv[1])
case_id = int(sys.argv[2])
run_number = int(sys.argv[3])
dir_name = str(sys.argv[4])

parameter_line_number = 1

if run_locally == True:   
    dir_name = os.path.join(path, "output/branch_configurable_date_{}_case_{}_app_{}_run_{}".format(datetime.now().strftime('%Y-%m-%d'),case_id, app_uptake_multiplier, run_number))
    os.mkdir(dir_name)
     
    input_parameter_file = os.path.join(path, "input/baseline_parameters.csv")
    output_dir = dir_name
    household_demographics_file = os.path.join(path, "input/baseline_household_demographics.csv")
else:
#    dir_name = os.path.join(path, "output/branch_configurable/date_{}/case_{}/app_{}/run_{}".format(datetime.now().strftime('%Y-%m-%d'), case_id, app_uptake_multiplier, run_number))
#    os.makedirs(dir_name, exist_ok=True)
        
    input_parameter_file = os.path.join(path, "input/baseline_parameters.csv")
    output_dir = dir_name 
    household_demographics_file = os.path.join(path, "input/baseline_household_demographics.csv")

def get_baseline_parameters():
    params = Parameters(input_parameter_file, parameter_line_number, output_dir, household_demographics_file)
    return params

end_time = 150

def get_simulation( params ):
    params.set_param( "end_time", end_time )
    model = simulation.COVID19IBM(model = Model(params))
    sim = simulation.Simulation(env = model, end_time = params.get_param( "end_time" ) )
    return sim


if __name__ == "__main__":
    
    params = get_baseline_parameters()
    params.set_param( "rng_seed", run_number )
    params.set_param( "n_seed_infection", 10)

    
    params.set_param( "n_total", 1000000 )
    if run_locally == True:
        params.set_param( "n_total", 100000 )
    
#    # create random world
    n_connections =  15

    params.set_param( "relative_transmission_household", 0.0 )
    params.set_param( "relative_transmission_occupation", 0.0 )
    params.set_param( "relative_transmission_random", 1.0 )
    
    params.set_param( "random_interaction_distribution", 0 )
    
    params.set_param( "mean_random_interactions_child", n_connections )
    params.set_param( "mean_random_interactions_adult", n_connections )
    params.set_param( "mean_random_interactions_elderly", n_connections )
    
    params.set_param( "sd_random_interactions_child", 0 )
    params.set_param( "sd_random_interactions_adult", 0 )
    params.set_param( "sd_random_interactions_elderly", 0 )
    
    params.set_param( "mean_work_interactions_child", 0 )
    params.set_param( "mean_work_interactions_adult", 0 )
    params.set_param( "mean_work_interactions_elderly", 0 )

    # equal diseases for everyone. No hospitalisation or death
    params = utils.set_fatality_fraction_all(params, 0)
    params = utils.set_fraction_asymptomatic_all(params, 0)
    params = utils.set_icu_allocation_all(params, 0)
    params = utils.set_critical_fraction_all(params, 0)
    params = utils.set_hospitalisation_fraction_all(params, 0)
    params = utils.set_relative_susceptibility_equal(params)
    params.set_param("mild_infectious_factor", 1)
    params.set_param("asymptomatic_infectious_factor", 1)

    # Recover slowly
    params.set_param("mean_asymptomatic_to_recovery", 20)
    params.set_param("sd_asymptomatic_to_recovery", 2)

    # Guess for useful R0 to investigate
    params.set_param("infectious_rate", 6)

    # no testing
    params = utils.turn_off_testing(params)

    # app turned on from day zero
    params.set_param("app_turned_on", 1)
    params.set_param("app_turn_on_time", 1)
    # trace on symptoms
    params.set_param( "trace_on_positive", 0)
    params.set_param( "trace_on_symptoms", 1)

    # 100% smartphone usage
    params = utils.set_app_users_fraction_all(params, app_uptake_multiplier)

    # Perfect app:
    params.set_param("quarantine_compliance_traced_symptoms", 1) # full compliance
    params.set_param( "quarantine_dropout_self", 0) # no dropouts
    params.set_param( "quarantine_dropout_traced_symptoms", 0) # no dropouts
    params.set_param( "quarantine_on_traced", 1 ) # unsure what this means
    params.set_param( "traceable_interaction_fraction", 1 ) # all interactions traced
    params.set_param("quarantined_daily_interactions", 0) # perfect quarantine
    params.set_param("daily_non_cov_symptoms_rate", 0) # perfect specificity

    # Everyone self-quarantines on symptoms
    params.set_param( "self_quarantine_fraction", 1 )
    
    # Never propagate quarantine through a household
    params.set_param( "quarantine_household_on_symptoms", 1 )
    params.set_param( "quarantine_household_contacts_on_symptoms", 0 )
    params.set_param( "quarantine_household_on_traced_symptoms", 1 )

    params.set_param("quarantine_length_traced_symptoms", 14)
    
    if case_id == 3: 
        params.set_param("random_interactions_quarantine_replacement", True)
    # change behaviour such that the random network is generated without replacement
    if case_id == 4: 
        params.set_param("random_interactions_quarantine_replacement", False)
        
    # start the epidemic
    sim = get_simulation( params ) 
    sim.steps( 1 )
    et = 1
    sim.env.model.write_individual_file()
    os.rename('{}/individual_file_Run1.csv'.format(dir_name), '{}/individual_file_Run1_t{}.csv'.format(dir_name, et))
    
    while (et < end_time) & ( sim.results["total_infected"][ -1] < (0.1 * params.get_param("n_total"))):
        et += 1
        sim.steps( 1 )
        sim.env.model.write_individual_file()
        os.rename('{}/individual_file_Run1.csv'.format(dir_name), '{}/individual_file_Run1_t{}.csv'.format(dir_name, et))
#    sim.env.model.write_individual_file()   
    sim.env.model.write_transmissions()
    
    timeseries = pd.DataFrame( sim.results )
    timeseries.to_csv("{}/covid_timeseries_Run1.csv".format(dir_name), index=False)


    if run_locally == True:
        import matplotlib.pyplot as plt
        timeseries.plot( x = "time", y = "n_quarantine" )
        plt.savefig('{}/simple_quarantine.pdf'.format(dir_name))
        timeseries.plot( x = "time", y = "total_infected" )
        plt.savefig('{}/simple_infected.pdf'.format(dir_name))
        timeseries.plot( x = "time", y = "n_death" )
        plt.savefig('{}/simple_death.pdf'.format(dir_name))
