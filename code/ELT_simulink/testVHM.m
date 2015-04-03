clear

model='testableCase2';
% Tclk_h=1;
% set_param(model,'StopTime','10000');
% set_param(sys_name,'simulationcommand','start');
% 

% Node table
% 1.	Name(p)
                        % 2.	State(s)
                        % 3.	ERP_cur(s)
% 4.	ERP_def(p)
                        % 5.	RRP_cur(s)
% 6.	RRP_def(p)
                        % 7.	Rest_cur(s)
% 8.	Rest_def(p)
                        % 9.	Node_in(s)
% 10.	ERP_int(p)
                        % 11.	Node_out(s)
% 12.	Node_cat(p)

% Path table
% 1.	Name(p)
                        % 2.	State(s)
% 3.	Node_ind1(p)
% 4.	Node_ind2(p)
% 5.	Amp(p)*
% 6.	Velocity(p)*
% 7.	Type(p)*
                        % 8.	Forw_cur(s)
% 9.	Forw_def(p)
                        % 10.	Back_cur(s)
% 11.	Back_def(p)
% 12.	Length(p)*
% 13.	Slope(p)*
% *not used in the Simulink model

% Pacemaker parameters
% 1.	Name(p)
                        % 2.	State(s)
                        % 3.	Timer_cur(s)
% 4.	Timer_def(p)
% 5.                                          (1)AP(u); 
%                                             (2)VP(u); 
%                       (3)AS(s); 
%                       (4)VS(s); 
%%

setup_case2none;
% % rto = get_param(sprintf('%s/%s/node_aut',sys_name,node_name{i}),'RuntimeObject');
% % node_c=rto.OutputPort(2).Data;
% % pause(Config.delay)
% % 

disp(' ')
disp('The constraints on the initial conditions:')
init_cond = [] %#ok<*NOPTS>

disp(' ')
disp('The constraints on the input signals PVC and PAC defined as a hypercube:')
input_range = [0 1; 0 1]
disp(' ')
disp('The number of control points for the input signal determines how many pulses there are:')
cp_array = [10, 10];
nb_pulses = cp_array/2

% output = NA1 ... NA7, VP, PVC
% VS is given by NA3_Out
disp(' ')
disp('The specification:')
% phi = '(VP \/ PVC \/ VS) -> ([]_[0,500] !VP)'
phi = 'VP'

preds(1).str='VP';
preds(1).A = [zeros(1,7), -1, 0];
preds(1).b = -1;

preds(2).str='PVC';
preds(2).A = [zeros(1,8), -1];
preds(2).b = -1;

preds(3).str='VS';
preds(3).A = [0, 0, -1, zeros(1,6)];
preds(3).b = -1;

disp(' ')
disp('Total Simulation time:')
simTime = 5

opt = staliro_options();

opt.optimization_solver = 'UR_Taliro';
opt.runs = 2;
opt.ur_params.n_tests = 3;
opt.spec_space='Y';
opt.interpolationtype = {'bool'};
opt.n_workers = 1;

open_system(sprintf('%s/pacemaker_DDD/pacem_aut',model));

disp(' ')
disp('Running S-TaLiRo with Uniform Random Sampling ...')
tic
results = staliro(model,init_cond,input_range,cp_array,phi,preds,simTime,opt);
toc

disp(' ')
display(['Minimum Robustness found in Run 1 = ',num2str(results.run(1).bestRob)])
display(['Minimum Robustness found in Run 2 = ',num2str(results.run(2).bestRob)])

disp(' ')
disp('Displaying trajectories in Figures 1 and 2 ...')

figure(1)
clf
[T1,XT1,YT1,IT1] = SimSimulinkMdl(model,init_cond,input_range,cp_array,results.run(1).bestSample,simTime,opt);
subplot(2,1,1)
plot(T1,XT1)
title('State trajectories')
subplot(2,1,2)
plot(IT1(:,1),IT1(:,2))
title('Input Signal')

figure(2)
clf
[T2,XT2,YT2,IT2] = SimSimulinkMdl(model,init_cond,input_range,cp_array,results.run(2).bestSample,simTime,opt);
subplot(2,1,1)
plot(T2,XT2)
title('State trajectories')
subplot(2,1,2)
plot(IT2(:,1),IT2(:,2))
title('Input Signal')

disp(' ')
disp('Displaying Simulink model for visualization. ')
open(model)


