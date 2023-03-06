mrstModule add ad-core mrst-gui mpfa agmg linearsolvers

%% Setup parameters using json inputs available in repo

% load json struct for the material properties
jsonfilename = fullfile('ParameterData', 'BatteryCellParameters', 'LithiumIonBatteryCell', ...
                        'lithium_ion_battery_nmc_graphite.json');
jsonstruct_material = parseBattmoJson(jsonfilename);

% load json struct for the geometrical properties
jsonfilename = fullfile('Examples','utils', 'data', 'geometry1d.json');
jsonstruct_geometry = parseBattmoJson(jsonfilename);

% load json struct for the geometrical properties
jsonfilename = fullfile('Examples','utils', 'data', 'ie_control.json');
jsonstruct_control = parseBattmoJson(jsonfilename);

% load json struct for the geometrical properties
jsonfilename = fullfile('Examples','utils', 'data', 'simulation_parameters.json');
jsonstruct_simparams = parseBattmoJson(jsonfilename);

% We merge the json structures. The function issues a warning if a parameter is set with different values in the given
% structures. The rule is that the first value takes precedence.
jsonstruct = mergeJsonStructs({jsonstruct_geometry , ...
                               jsonstruct_material , ...
                               jsonstruct_control  , ...
                               jsonstruct_simparams});

jsonstruct0 = jsonstruct;

%% We adjust the total time with respect to the given CRate.

CRate = jsonstruct.Control.CRate;
jsonstruct.TimeStepping.totalTime = 1.4*hour/CRate;
jsonstruct.TimeStepping.N = 40;

%% Run battery simulation with function that takes json input

output = runBatteryJson(jsonstruct);

%% Plotting

states = output.states;

E = cellfun(@(x) x.Control.E, states); 
I = cellfun(@(x) x.Control.I, states);
time = cellfun(@(x) x.time, states); 

figure()
subplot(1,2,1)
plot(time/hour, E)
xlabel('time [hours]')
ylabel('Cell Voltage [V]')

subplot(1,2,2)
plot(time/hour, I)
xlabel('time [hours]')
ylabel('Cell Current [A]')


%% We change the CRate

output1 = output;

CRate2 = 2;

jsonstruct.Control.CRate = CRate2;
jsonstruct.TimeStepping.totalTime = 1.4*hour/CRate2;
jsonstruct.TimeStepping.N = 40;

output2 = runBatteryJson(jsonstruct);

%% We plot the results of the second simulation

states = output2.states;
E2    = cellfun(@(x) x.Control.E, states); 
I2    = cellfun(@(x) x.Control.I, states);
time2 = cellfun(@(x) x.time, states); 

figure()
subplot(1,2,1)
plot(time2/hour, E2)
xlabel('time [hours]')
ylabel('Cell Voltage [V]')

subplot(1,2,2)
plot(time2/hour, I2)
xlabel('time [hours]')
ylabel('Cell Current [A]')


%% We compare the results by adjusting time with CRate

figure()
hold on
plot(time/hour, E);
plot(time2/hour*CRate2, E2);
xlabel('time [hours]')
ylabel('Cell Voltage [V]')


%% We change the diffusion coefficient

CRate = 1;

jsonstruct.Control.CRate = CRate;
jsonstruct.TimeStepping.totalTime = 1.4*hour/CRate;

D0 = jsonstruct_material.NegativeElectrode.ActiveMaterial.SolidDiffusion.D0;
jsonstruct.NegativeElectrode.ActiveMaterial.SolidDiffusion.D0 = 1e-3*D0;

output3 = runBatteryJson(jsonstruct);

%% plotting

states = output3.states;
E3    = cellfun(@(x) x.Control.E, states); 
I3    = cellfun(@(x) x.Control.I, states);
time3 = cellfun(@(x) x.time, states);

figure()
subplot(1,2,1)
plot(time3/hour, E3)
xlabel('time [hours]')
ylabel('Cell Voltage [V]')

subplot(1,2,2)
plot(time3/hour, I3)
xlabel('time [hours]')
ylabel('Cell Current [A]')

%% We compare the plots

figure()
subplot(1,2,1)
hold on
plot(time/hour, E)
plot(time3/hour, E3)
xlabel('time [hours]')
ylabel('Cell Voltage [V]')

subplot(1,2,2)
hold on
plot(time/hour, I)
plot(time3/hour, I3)
xlabel('time [hours]')
ylabel('Cell Current [A]')

%% We change control to CCCV

% load json struct for the geometrical properties
jsonfilename = fullfile('Examples','utils', 'data', 'cccv_control.json');
jsonstruct_control = parseBattmoJson(jsonfilename);

jsonstruct = mergeJsonStructs({jsonstruct_control, ...
                               jsonstruct0});

CRate = jsonstruct.Control.CRate;
jsonstruct.TimeStepping.totalTime = 5*hour/CRate;
jsonstruct.TimeStepping.N = 200;

output4 = runBatteryJson(jsonstruct);

%% Plotting CCCV result

states = output4.states;
E4    = cellfun(@(x) x.Control.E, states); 
I4    = cellfun(@(x) x.Control.I, states);
time4 = cellfun(@(x) x.time, states);

figure()
subplot(1,2,1)
plot(time4/hour, E4)
xlabel('time [hours]')
ylabel('Cell Voltage [V]')

