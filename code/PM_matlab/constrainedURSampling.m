function nextSample = constrainedURSampling(inpRanges, nInputs, opt)
if ~opt.ur_generation.constrained
    nextSample = (inpRanges(:,1)-inpRanges(:,2)).*rand(nInputs,1)+inpRanges(:,2);
else
    if opt.varying_cp_times
        global staliro_SimulationTime;
        nextSample = zeros(size(inpRanges,1),1);
        %dimU = 1;%size(inpRanges,2);
        nCtrlValues = 10;%nInputs - dimU;
        nextSample(1:nCtrlValues,:) = (inpRanges(1:nCtrlValues,1)-inpRanges(1:nCtrlValues,2)).*rand(nCtrlValues,1)+inpRanges(1:nCtrlValues,2);
        t = 0; % first moment is always 0
        nextSample(nCtrlValues+1,1) = t;
        for cv=nCtrlValues+2:nInputs
            % next moments are chosen uniformly at random in increasingly
            % smaller intervals
            % After ith moment is chosen, the remaining time simTime - tadd
            % is divided into as many intervals as there are moments left.
            % Then the next momemnt tadd is sampled uniformly at random in the
            % next interval. That is the placementInterval
            placementInterval = (staliro_SimulationTime - (opt.ur_generation.minDelay + t))/(nInputs - cv + 1);
            tadd = t + opt.ur_generation.minDelay + (placementInterval)*rand;
            if tadd > staliro_SimulationTime
                break
            end
            nextSample(cv) = tadd;
            t = tadd;
        end
        
    else
        nextSample = (inpRanges(:,1)-inpRanges(:,2)).*rand(nInputs,1)+inpRanges(:,2);
    end
end

end