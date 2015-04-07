clear 
model = @closedloopheart;

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
% output = NA3, Apace, Vpace
disp(' ')
disp('The specification:')
phi = '[] ((na3 || vp) -> []_[0,500] !(na3||vp))'

preds(1).str='vp';
preds(1).A = [0, 0, -1];
preds(1).b = -0.8;

preds(2).str='na3';
preds(2).A = [-1, 0, 0];
preds(2).b = -0.8;

%% ==============
%  Run option
%  ==============
disp(' ')
disp('Total Simulation time:')
simTime = 5000

opt = staliro_options();

opt.optimization_solver = 'UR_Taliro';
opt.runs = 3;
opt.sa_params.n_tests = 5;%1000;
opt.spec_space='Y';
opt.interpolationtype = {'bool'};
opt.n_workers = 1;
opt.varying_cp_times = 1;
opt.taliro = 'dp_t_taliro';
%opt.dp_t_taliro_direction  = 'past';
opt.falsification = 1;
opt.black_box = 1;
opt.SampTime = 1;

global node_table;
global path_table;
global pace_param;
load HM
load PM_new
pace_param.P_det = 0;

disp(' ')
tic
results = staliro(model,init_cond,input_range,cp_array,phi, preds,simTime,opt);
toc
save('results.mat')

disp(' ')
display(['Minimum Robustness found in Run 1 = ',num2str(results.run(1).bestRob)])
display(['Minimum Robustness found in Run 2 = ',num2str(results.run(2).bestRob)])

%% Graph
for i=1:3
    [hs, rc] = systemsimulator(model, [], results.run(i).bestSample, simTime, input_range, cp_array);
    NA3 = hs.STraj(:,1);
    VP = hs.STraj(:,3);
    T = hs.T;
    IT = hs.InputSignal;
    kept{i} = hs;    
    oo = dp_t_taliro(phi, preds,hs.STraj,T,[],[],[])
    figure(i)
    clf
    subplot(2,1,1)
    plot(T,NA3)
    title(['NA3_',num2str(i)])
    subplot(2,1,2)
    plot(T,VP)
    title(['VP_',num2str(i)])
    
end
save('results.mat','kept','-append')
