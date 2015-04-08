function [T, XT, YT, LT, CLG, GRD] =  closedloopheart(XPoint, simTime, steptime,InpSignal)

% steptime
global node_table;
global path_table;
global pace_param;

ntimeSteps = length(steptime);  % because we assume stepsize to be 1ms = one unit
paceOut = zeros(ntimeSteps,2);
senseOut = zeros(ntimeSteps,3);
pathOut = zeros(ntimeSteps,2);
%Pattern:
% Vpace->PA2.state=3->NA2->PA1.state=3->NA1->VPace (repetitive for at least 4 cycles)
% Vpace = pace_param.v_pace
% PA2.state = path_table{2,1}
% NA2 = node_table{2,7}
% PA1.state = path_table{1,1}
% NA1 = node_table{1,7}
% ? time between events
% 
% Timing:
% Vpace-Vpace<600

t=0;
while t<ntimeSteps
    t=t+1;
    % PAC
    %node_table{1,6}=1;
    
    [node_table,path_table,NA3]=heart_model(node_table,path_table);
    % Sensing
    a_out=node_table{1,7};
    v_out=node_table{3,7};
    senseOut(t,:) = [node_table{1,7}, node_table{2,7}, node_table{3,7}];
    
    pace_param=pacemaker_new(pace_param, a_out, v_out, 1);
    % pacing
    node_table{1,6}=node_table{1,6} || pace_param.a_pace;
    node_table{3,6}=node_table{3,6} || pace_param.v_pace || InpSignal(t,1);
    paceOut(t,:) = [pace_param.a_pace, pace_param.v_pace];
    
    pathOut(t,:) = [path_table{1,1}, path_table{2,1}];
    
end

T = steptime;
XT = [];
YT = [senseOut, paceOut, pathOut];
LT = []; 
CLG = [];
GRD = [];
end