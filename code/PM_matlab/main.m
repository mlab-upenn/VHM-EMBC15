
load HM
load PM_new

pace_param.P_det=0;
t=0;
ntimeSteps = 5000;
paceOut = zeros(ntimeSteps,2);
senseOut = zeros(ntimeSteps,2);

data=[];
while t<ntimeSteps
    t=t+1;
    [node_table,path_table]=heart_model(node_table,path_table);
    % Sensing
    a_out=node_table{1,7};
    v_out=node_table{3,7};
    senseOut(t,:) = [a_out,v_out];
    
    pace_param=pacemaker_new(pace_param, a_out, v_out, 1);
    % pacing
    node_table{1,6}=node_table{1,6} || pace_param.a_pace;
    node_table{3,6}=node_table{3,6} || pace_param.v_pace;
    paceOut(t,:) = [pace_param.a_pace, pace_param.v_pace];
    
    % PAC
    %node_table{1,6}=1;
    % PVC
    %node_table{3,6}=1;
    if t==1300
        node_table{3,6}=1;
    end
    data=[data,[node_table{1,7};node_table{2,7};node_table{3,7};pace_param.a_pace;pace_param.v_pace]];
    
end

figure
for i=1:size(data,1)
    subplot(size(data,1),1,i);
    plot(data(i,:))
end
