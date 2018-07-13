
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

    //for each file; read data and put them in a matrix to be returned
    for i=1:size(csv_files,1)
        ////@DEBUG : display the name of the current file to be read
        //disp(csv_files(i))
        
        //read the file and remove first element (name of the different columns)
        curr=read_csv(csv_files(i));
        
        if(size(curr,2) == 1)
            curr = csvTextScan(curr,';','.','string');
        end
        
        curr(1,:)=[];
        //concatenate to previous data

        x=[x;curr];
    end
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
    //formatted_data = csvTextScan(data,';','.','string');
    formatted_data = data;
    
    formatted_data = normalize_and_fill(formatted_data,idx_col);
    
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

//index for precision
index = [9];
//index for recall
//index = [10];
//index for composite
//index = [11,12,13];

//load all csv files from the current directory
//and rewrite them into a single one without headers
//one after an other

all_data=load_csv_files("../../../../../results/video_synth/results_executions/","motiv_metrics_*");

save_result(all_data,"../../../../../data/video_synth/","all_data.csv");
//all_data= csvRead("../../../../../data/video_synth/all_data.csv",",",".","string");

process_data(all_data,"../../../../../results/video_synth/result_dispersion_score/","metrics_hist_precision.csv",index);
