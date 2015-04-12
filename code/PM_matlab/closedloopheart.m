function [T, XT, YT, LT, CLG, GRD] =  closedloopheart(XPoint, simTime, steptime,InpSignal)

% Vpace = pace_param.v_pace
% PA2.state = path_table{2,1}
% NA2 = node_table{2,7}
% PA1.state = path_table{1,1}
% NA1 = node_table{1,7}
% 

global node_table;
global path_table;
global pace_param;
% These must be loaded everytime because they constitute an initialization
% of the models
load HM
load PM_new
pace_param.P_det = 0;

ntimeSteps = length(steptime);  
paceOut = zeros(ntimeSteps,2);
senseOut = zeros(ntimeSteps,3);
pathOut = zeros(ntimeSteps,2);
delta = (size(steptime,1)-1) / simTime;
assert(delta == floor(delta), ' Seems you have an off by one error?')
i=0;
while i<simTime
    i=i+1;
    % PAC
    %node_table{1,6}=1;
    begstep = i*delta - (delta-1);
    thisstep = ((i*delta - (delta-1)):i*delta)';
    
    [node_table,path_table,NA3]=heart_model(node_table,path_table);
    % Sensing
    a_out   = node_table{1,7}; % atrial node
    av_out  =  node_table{2,7}; % AV node
    v_out   = node_table{3,7}; % ventricular node    
    senseOut(thisstep,:) = repmat([a_out, av_out, v_out],delta,1);

    pace_param=pacemaker_new(pace_param, a_out, v_out, 1);
    % pacing
    node_table{1,6}=node_table{1,6} || pace_param.a_pace;
    node_table{3,6}=node_table{3,6} || pace_param.v_pace || InpSignal(begstep,1);
    paceOut(thisstep,:) = repmat([pace_param.a_pace, pace_param.v_pace],delta,1);
    
    pathOut(thisstep,:) = repmat([path_table{1,1}, path_table{2,1}],delta,1);
    
end

% ntimeSteps = length(steptime);  
% paceOut = zeros(ntimeSteps,2);
% senseOut = zeros(ntimeSteps,3);
% pathOut = zeros(ntimeSteps,2);
% t=0;
% while t<ntimeSteps
%     t=t+1;
%     % PAC
%     %node_table{1,6}=1;
%     
%     [node_table,path_table,NA3]=heart_model(node_table,path_table);
%     % Sensing
%     a_out=node_table{1,7};
%     v_out=node_table{3,7};
%     senseOut(t,:) = [node_table{1,7}, node_table{2,7}, node_table{3,7}];
%     
%     pace_param=pacemaker_new(pace_param, a_out, v_out, 1);
%     % pacing
%     node_table{1,6}=node_table{1,6} || pace_param.a_pace;
%     node_table{3,6}=node_table{3,6} || pace_param.v_pace || InpSignal(t,1);
%     paceOut(t,:) = [pace_param.a_pace, pace_param.v_pace];
%     
%     pathOut(t,:) = [path_table{1,1}, path_table{2,1}];
%     
% end

T = steptime;
XT = [];
YT = [senseOut, paceOut, pathOut];
LT = []; 
CLG = [];
GRD = [];
end