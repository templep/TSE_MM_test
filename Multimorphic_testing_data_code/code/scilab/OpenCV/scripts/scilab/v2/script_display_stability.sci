function meas = display_stability(path,fileregex,test_case_name)
    csv_files=listfiles(path+fileregex+'.csv');
    meas = [];
    
    //ordered reading of files
    nb_files = prod(size(csv_files));
    
    //prepare filename
    //to replace the joker with an index of the file to be processed
    //find the joker; then split the filename according to its position
    idx = strindex(regex,'*');
    if(idx ~= [])
        //assume that the joker is the last character from regex
        filename_base = strsplit(regex,idx-1);
    else
        error("no joker found");
    end
    //else compare idx with length(regex) and
    //use strsplit multiple time on the filename_base (vector)
    
    for i = 1:prod(size(csv_files))            
        curr=read_csv(path+filename_base(1)+string(i-1)+"csv");
        //second column is the dispersion score
        meas=[meas;curr(find(curr(:,1) == test_case_name),2)];
    end
    
    //if(test_case_name is a vector)
    if(prod(size(test_case_name)) ~= 1)
        meas = matrix(meas,[size(test_case_name,1),size(test_case_name,2)]);
    end
    
    //display based on the retrieved measures
    display(meas,nb_files);
    
endfunction

function display(measures,nb_files)
    
    measures_d= strtod(measures);
    nb_instance = size(measures,1)/nb_files;
    
    m_meas = [];
    cpt = 1;
    for i = 1:nb_files
        instances = measures_d(cpt:i*nb_instance,:);
        m= mean(instances);
        m_meas = [m_meas;m];
        cpt = i*nb_instance+1;
    end
    
    plot2d(m_meas);
    
endfunction

display_stability("","metrics_hist_reduced_*","1432")
