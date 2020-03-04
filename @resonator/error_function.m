function y = error_function(res,x0)
    y=[];
    res_cp=res;
    res.array_to_variables(x0);
    res.plot_data;
    res.table_res;
    y_meas =  res.y_smooth;
    y_calc =  res.y_calc;
    freq   =  res.freq;
    
    if isempty(y_meas) || isempty(y_calc)
        fprintf('y_meas or y_calc is empty, abort\n');
        return;
    else
        angle_deg   =   @(x) 180/pi*angle(x);
        mag_err     =   sum ( ...
             abs ( (res.db( y_meas ) - res.db(y_calc))./(res.db(y_calc )) .^2  ));
        phase_err   =   sum ( ...
             abs ( (angle_deg( y_meas ) - angle_deg(y_calc))./(angle_deg(y_calc )) .^2  ));
        
        y           =   ( mag_err + phase_err ) ./ 2;
    end
    
      
%     function y = norm_error(func)
%         y = sum ( ...
%             abs ( (func( y_meas ) - func(y_calc))./(func(y_calc )) .^2  ));
%     end

end

% here we can cap the number of points if the code is too slow...


