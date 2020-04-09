classdef resonator < matlab.mixin.Copyable & handle
    
    %% properties
    
    properties (Access=private,Hidden)
        optimizer_setup;
    end % optimization options
   
    properties (SetObservable,AbortSet,Hidden)
        max_samples double = 16001;
        smoothing_data double = 0;
        interp_points double =  0;
        touchstone_file;
    end %s-par modifiers
    
    properties (Hidden)
        max_modes=8;
    end %modeling params
       
    properties (Access=private,Constant)
        dxfig= 0.4;
        dyfig= 0.35;
        x0fig=0;
        y0fig=0.3;
        
        dxbar= 0.075;
        dybar= 0.03;
        
        dxlabel = 0.04;
        dylabel = 0.03;
        
        dxbutton = 0.1;
        dybutton = 0.05;
        button_spacing = 0.001;
        checkbox_spacing = 0.01;
        
        x0label = resonator.x0fig+resonator.dxfig-resonator.dxlabel/2;
        y0label = resonator.y0fig+2*resonator.dyfig-3*resonator.dylabel;
        x0bar = resonator.x0label+3*resonator.dxlabel+3*resonator.button_spacing;
        
        buttons_name={...
            "Add Mode",...
            "Remove Mode",...
            "Start Fit",...
            "Stop Fit",...
            "Reset",...
            "Guess Shape",...
            "Rescale Boundaries",...
            "OptimizeAll"};
        name_headings={...
            "Control",...
            "Min",...
            "Max",...
            "Param",...
            "Value",...
            "O"};
        bars_per_column=30;
        
        
    end %graphic positioners
    
    properties (Hidden)
        sparam;
        y_meas;
    end % measured vars
    
    properties (Hidden,Dependent)
        y_calc;
    end% calculated when prompted
    
    properties (SetAccess=private,Hidden)
        c0 opt_param;
        r0 opt_param;
        rs opt_param;
        mode = struct ('fres',opt_param,...
                       'q',opt_param,...
                       'kt2',opt_param);
        freq double;
        freq_smooth double;
        y_smooth double;
    end % physical parameters
    
    properties (Access=private,Hidden)
        figure;
        mag_axis;
        phase_axis;
        mag_legend;
        phase_legend;
        boundaries_bars;
        boundaries_edit;
        param_name_labels;
        param_value_labels;
        action_buttons;
        optim_checkbox;
        headings;
    end % graphic objects

    %% methods 
    
    methods 
        
        function obj =  resonator()
            obj.set_default_param;
            obj.set_freq;
            
            addlistener(obj,'touchstone_file','PostSet',@obj.update_sparam);
            addlistener(obj,'max_samples','PostSet',@obj.update_sparam);
            addlistener(obj,'smoothing_data','PostSet',@obj.update_sparam);
            addlistener(obj,'interp_points','PostSet',@obj.update_sparam);  
%             %to be removed
            cd(fileparts(which('resonator.m')));
            cd ..
            obj.touchstone_file='./Old optimization/Fitting test/R3C5_80MHz_140MHz_Pm20dB_vacuum.s2p';
            obj.smoothing_data=0;
            obj.guess_coarse;
            obj.set_default_boundaries;
        end
        
        function delete(r)
            if ~isempty(r.figure)
                if isobject(r.figure)
                    if isvalid(r.figure)
                        delete(r.figure)
                    end
                end
            end        
        end
        
        reset(r);
        
    end %Constructor/Destructor
    
    methods (Access=private)
        
        x0      =   optim_array(r);
        transform_resonator(r,x0);
        stop    =   out_optim(r,x,flag,state);
        err     =   error_function(r,x0);  
        y       =   calculate_y (r);
        guess_mode(r,index);
        set_freq(r);
        set_sparam(r);
        
        extract_y_from_s(r);
        m   =   calculate_mot_branch(r,index);     
        m   =   calculate_all_mot(r);
        prompt_touchstone(r);
        c0      =   fit_c0(r);
        
        add_mode(r,varargin);
        remove_mode(r,varargin);
        
        set_param(r,index,value,varargin);
        num =   get_param(r,index);
        
        [min,max]   =   get_boundary(r,index);
        set_boundary(r,index,value,type);
        
        function y = n_param(r)
            y= length(r.mode)*3+3;
        end
        
        set_default_param(r);
        set_default_boundaries(r);
        
        flag=run_optim(r);
        
    end % internal functions
    
    methods (Static) %const definition
        str= param_name(index);
        str= param_unit(index);
        n  = param_global_min(index) ;
        n  = param_global_max(index) ;
    end
    
    methods
        fit_routine(r);
        
        guess_coarse(r);   
        
        function y = get.y_calc(r)
            y=calculate_y(r);          
            return;
        end        
    end % main tools
    
    methods
        setup_gui(r);
        setup_plot(r);
        setup_bars(r);
        setup_boundaries_edit(r);
        setup_name_labels(r);
        setup_value_labels(r);
        setup_optim_checkbox(r);
        setup_headings_checkbox(r);
 
        plot_data(r);
        populate_bars(r);
        populate_boundaries_edit(r);
        populate_value_labels(r);
        populate_name_labels(r);
        populate_checkbox(r);
        update_fig(r);
        setup_buttons(r);
        
        delete_gui(r);
    end % Graphic Tools

    methods (Static,Access=private)
        
        function y = db(x)
            y = 20 .* log10 ( abs(x) );
        end
        
        function y = calculate_kt2(fseries,fshunt)
            y   =   pi* fseries/2/fshunt/(tan(pi*fseries/2/fshunt));
        end
        
    end %Mathematical Functions
   
    methods (Static,Access=private,Hidden)
        
        function update_sparam(~,event)
            res=event.AffectedObject;
            res.set_sparam;
            res.set_freq;
            res.extract_y_from_s;
        end
        
        bar_callback(src_event,event,r);       
        edit_callback(src_event,event,r);
        button_callback(src_event,event,r);
        checkbox_callback(src_event,event,r);
    end %Listeners callback
    
end
