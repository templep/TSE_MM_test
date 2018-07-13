// load the index of test cases of interest
// inputs:
//  - path: the path to the folder containing the file with indexes of interest
//  - filename: the file containing indexes of test cases of interest
//  - nb_elem: number of element (ndexes) to read from the file
// output:
//  - set5: the set containing indexes of test cases of interest
//
function set5= load_best_set(path,filename,nb_elem)
    set5 = mgetl(path+filename,nb_elem);
endfunction


//a function to load all csv files from a given directory
// inputs : 
//  - path : the path where files containing observations over executions
//  - fileregex : a simple regex  containing data to process
//files containing data to process must be in a csv format with columns separated by ';'
//decimal float values given by a '.' and every cell will be intepreted as a string
//  - idx_test : the indexes of test cases of interest
//  - idx_prop : indexes of properties of interest
//  - is_obj_class : if true, consider only object classes
// outputs :
//  - x : a matrix containing every read data contained in files
function x=load_csv_files(path,fileregex,idx_test,idx_prop)
    x=[];
    
    //lut between idx_test and label of the tests
    //all_data = all_obj_classes
    all_data = csvRead("../../../../../data/coco/"+"all_data_dev_obj_class.csv",",",".","string");
    all_data(find(all_data(:,1)=="[all]: [all]"),:) = [];
    unique_text_file = unique(all_data(:,1));
    
    set_label = unique_text_file(idx_test);
    
    set_obj_class=[];
    for i = 1:prod(size(set_label))
        set_obj_class = [set_obj_class; part(set_label(i),1:strindex(set_label(i),': [all]')-1)];
    end
    
    all_data = csvRead("../../../../../data/coco/"+"all_data_dev_reduced.csv",",",".","string");
    
    curr_i = [];
    curr_i = all_data(grep(all_data,set_obj_class),[1:idx_prop]);
    x=curr_i;
endfunction

//a function to create histograms needed to compute dispersion scores
//it also computates associate dispersion scores to videos
//scores and histograms are stored in the given file
//inputs : 
//  - data : data to build histograms and dispersion scores
//  - path : the path to the folder where results will be saved
//  - filename : the file name containing results (histograms + dispersion score)
//  - idx_col : the column indexes containing property of interest
function process_data(data,path,filename,idx_col)
    //scan csv data to have proper format (string and double are mixted) ->
    //everything in string with decimal noted '.'
    //formatted_data = csvTextScan(data,";",".",'string');
    formatted_data = data;
    
    //unique filenames contained in the data file (consider one video at a time)
    unique_text_file = unique(formatted_data(:,1));
    
    //prepare output file (column header)
    result=["filename","metric","hist"];
    
    //find for each unique filename corresponding rows (= every execution of considered video)
    for(i=1:size(unique_text_file,1))
        
        //find each row -> index in the matrix of formatted data
        rows = formatted_data(find(formatted_data(:,1) == unique_text_file(i)),:);
        //extract corresponding columns and compute histograms as well as dispersion scores
        [measure,hist] = compute_metric(rows,idx_col);
        
        //////store results
        //because histogram is more than size of matrix -> put into a 1x1 mat
        //bins are separated by ' '
        hist = strcat(hist,' ');
        //concatenation of results
        result=[result;unique_text_file(i),measure, hist];
    end
    //save result
    save_result(result,path,filename);
    
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
    //retrieve right data -> column(s))
    perf=m(:,idx_col);
    
    
    //convert to double
    d=strtod(perf);
    
    
    ////prepare histogram
    //number of bins
    nb_bins = size(perf,1);
    
    cf =[];
    ind=[];
    
    //for each column to process
    for i = 1:size(idx_col,2)
        //compute histogram between 0 and 1
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

//a function to save a matrix in a specified filename
function save_result(m,path,filename)
    csvWrite(m,path+filename);
endfunction



//retrieve label of class
s = load_best_set("../../../../../data/coco/best_sets/","best_set_5_dev_obj_class.txt",5);
s_d = strtod(s); //index in double or integers

index = [2];
data=load_csv_files("../../../../../data/coco/Coco_Dev_2017/data/","*",s_d,index)
data_d = strtod(data); //convert into double

save_result(data,"../../../../../data/coco/","data_dev_class_best_obj_class.csv");

process_data(data,"../../../../../results/coco/result_dispersion_score/","metrics_hist_Precision_AP_dev_2017_best_set_obj_class.csv",index);
