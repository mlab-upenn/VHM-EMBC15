 load edge_cov
 load PM_new
 
 t=0;
 a_in=0;
 v_in=0;
 while t<=test(end,1)+100
     t=t+1;
     [a_out,v_out,pass]=PM_tester(test,a_in,v_in,t);
     
     [a_out,v_out,t]
     pace_param=pacemaker_new(pace_param, a_out, v_out, 1);
     a_in=pace_param.a_pace;
     v_in=pace_param.v_pace;
     
     if pass==0
         disp('Test Fail');
         break;
     end
     
 end