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
%
%Niwano et al13 used a cut point of 20 000 PVCs over 24 hours to define 
%the high-frequency group, 
% whereas Kanei et al17 used a figure of 10 000 PVCs per day. 
% Other studies defined ?frequent? PVCs as >10% of total beats
%rather than the absolute number of PVCs,18,19 
%
%yet in some cases, a high 
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
cp_array = 2*ones(1,size(input_range,1));


%% =================
%  The spec
%  =================
%Pattern:
% Vpace -> PA2.state=3 -> NA2 -> PA1.state=3 -> NA1 -> VPace (repetitive for at least 4 cycles)
% Vpace = pace_param.v_pace
% PA2.state = path_table{2,1}
% NA2 = node_table{2,7}
% PA1.state = path_table{1,1}
% NA1 = node_table{1,7}
% ? time between events
% 
% Timing:
% Vpace-Vpace<600

disp(' ')
disp('The specification:')
phiSimple = '[] ((na3 || vp) -> []_[0,500] !(na3||vp))';
phiSequence  =  '(<> (vp /\ (vp -> <>(pa2 /\ (pa2 -> <>(na2 /\ (na2 -> <>(pa1 /\ (pa1 -> <>(na1 /\ (na1 -> <>(vp) )) )) )) )) )))';
phiDelayWide = '( (vp /\ X(!vp)) -> (<>_[1,600]vp) )';
phiDelay     = '( vp             -> (<>_[1,600]vp) )';
phiELTWidePulses = ['!(',phiSequence, ' /\ ', phiDelayWide, ')'];
phiELT           = ['!(',phiSequence, ' /\ ', phiDelay, ')'];
phi = phiELTWidePulses

% Signals = NA1, NA2, NA3, Apace, Vpace, PA1, PA2
preds(1).str='vp';
preds(1).A = [0, 0, 0, 0, -1, 0, 0];
preds(1).b = -0.8;

preds(2).str='na1';
preds(2).A = [-1, 0, 0, 0, 0, 0, 0];
preds(2).b = -0.8;

preds(3).str='na2';
preds(3).A = [0, -1, 0, 0, 0, 0, 0];
preds(3).b = -0.8;

preds(4).str='na3';
preds(4).A = [0, 0, -1, 0, 0, 0, 0];
preds(4).b = -0.8;

preds(5).str='apace';
preds(5).A = [0, 0, 0, -1, 0, 0, 0];
preds(5).b = -0.8;

preds(6).str='pa1';
preds(6).A = [0, 0, 0, 0, 0, -1, 0
              0, 0, 0, 0, 0, 1, 0];
preds(6).b = [-2.8; 3.2];

preds(7).str='pa2';
preds(7).A = [0, 0, 0, 0, 0, 0, -1
              0, 0, 0, 0, 0, 0, 1];
preds(7).b = [-2.8; 3.2];


% % Output = NA3, Apace, Vpace
% preds(1).str='vp';
% preds(1).A = [0, 0, -1];
% preds(1).b = -0.8;
% 
% preds(2).str='na3';
% preds(2).A = [-1, 0, 0];
% preds(2).b = -0.8;
%% ==============
%  Run option
%  ==============
% PVCs were found to be 0.5% to 2.2% of the heartbeats in 24hrs for healthy
% individuals
disp(' ')
disp('Total Simulation time:')
simTime = 10000

opt = staliro_options();
opt.optimization_solver = 'SA_Taliro';
opt.runs                = 3;
n_tests                 = 5;
opt.sa_params.n_tests   = n_tests;
opt.ur_params.n_tests   = n_tests;
opt.spec_space          = 'Y';
opt.interpolationtype   = {'pulse'};
opt.SampTime            = 0.2;
opt.n_workers           = 1;
opt.varying_cp_times    = 1;
opt.taliro = 'dp_t_taliro';
%opt.dp_t_taliro_direction  = 'past';
opt.falsification = 0;
opt.black_box = 1;

opt.constrained_generation.enabled = 1;
opt.constrained_generation.minSeparation = 0.5*simTime;
opt.constrained_generation.distribution = 'uniform';
opt.constrained_generation.sort = 0;
opt.constrained_generation.percentageDisplacement = 0.1;

global node_table;
global path_table;
global pace_param;
load HM
load PM_new
pace_param.P_det = 0;
for r=1:size(node_table,1)
    for c = 1:size(node_table,2)
        xNode = [xNode;node_table{r,c}];
    end
end
for r=1:size(path_table,1)
    for c = 1:size(path_table,2)
        xPath = [xPath;path_table{r,c}];
    end
end
x0 = [xNode;xPath];

disp(' ')
tic
[results, history] = staliro(model,init_cond,input_range,cp_array,phi, preds,simTime,opt);
toc
save('results.mat')

disp(' ')
display(['Minimum Robustness found in Run 1 = ',num2str(results.run(1).bestRob)])
display(['Minimum Robustness found in Run 2 = ',num2str(results.run(2).bestRob)])

%% Graph
for i=1:3
    [hs, rc] = systemsimulator(model, [], results.run(i).bestSample, simTime, input_range, cp_array);
    oo = dp_t_taliro(phi, preds,hs.STraj,hs.T,[],[],[])
    kept{i} = hs;    
    plotELTseekers(hs,i);
    
end
save('results.mat','kept','-append')