subplot(1,2,2)
plot(time4/hour, I4)
xlabel('time [hours]')
ylabel('Cell Current [A]')


%% We populate the outputs with all the dynamical variables

states = output.states;
model = output.model;

for istate = 1 : numel(states)
    states{istate} = model.addVariables(states{istate});
end

% shorhand names
ne      = 'NegativeElectrode';
pe      = 'PositiveElectrode';
elyte   = 'Electrolyte';
thermal = 'ThermalModel';
am      = 'ActiveMaterial';
itf     = 'Interface';
sd      = 'SolidDiffusion';
ctrl    = 'Control';
cc      = 'CurrentCollector';


%% We change control to CCCV

% load json struct for the geometrical properties
jsonfilename = fullfile('Examples','utils', 'data', 'cccv_control.json');
jsonstruct_control = parseBattmoJson(jsonfilename);

jsonstruct = mergeJsonStructs({jsonstruct_control, ...
                               jsonstruct0});

CRate = jsonstruct.Control.CRate;
jsonstruct.TimeStepping.totalTime = 5*hour/CRate;
jsonstruct.TimeStepping.N = 200;

output4 = runBatteryJson(jsonstruct);

%% Plotting CCCV result

states = output4.states;
E4    = cellfun(@(state) state.Control.E, states); 
I4    = cellfun(@(state) state.Control.I, states);
time4 = cellfun(@(state) state.time, states);

figure()
subplot(1,2,1)
plot(time4/hour, E4)
xlabel('time [hours]')
ylabel('Cell Voltage [V]')

subplot(1,2,2)
plot(time4/hour, I4)
xlabel('time [hours]')
ylabel('Cell Current [A]')

%% run 3D simulation

% load json struct for the geometrical properties
jsonfilename = fullfile('Examples','utils', 'data', 'geometry3d.json');
jsonstruct_geometry = parseBattmoJson(jsonfilename);

jsonstruct = mergeJsonStructs({jsonstruct_geometry, ...
                               jsonstruct0}, 'warn', false);
jsonstruct.include_current_collectors = true;

output5 = runBatteryJson(jsonstruct);

%% plotting for 3D simulation

states = output5.states;
E5    = cellfun(@(state) state.Control.E, states); 
I5    = cellfun(@(state) state.Control.I, states);
time5 = cellfun(@(state) state.time, states);

figure()
subplot(1,2,1)
plot(time5/hour, E5)
xlabel('time [hours]')
ylabel('Cell Voltage [V]')

subplot(1,2,2)
plot(time5/hour, I5)
xlabel('time [hours]')
ylabel('Cell Current [A]')


%%

model     = output5.model;
initstate = output5.initstate;
schedule  = output5.schedule;

CRate = model.Control.CRate;

n           = 25;
dt          = [];
dt          = [dt; repmat(0.5e-4, n, 1).*1.5.^[1 : n]'];
totalTime   = 1.4*hour/CRate;
n           = 40; 
dt          = [dt; repmat(totalTime/n, n, 1)]; 
times       = [0; cumsum(dt)]; 
tt          = times(2 : end); 
step        = struct('val', diff(times), 'control', ones(numel(tt), 1)); 

schedule.step = step;

[~, states, report] = simulateScheduleAD(initstate, model, schedule);

%% We plot the grid for the whole model using the MRST function plotGrid

plotGrid(model.G);

%% be aware of the scales...

axis equal

%% We plot each components

ne    = 'NegativeElectrode';
pe    = 'PositiveElectrode';
am    = 'ActiveMaterial';
cc    = 'CurrentCollector';
sd    = 'SolidDiffusion';
sep   = 'Separator';
elyte = 'Electrolyte';

c0 = 1/255;

figure

G      = model.(ne).(am).G;
legtxt = 'Negative Active Material';
c      = c0*[0 0 0];
plotGrid(G, 'facecolor', c, 'edgealpha', 0.3, 'displayname', legtxt);

G      = model.(ne).(cc).G;
legtxt = 'Negative Current Collector';
c      = c0*[0 121 203];
plotGrid(G, 'facecolor', c, 'edgealpha', 0.3, 'displayname', legtxt);

G      = model.(pe).(am).G;
legtxt = 'Positive Active Material';
c      = c0*[127 127 127];
plotGrid(G, 'facecolor', c, 'edgealpha', 0.3, 'displayname', legtxt);

G      = model.(pe).(cc).G;
legtxt = 'Positive Current Collector';
c      = c0*[142 45 41];
plotGrid(G, 'facecolor', c, 'edgealpha', 0.3, 'displayname', legtxt);

G      = model.(elyte).(sep).G;
legtxt = 'Separator';
c      = c0*[239 204 97]; 
plotGrid(G, 'facecolor', c, 'edgealpha', 0.3, 'displayname', legtxt);

legend show

%% We plot the value of the surface concentration in the active material of the negative electrode

states = output5.states;

G = model.(ne).(am).G;
clear output;
for istate = 1 : numel(states)
    output{istate}.cSurface = states{istate}.(ne).(am).(sd).cSurface;
end

figure
plotToolbar(G, output);

%% We plot the value of the surface concentration in the active material of the negative electrode

G = model.(thermal).G;
clear output;
for istate = 1 : numel(states)
    output{istate}.T = states{istate}.(thermal).T;
end

figure
plotToolbar(G, output);




