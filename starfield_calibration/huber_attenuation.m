function err = huber_attenuation(err, th)
    huber = huber_cost(err, th);
    huber_weight = (huber).^0.5./abs(err);
    err = huber_weight.*err;
end