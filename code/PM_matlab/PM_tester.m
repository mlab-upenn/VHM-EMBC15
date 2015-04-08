function [a_out,v_out,pass]=PM_tester(test,a_in,v_in,t)

persistent next_sense

if t==1
    next_sense=1;
else
    temp=find(test(next_sense:end,2)<=2);
    next_sense=temp(1);
end

a_out=0;
v_out=0;
pass=1;

if t==test(next_sense,1)
    if test(next_sense,2)==1
        a_out=1;
    else
        v_out=1;
    end
    temp=find(test(next_sense+1:end,2)<=2);
    next_sense=temp(1)+1;
end

if a_in==1
    temp=find(test(:,2)==3);
    if isempty(find(abs(test(temp,1)-t)<=5))
        pass=0;
        return
    end
end

if v_in==1
    temp=find(test(:,2)==4);
    if isempty(find(abs(test(temp,1)-t)<=5))
        pass=0;
        return
    end
end