 load HM
 load PM_new
 
 t=0;

 while t<=5000
     t=t+1;
     [node_table,path_table]=heart_model(node_table,path_table);
    % Sensing
     a_out=node_table{1,7};
     v_out=node_table{3,7};

     pace_param=pacemaker_new(pace_param, a_out, v_out, 1);
     % pacing
     node_table{1,6}=node_table{1,6} || pace_param.a_pace;
     node_table{3,6}=node_table{3,6} || pace_param.v_pace;


     % PAC
     %node_table{1,7}=1;
     % PVC
     %node_table{3,7}=1;
     
     

 end