
//a function to choose randomly a number nb_config of observations
//to remove in the range [1,l] (l being the total number of observations ; i.e., the number of line)
//inputs :
//  - nb_config : number of observations to be removed
//  - l : total number of observations
//outputs :
//  - idx_config : randomly chosen observations to be removed
function idx_config = choose_random_index(nb_config,l)
    //random permutation
    r = grand(1,"prm",1:l);
    //choose nb_config first elem in the permutation
    idx_config = r(1:nb_config);
endfunction

//remove idx_config from teh set of observations rows
//inputs : 
//  - rows : the initial set of observations
//  - idx_config : indexes of observations to be removed
//outputs : 
//  - red_rows : reduced set of observations (initial set from which observations have been removed)
function red_rows = remove_idx(rows, idx_config)
    red_rows = rows;
    red_rows(idx_config,:) = [];
endfunction

//a function to save a matrix in a specified filename
//inputs :
//  - m : matrix of data to be saved
//  - path : the path to the directory in which data will be saved
//  - filename : the name of the file containing data to be saved
function save_result(m,path,filename)
    csvWrite(m,path+filename);
endfunction

//a function to normalize and take care of missing values
//the normalization is in [0;1],
//missing values are replaced with '0' (at worst will add a bin)
//each column are treated separately in turn and replace previous values
//inputs :
//  - data : all data that will be processed (even columns which are not of interest)
//  - idx_col : indexes of columns of interest
//outputs :
//  - d : matrix with all columns but columns are interest are normalized and missing value are replaced
function d=normalize_and_fill(data,idx_col)
    
    //copy before replacing needed columns
    d = data;
    
    //for each column of interest, check if no value miss and if normalize in [0;1]
    for i = 1:prod(size(idx_col))
        //consider specific column
        c = data(:,idx_col(i));
        
        //remove possible"-nan" replacing them by '0'
        perf_red = c;
        perf_red(find(c == "-nan"))='0';
        
        ////normalize
        //find columns which are not between [0;1]
        //normalize columns
        temp=strtod(perf_red);
        if(find(temp > 1 | temp < 0) ~= [])
            ma = max(temp);
            mi = min(temp);
            temp = (temp-mi)/(ma-mi);
        end
        
        //replace column with possible changes
//        d=d';
//        d(idx_col(i),:) = temp';
//        d=d';
        d(:,idx_col(i)) = string(temp);
    end
endfunction


function [red_set, test_set] = decouple(data,list_tc,idx_config)
    test_set = [];
    red_set = [];
    for i=1:prod(size(list_tc))
        tc_meas = data(find(data(:,1) == list_tc(i)),:);
        
        test_set = [test_set;tc_meas(idx_config,:)];
        
        tc_meas(idx_config,:)=[];
        red_set= [red_set;tc_meas];
    end
endfunction

//a function to load all csv files from a given directory
// inputs : 
//  - path : the path where files containing observations over executions
//  - fileregex : a simple regex  containing data to process
//files containing data to process must be in a csv format with columns separated by ';'
//decimal float values given by a '.' and every cell will be intepreted as a string
// outputs :
//  - x : a matrix containing every read data contained in files
function x=load_csv_files(path,fileregex)
    x=[];
    //not sorted list specifically
    csv_files=listfiles(path+fileregex+'.csv');
    
    //nb file to retrieve
    nb_iter = size(csv_files,1);

    //for each file; read data and put them in a matrix to be returned
    for i=1:nb_iter
        ////@DEBUG : display the name of the current file to be read
        //disp(csv_files(i))
        
        //read the file and remove first element (name of the different columns)
        curr=read_csv(csv_files(i));
        
        if(size(curr,2) == 1)
            curr = csvTextScan(curr,';','.','string');
        end
        
        if(nb_iter ~= 1)
            curr(1,:)=[];
            //concatenate to previous data
            x=[x;curr];
        else
            x = curr;
        end
    end
endfunction

