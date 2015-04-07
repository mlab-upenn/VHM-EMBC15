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
% input_range = [0 1; 0 1]
input_range = [0 1]
disp(' ')
disp('The number of control points for the input signal determines how many pulses there are:')
cp_array = 100*ones(1,size(input_range,1));


%% =================
%  The spec
%  =================
% output = NA1 ... NA7, VP, PVC
% VS is given by NA3_Out
disp(' ')
disp('The specification:')
phi_vp  = '((vp /\ X(!vp))   -> X([]_[1,500]!vp))';
phi_vs  = '((vs /\ X(!vs))   -> X([]_[1,500]!vp))';
phi_pvc = '((pvc /\ X(!pvc)) -> X([]_[1,500]!vp))';

phifull = ['[] ( ', phi_vp,' /\', phi_vs, '/\', phi_pvc, ' )'];
phi = ['[] ',phi_vs];

preds(1).str='vp';
preds(1).A = [zeros(1,7), -1, 0];
preds(1).b = -0.8;

preds(2).str='pvc';
preds(2).A = [zeros(1,8), -1];
preds(2).b = -0.8;

preds(3).str='vs';
preds(3).A = [0, 0, -1, zeros(1,6)];
preds(3).b = -0.8;

%% ==============
%  Run option
%  ==============
disp(' ')
disp('Total Simulation time:')
simTime = 7000

opt = staliro_options();

opt.optimization_solver = 'SA_Taliro';
opt.runs = 3;
opt.sa_params.n_tests = 5;%1000;
opt.spec_space='Y';
opt.interpolationtype = {'bool'};
opt.n_workers = 1;
opt.varying_cp_times = 1;
opt.taliro = 'dp_t_taliro';
%opt.dp_t_taliro_direction  = 'past';
opt.falsification = 1;


open_system(sprintf('%s/pacemaker_DDD/pacem_aut',model));

disp(' ')
tic
results = staliro(model,init_cond,input_range,cp_array,phi, preds,simTime,opt);
toc
save('results.mat')

disp(' ')
display(['Minimum Robustness found in Run 1 = ',num2str(results.run(1).bestRob)])
display(['Minimum Robustness found in Run 2 = ',num2str(results.run(2).bestRob)])

for i=1:3
    [T1,XT1,YT1,IT1] = SimSimulinkMdl(model,init_cond,input_range,cp_array,results.run(i).bestSample,simTime,opt);
    VS1 = YT1(:,3);
    VP1 = YT1(:,8);
    PVC1 = YT1(:,9);
    kept{i,1} = YT1;
    kept{i,2} = IT1;
    oo = dp_t_taliro(phi, preds,YT1,T1,[],[],[])
    figure(i)
    clf
    subplot(3,1,1)
    plot(T1,VS1)
    title(['VS_',num2str(i)])
    subplot(3,1,2)
    plot(T1,VP1)
    title(['VP_',num2str(i)])
    subplot(3,1,3)
    plot(T1,PVC1)
    title(['PVC_',num2str(i)])
end
save('results.mat','kept','-append')
