clear 
model = @closedloopheart;

disp(' ')
disp('The constraints on the initial conditions:')
init_cond = [] %#ok<*NOPTS>

% Electrophysiological Characteristics
% PVC Burden
% Several studies have shown that the frequency of PVCs correlates at 
%least modestly with the extent of LV dysfunction and ventricular dilation
%at the time of initial clinical presentation.13?17 Patients with decreased 
%LVEF had a higher mean PVC burden than their counterparts with normal LV 
%function (29%?37% versus 8%?13%).15,18,19 However, there are no clear-cut 
%points that mark the frequency at which cardiomyopathy is unavoidable. 
%Niwano et al13 used a cut point of 20 000 PVCs over 24 hours to define 
%the high-frequency group, whereas Kanei et al17 used a figure of 10 000 
%PVCs per day. Other studies defined ?frequent? PVCs as >10% of total beats
%rather than the absolute number of PVCs,18,19 yet in some cases, a high 
%PVC burden may not impair LV function, whereas PVC-induced cardiomyopathy 
%can be observed in patients with lower PVC frequencies, albeit at lower 
%incidences.12,16,17 It is not known why the majority of patients with 
%frequent PVCs have a benign course, whereas up to one third of them 
%develop cardiomyopathy. One possible explanation is that the evaluation 
%of PVC burden using 24-hour Holter monitoring may be inadequate and may 
%misrepresent the patient's true PVC burden.20 Baman et al18 suggested that 
%a PVC burden of >24% had a sensitivity and specificity of 79% and 78%, 
%respectively, in separating the patient populations with impaired versus 
%preserved LV function. Nevertheless, the majority of patients presenting 
%with frequent PVCs had preserved LVEF.4,9,12,13,15 Therefore, although 
%significant, the PVC burden is not the only factor contributing to 
%impairment of LV systolic function.9,15,21
% from "Advances in Arrhythmia and Electrophysiology. Premature Ventricular 
% Contraction-Induced Cardiomyopathy A Treatable Condition"
% http://circep.ahajournals.org/content/5/1/229.full

disp(' ')
disp('The constraints on the input signals PVC and PAC defined as a hypercube:')
% input_range = [0 1; 0 1]
input_range = [0 1]
disp(' ')
disp('The number of control points for the input signal determines how many pulses there are:')
cp_array = 10*ones(1,size(input_range,1));


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
% PVCs were found to be 0.5% to 2.2% of the heartbeats in 24hrs for healthy
% individuals
disp(' ')
disp('Total Simulation time:')
simTime = 10000

opt = staliro_options();

opt.optimization_solver = 'UR_Taliro';
opt.runs = 3;
opt.sa_params.n_tests = 5;%1000;
opt.spec_space='Y';
opt.interpolationtype = {'impulse'};
opt.n_workers = 1;
opt.varying_cp_times = 1;
opt.taliro = 'dp_t_taliro';
%opt.dp_t_taliro_direction  = 'past';
opt.falsification = 1;
opt.black_box = 1;
opt.SampTime = 1;
opt.ur_generation.constrained = 1;
opt.ur_generation.minDelay = 400;% delay in absolute real time.

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