//a function to create histograms needed to compute dispersion scores
//it also computates associate dispersion scores to videos
//scores and histograms are stored in the given file
//inputs : 
//  - data : data to build histograms and dispersion scores
//  - path : the path to the folder where results will be saved
//  - filename : the file name containing results (histograms + dispersion score)
//  - idx_col : the column indexes containing property of interest
//  - is_rand : a boolean representing whether we should use random test cases or a predefined set
function [best_i,best_j,best_k,best_l,best_m] = process_data(data,path,filename,idx_col,is_rand)
    //scan csv data to have proper format (string and double are mixted) ->
    //everything in string with decimal noted '.'
    //formatted_data = csvTextScan(data,";",".",'string');
    formatted_data = data;
    
    formatted_data = normalize_and_fill(formatted_data,idx_col);
    
    //unique first column (filename)
    unique_text_file = unique(formatted_data(:,1));
    
    //prepare output file (column header)
    result=["filename","metric","hist"];
    
    idx_config =[];
    if(is_rand)
        //compute the maximum number of observations (parameter to remove observations)
        l_max = 0;
    //    //arbitrary high constant value
        l_min = 100000;
        for(i=1:size(unique_text_file,1))
            rows = formatted_data(find(formatted_data(:,1) == unique_text_file(i)),:);
            
            l = size(rows,1);
            if(l > l_max)
                l_max = l;
            end
            if(l < l_min)
                l_min = l;
            end
        end
        
        //find for each unique filename corresponding rows
        //for j = 0 : 100
        
        //number of config to put in test set
        j = 30;
                
        //take indexes at random to be removed
        //cannot remove more than the max number of observations
        if(j>l_max)
            j = l_max-1;
        end
        
        
                
        //choose the index to put appart
        idx_config = choose_random_index(j,l_max);
        
    else
 //       test_filename = ["../../../../../results/video_synth/results_executions/motiv_metrics_product_1.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_2.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_10_2.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_10_7.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_16.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_24.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_32.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_70.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_89.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_34_208.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_10_105.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_44.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_34_213.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_34_212.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_34_206.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_19_121.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_19_125.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_19_115.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_19_107.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_34_124.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_59.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_19_122.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_19_128.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_19_110.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_19_111.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_34_216.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_19_116.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_19_132.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_34.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_34_106.csv"];
        
        
        test_filename = ["../../../../../results/video_synth/results_executions/motiv_metrics_product_1.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_2.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_10_2.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_10_7.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_16.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_24.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_32.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_70.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_89.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_34_208.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_10_105.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_34_212.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_19_111.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_34_216.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_19_116.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_11_208.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_11_303.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_10.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_10_107.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_11_212.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_19.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_19_101.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_19_107.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_19_108.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_19_114.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_19_127.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_19_131.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_19_132.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_44.csv"; "../../../../../results/video_synth/results_executions/motiv_metrics_product_69.csv"];
        
        csv_files=listfiles("../../../../../results/video_synth/results_executions/"+"motiv_metrics_*"+".csv");
        
        for i =1:size(test_filename,1)
            idx_config = [idx_config find(csv_files == test_filename(i))];
        end
    end
        
        
        //extract property (properties) of interest
        data_prop = formatted_data(:,[1 idx_col]);
        
        //decouple data into two sets : the test set and the other set
        //test set will be used to check that our score makes sense
        [red_set, test_set] = decouple(data_prop,unique_text_file,idx_config);
        
        fd=mopen("../../../../../data/video_synth/CV_programs/used_configurations.txt",'r');
        used_config = mgetl(fd,-1);
        mclose(fd);
        //disp(size(used_config));
        
        //save config used for test
        used_config_test = used_config(idx_config,:);
        
        save_result(used_config_test,"../../../../../data/video_synth/generalization/","used_configuration_test.txt");
    
    
    //for each test case in reduced set, compute metric and histogram
    for i=1:size(unique_text_file,1)
        
        red_set2 = red_set(find(red_set(:,1) == unique_text_file(i)),:);
        
        if(red_set2 ~= [])
            [measure,hist] = compute_metric(red_set2);
        
            hist = strcat(hist,' ');
            result=[result;unique_text_file(i),measure, hist];
        end
    end
    
    //save results of histograms and measures for a given set
    save_result(result,"../../../../../data/video_synth/generalization/",filename+"_gener.csv");
    
    save_result(test_set,"../../../../../data/video_synth/generalization/",filename+"_test_set.csv")
    
    
    
    nb_cols = prod(size(idx_col));
    
    // retrieve the best set of 5 histograms
    [best_measure,best_i,best_j,best_k,best_l,best_m] = compose_5hist_best(result(2:$,3),nb_cols);
    disp("afte composition : ");
    disp(best_measure);
    disp(best_i);
    disp(best_j);
    disp(best_k);
    disp(best_l);
    disp(best_m);
    
    //retrieve lines corresponding to test cases in test set
    meas_test1 = test_set(find(test_set(:,1) == unique_text_file(best_i)),:);
    meas_test2 = test_set(find(test_set(:,1) == unique_text_file(best_j)),:);
    meas_test3 = test_set(find(test_set(:,1) == unique_text_file(best_k)),:);
    meas_test4 = test_set(find(test_set(:,1) == unique_text_file(best_l)),:);
    meas_test5 = test_set(find(test_set(:,1) == unique_text_file(best_m)),:);
    
    //save those information
    save_result(meas_test1,"../../../../../results/video_synth/generalization/","tc1.csv"); 
    save_result(meas_test2,"../../../../../results/video_synth/generalization/","tc2.csv");
    save_result(meas_test3,"../../../../../results/video_synth/generalization/","tc3.csv");
    save_result(meas_test4,"../../../../../results/video_synth/generalization/","tc4.csv");
    save_result(meas_test5,"../../../../../results/video_synth/generalization/","tc5.csv");
    
    
