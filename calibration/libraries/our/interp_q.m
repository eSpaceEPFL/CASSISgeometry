function q = interp_q(angle, angleRef, qRef)
  
    [~,I] = min(abs(angleRef - angle));
    q = qRef(:,I);
    
end