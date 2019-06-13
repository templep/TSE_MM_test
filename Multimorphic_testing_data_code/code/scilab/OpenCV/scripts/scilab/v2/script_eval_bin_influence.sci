//a function to create histograms needed to compute dispersion scores
//it also computates associate dispersion scores to videos
//scores and histograms are stored in the given file
//inputs : 
//  - path : the path to the folder where data are
//  - filename : the file name containing are (csv format with ';' separating columns)
//  - idx_col : index of column containing measures of properties of interest
//outputs :
//  all_histogram : all histogram put together
//  nb_rows : number of executions for a video
function [all_histogram,nb_rows] = prepare_data(path,filename,idx_col)
    //read all data
    all_data = csvRead(path+filename,",",".","string");
    
    all_data(find(all_data(:,1)=="[all]: [all]"),:) = [];
    
    all_data = normalize_and_fill(all_data,idx_col);
    
    //retrieve number of histogram to create
    unique_text_file = unique(all_data(:,1));
    nb_rows = size(unique_text_file,1);
    
    //max nb of bins to show
    max_nb_bins=(size(all_data,1)/nb_rows)*4;

    all_disp_scores = [];
    //for each video, retrieve corresponding lines in data, compute histogram and score, save in a matrix
    for(i=1:nb_rows)
        //retrieve lines of interest
        rows = all_data(find(all_data(:,1) == unique_text_file(i)),:);

        //compute histogram and score
        meas = compute_metric(rows,idx_col,max_nb_bins);
        all_disp_scores=[all_disp_scores;meas];
    end
    
    //create the figure
    mini = min(all_disp_scores,"r");
    maxi = max(all_disp_scores,"r");
    
    if(size(mini) ~= size(maxi))
        disp("size mini: "+string(size(mini)));
        disp("size maxi: "+string(size(maxi)));
        error("the size of mini and maxi are different");
    end
    if(prod(size(mini)) ~= max_nb_bins)
        disp("size mini: "+string(size(mini,1))+" "+string(size(mini,2)));
        disp("size maxi: "+string(size(maxi,1))+" "+string(size(maxi,2)));
        disp("expected size: "+string(max_nb_bins))
        error("mini and maxi are not of the expected size")
    end
    
    //plot2d(mini);
    //plot2d(maxi);
    x=[1:size(mini,2)];
    disp(size(x));
    disp(size(mini));
    disp(size(maxi));
    plot2d(x',[mini' maxi'],style=[color("blue"),color("green")],rect=[0,0,size(mini,2),1]);
    legends(['min disp. score';'max disp. score'],[color("blue"),color("green")],opt="ur")
    //plot2d(maxi,"b");
    all_histogram=[];

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
    
    //disp(size(d));
    
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
function measures=compute_metric(m,idx_col,max_nb_bins)
    measure=[];
    //retrieve right data -> column(s))
    perf=m(:,idx_col);
    
    
    //convert to double
    d=strtod(perf);
    
    measures = [];
    ////prepare histogram
    //number of bins
    for nb_bins = 1:max_nb_bins
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
        measures=[measures,measure]
    end
    //nb_bins = size(perf,1);
    
    
    

    //measure = string(measure);
    
    //histogram also converted to string
    //hist = string(cf);
    
endfunction


//observations of interest
//index for precision
cols= [9];
//index for recall
//cols= [10];
//index for composite
//cols= [11,12,13];

//number of observations
nb_col = prod(size(cols));

histograms = prepare_data("../../../../../../data/OpenCV/","all_data.csv",cols);