endfunction

// computes the histogram of observations and associated dispersion score
// the dispersion score is computed as follows: disp(S) = (#bin of histogram ~= 0 / # of programs)
// which is the ratio of activated bins to the number of programs to execute
// inputs :
//  - m : a matrix containing observations to build histogram and dispersion score
//  - idx_col : index of columns of interest containing observations to take into account
// outputs :
//  - measure : the computed dispersion score based on observations
//  - hist : histogram associated to the dispersion score
function [measure, hist]=compute_metric(m,idx_col)
    measure=[];
    //retrieve right data -> data-first column
    perf=m;
    perf(:,1) = [];
    
    
    //convert to double
    d=strtod(perf);
    
    ////prepare histogram
    //number of bins
    nb_bins = size(perf,1);
    
    cf =[];
    ind=[];
    
    //for each column to process
    for i = 1:size(idx_col,2)
        //compute histogram
        [tmp_cf,tmp_ind] = histc([0:nb_bins]/nb_bins,d(:,i));
        //add to final histogram and frequencies
        cf = [cf,tmp_cf'];
        ind=[ind,tmp_ind];
    end
    
    //finalize dispersion score and convert to string
    measure = size(unique(ind,'r'),1);
    measure = measure/nb_bins;
    measure = string(measure);
    
    //histogram also converted to string
    hist = string(cf);
    
endfunction

//function to create the set of 5 videos which gives the highest dispersion score
//regarding a property of interest combining different observations :
// histograms are kept separated and are processed as one multi-dimensional histogram
//inputs :
//  - histograms : the set of all histograms available
//  - nb_cols : number of execution performed to compute histograms
//outputs : 
//  - measure : the dispersion scores of each possible set
//  - i : the index of the first video of each possible set
//  - j : the index of the second video of each possible set
//  - k : the index of the third video of each possible set
//  - l : the index of the fourth video of each possible set
//  - m : the index of the fifth video of each possible set
function [best_measure,best_i,best_j,best_k,best_l,best_m] = compose_5hist_best(histograms,nb_cols)
    best_measure = 0;
    best_i = 1;
    best_j = 2;
    best_k = 3;
    best_l = 4;
    best_m = 5;
    
    
    
    z=1
    for i = 1 : size(histograms,1)
        for j = i+1 : size(histograms,1)
            for k = j+1 : size(histograms,1)
                for l = k+1 :size(histograms,1)
                    for m = l+1 : size(histograms,1)

                        hist1 = csvTextScan(histograms(i),' ','.',"double");
                        hist2 = csvTextScan(histograms(j),' ','.',"double");
                        hist3 = csvTextScan(histograms(k),' ','.',"double");
                        hist4 = csvTextScan(histograms(l),' ','.',"double");
                        hist5 = csvTextScan(histograms(m),' ','.',"double");

//                        hist2 = histograms(j);
//                        hist3 = histograms(k);
//                        hist4 = histograms(l);
//                        hist5 = histograms(m);
                        
                        //resize so that cols are kept (no mix of different dimensions)
                        hist1 = matrix(hist1,nb_cols,-1);
                        hist2 = matrix(hist2,nb_cols,-1);
                        hist3 = matrix(hist3,nb_cols,-1);
                        hist4 = matrix(hist2,nb_cols,-1);
                        hist5 = matrix(hist3,nb_cols,-1);
                        
                        
                        //hist1T and hist2T are transposed of hist1 and hist2 respectively
                        //hist1T and hist2T -> 1 line = 1 observation over all columns of interest
                        hist1T = hist1';
                        hist2T = hist2';
                        hist3T = hist3';
                        hist4T = hist4';
                        hist5T = hist5';
                        
                        //with different dimensions, a bin is not activated if
                        // every bin of each dimension is not activated
                        v=[];
                        [v1,v2]=find(hist1T~=0);
                        v=[v;unique(v1)'];
                        [v1,v2]=find(hist2T~=0);
                        v=[v;unique(v1)'];
                        [v1,v2]=find(hist3T~=0);
                        v=[v;unique(v1)'];
                        [v1,v2]=find(hist4T~=0);
                        v=[v;unique(v1)'];
                        [v1,v2]=find(hist5T~=0);
                        v=[v;unique(v1)'];
                        
                        ///////dispersion score is still
                        ///////the number of bins activated to the number of executions
                        //measure = # of activated bins
                        measure = size(unique(v),1);
                        //normalize
                        nb_bins = max([size(hist1,2),size(hist2,2),size(hist3,2),size(hist4,2),size(hist5,2)]);
                        measure = measure/nb_bins;
                        
                        if(measure > best_measure) then
                            best_measure = measure;
                            best_i = i;
                            best_j = j;
                            best_k = k;
                            best_l = l;
                            best_m = m;
                        end
                    end
                end
            end
        end
    end
endfunction

function data = display_results(filename,best_i,best_j,best_k,best_l,best_m)
    
    data = read_csv("../../../../../data/video_synth/generalization/"+filename+"_test_set.csv");
    
    reshaped_d = matrix(data(:,2),[30,-1]);
    
    col=[best_i best_j best_k best_l best_m];
    
    //retrieve column of interest
    d_interest = reshaped_d(:,col);
    //convert from string to double
    d_interest = strtod(d_interest);
    
    //x= [1:size(col,2)];
    //plot2d(x,d_interest,style=[-1 -1 -1 -1 -1], rect=[0 -0.2 30 1])
    
    plot2d(d_interest,style=[-1 -1 -1 -1 -1], rect=[0 -0.2 30 1]);
    

endfunction

//load all csv files from the current directory
//and rewrite them into a single one without headers
//one after an other
all_data=load_csv_files("../../../../../data/video_synth/","all_data");

//cols = [9];
//cols = [10];
cols = [11,12,13];

[i,j,k,l,m] = process_data(all_data,"../../../../../results/video_synth/generalization/","metrics_hist_composite_reduced",cols,%f);

////@DEBUG
//i= 1;
//j= 15;
//k = 35;
//l = 36;
//m = 37;

d = display_results("metrics_hist_composite_reduced",i,j,k,l,m);

