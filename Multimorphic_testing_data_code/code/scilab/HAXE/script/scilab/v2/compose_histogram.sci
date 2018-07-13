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
    //retrieve right data -> column
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
        //compute histogram
        [tmp_cf,tmp_ind] = histc([0:nb_bins]/nb_bins,d(:,i));
        //add to final histogram and frequencies
        cf = [cf,tmp_cf'];
        ind=[ind,tmp_ind];
    end
    
    //finalize dispersion score 
    measure = size(unique(ind,'r'),1);
    measure = measure/nb_bins;
    
    //and convert to string if necessary
    //measure = string(measure);
    
    //histogram also converted to string
    hist = string(cf);
    
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
//  - path : the path to the folder where data are
//  - filename : the file name containing are (csv format with ';' separating columns)
//  - idx_col : index of column containing measures of properties of interest
//outputs :
//  all_histogram : all histogram put together
//  nb_rows : number of executions for a video
function [all_histogram,nb_rows] = prepare_data(path,filename,idx_col)
    //read all data
    all_data = csvRead(path+filename,";",".","string");
    
    all_data = normalize_and_fill(all_data,idx_col);
    
    //retrieve number of histogram to create
    unique_text_file = unique(all_data(:,1));
    nb_rows = size(unique_text_file,1);
    
    all_histogram=[];
    
    //for each video, retrieve corresponding lines in data, compute histogram and score, save in a matrix
    for(i=1:nb_rows)
        //retrieve lines of interest
        rows = all_data(find(all_data(:,1) == unique_text_file(i)),:);
        //compute histogram and score
        [measure,hist] = compute_metric(rows,idx_col);
        //////store results
        //because histogram is more than size of matrix -> put into a 1x1 mat
        //bins are separated by ' '
        hist = strcat(hist,' ');
        //concatenation of results
        all_histogram = [all_histogram;hist];
    end
endfunction


//function to create sets of 2 videos
//retrieve the set providing the highest score
//regarding a property of interest combining different observations :
// histograms are kept separated and are processed as one multi-dimensional histogram
//inputs :
//  - histograms : the set of all histograms available
//  - nb_cols : number of execution performed to compute histograms
//outputs : 
//  - measure : the dispersion scores of each possible set
//  - i : the index of the first video of each possible set
//  - j : the index of the second video of each possible set
function [measure,i,j] = compose_2hist(histograms,nb_cols)
    measure = [];
    i = [];
    j = [];
    for curr_i = 1 : size(histograms,1)
        for curr_j = curr_i+1 : size(histograms,1)

            hist1 = csvTextScan(histograms(curr_i),' ','.','double');
            hist2 = csvTextScan(histograms(curr_j),' ','.','double');
            
            //resize so that cols are kept (no mix of different dimensions)
            hist1 = matrix(hist1,nb_cols,-1);
            hist2 = matrix(hist2,nb_cols,-1);
            
            //hist1T and hist2T are transposed of hist1 and hist2 respectively
            //hist1T and hist2T -> 1 line = 1 observation over all columns of interest
            hist1T = hist1';
            hist2T = hist2';
            
            //with different dimensions, a bin is not activated if
            // every bin of each dimension is not activated
            v=[];
            [v1,v2]=find(hist1T~=0);
            v=[v;unique(v1)'];
            [v1,v2]=find(hist2T~=0);
            v=[v;unique(v1)'];
            
            ///////dispersion score is still
            ///////the number of bins activated to the number of executions
            //measure = # of activated bins
            curr_measure = size(unique(v),1);
            //disp(curr_measure);
            //normalize
            nb_bins = max([size(hist1,2),size(hist2,2)]);
            curr_measure = curr_measure/nb_bins;
            
            //save measures and indexes
            measure = [measure; curr_measure];
            i = [i; curr_i];
            j = [j; curr_j];
        end
    end
endfunction

// another way to compute distance between histograms
// it uses the distance between two histograms
// if distance is small, then the two histograms look like and do not bring much more information
// on the contrary, if the distance is high, the histograms are likely to be different
// and could provide a good set
// DEPRECIATED // NOT UPDATED // NOT VERIFIED
//
function [dist, id1,id2] = distance(histograms)
    dist=[];
    id1=[];
    id2=[];
    for i = 1 : size(histograms,1)
        for j = i+1 : size(histograms,1)
            hist1 = csvTextScan(histograms(i),' ','.','double');
            hist2 = csvTextScan(histograms(j),' ','.','double');
            ad=abs(size(hist2,2)-size(hist1,2));
            mad = zeros(1,ad);
            if(size(hist1,2) < size(hist2,2)) then
                hist1 = [hist1,mad];
            else
                hist2 = [hist2,mad];
            end
            hist1_bool = bool2s(hist1~=0);
            hist2_bool = bool2s(hist2~=0);
            
            dist = [dist;norm(hist1_bool-hist2_bool)];
            id1=[id1;i];
            id2=[id2;j];
        end
    end
endfunction

//function to create the set of 2 videos which give the highest dispersion score
//retrieve the set providing the highest score
//regarding a property of interest combining different observations :
// histograms are kept separated and are processed as one multi-dimensional histogram
//inputs :
//  - histograms : the set of all histograms available
//  - nb_cols : number of execution performed to compute histograms
//outputs : 
//  - measure : the dispersion scores of each possible set
//  - i : the index of the first video of each possible set
//  - j : the index of the second video of each possible set
function [best_measure,best_i,best_j] = compose_2hist_best(histograms,nb_cols)
    best_measure = 0;
    best_i = 1;
    best_j = 2;
    for i = 1 : size(histograms,1)
        for j = i+1 : size(histograms,1)
            
            hist1 = csvTextScan(histograms(i),' ','.','double');
            hist2 = csvTextScan(histograms(j),' ','.','double');
            
            //resize so that cols are kept (no mix of different dimensions)
            hist1 = matrix(hist1,nb_cols,-1);
            hist2 = matrix(hist2,nb_cols,-1);
            
            //hist1T and hist2T are transposed of hist1 and hist2 respectively
            //hist1T and hist2T -> 1 line = 1 observation over all columns of interest
            hist1T = hist1';
            hist2T = hist2';
            
            //with different dimensions, a bin is not activated if
            // every bin of each dimension is not activated
            v=[];
            [v1,v2]=find(hist1T~=0);
            v=[v;unique(v1)'];
            [v1,v2]=find(hist2T~=0);
            v=[v;unique(v1)'];
            
            ///////dispersion score is still
            ///////the number of bins activated to the number of executions
            //measure = # of activated bins
            measure = size(unique(v),1);
            //normalize
            nb_bins = max([size(hist1,2),size(hist2,2)]);
            measure = measure/nb_bins;
            
            if(measure > best_measure) then
                best_measure = measure;
                best_i = i;
                best_j = j;
            end
        end
    end
endfunction

//function to create sets of 3 videos
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
function [measure, i, j, k] = compose_3hist(histograms,nb_cols)
    measure = [];
    i = [];
    j = [];
    k = [];
    for curr_i = 1 : size(histograms,1)
        for curr_j = curr_i+1 : size(histograms,1)
            for curr_k= curr_j+1 : size(histograms,1)
                
                hist1 = csvTextScan(histograms(curr_i),' ','.','double');
                hist2 = csvTextScan(histograms(curr_j),' ','.','double');
                hist3 = csvTextScan(histograms(curr_k),' ','.','double');
                
                //resize so that cols are kept (no mix of different dimensions)
                hist1 = matrix(hist1,nb_cols,-1);
                hist2 = matrix(hist2,nb_cols,-1);
                hist3 = matrix(hist3,nb_cols,-1);
                
                //hist1T and hist2T are transposed of hist1 and hist2 respectively
                //hist1T and hist2T -> 1 line = 1 observation over all columns of interest
                hist1T = hist1';
                hist2T = hist2';
                hist3T = hist3';
                
                
                //with different dimensions, a bin is not activated if
                // every bin of each dimension is not activated
                v=[];
                [v1,v2]=find(hist1T~=0);
                v=[v;unique(v1)'];
                [v1,v2]=find(hist2T~=0);
                v=[v;unique(v1)'];
                [v1,v2]=find(hist3T~=0);
                v=[v;unique(v1)'];
                
                ///////dispersion score is still
                ///////the number of bins activated to the number of executions
                //measure = # of activated bins
                curr_measure = size(unique(v),1);
                //normalize
                nb_bins = max([size(hist1,2),size(hist2,2),size(hist3,2)]);
                curr_measure = curr_measure/nb_bins;
                
                //save measures and indexes
                measure = [measure; curr_measure];
                i = [i; curr_i];
                j = [j; curr_j];
                k = [k; curr_k]
            end
        end
    end
endfunction


//function to create the set of 3 videos which gives the highest dispersion score
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
function [best_measure,best_i,best_j, best_k] = compose_3hist_best(histograms,nb_cols)
    best_measure = 0;
    best_i = 1;
    best_j = 2;
    best_k = 3;
    for i = 1 : size(histograms,1)
        for j = i+1 : size(histograms,1)
            for k = j+1 : size(histograms,1)
                hist1 = csvTextScan(histograms(i),' ','.','double');
                hist2 = csvTextScan(histograms(j),' ','.','double');
                hist3 = csvTextScan(histograms(k),' ','.','double');
                
                //resize so that cols are kept (no mix of different dimensions)
                hist1 = matrix(hist1,nb_cols,-1);
                hist2 = matrix(hist2,nb_cols,-1);
                hist3 = matrix(hist3,nb_cols,-1);
                
                //hist1T and hist2T are transposed of hist1 and hist2 respectively
                //hist1T and hist2T -> 1 line = 1 observation over all columns of interest
                hist1T = hist1';
                hist2T = hist2';
                hist3T = hist3';
                
                //with different dimensions, a bin is not activated if
                // every bin of each dimension is not activated
                v=[];
                [v1,v2]=find(hist1T~=0);
                v=[v;unique(v1)'];
                [v1,v2]=find(hist2T~=0);
                v=[v;unique(v1)'];
                [v1,v2]=find(hist3T~=0);
                v=[v;unique(v1)'];
                
                ///////dispersion score is still
                ///////the number of bins activated to the number of executions
                //measure = # of activated bins
                measure = size(unique(v),1);
                //normalize
                nb_bins = max([size(hist1,2),size(hist2,2)]);
                measure = measure/nb_bins;
                
                if(measure > best_measure) then
                    best_measure = measure;
                    best_i = i;
                    best_j = j;
                    best_k = k;
                end
            end
        end
    end
endfunction


//function to create sets of 5 videos
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
function [measure, i, j, k, l, m] = compose_5hist(histograms,nb_cols)
    measure = [];
    i = [];
    j = [];
    k = [];
    l = [];
    m = [];
    for curr_i = 1 : size(histograms,1)
        for curr_j = curr_i+1 : size(histograms,1)
            for curr_k = curr_j+1 : size(histograms,1)
                for curr_l = curr_k+1 :size(histograms,1)
                    for curr_m = curr_l+1 : size(histograms,1)

                        hist1 = csvTextScan(histograms(curr_i),' ','.','double');
                        hist2 = csvTextScan(histograms(curr_j),' ','.','double');
                        hist3 = csvTextScan(histograms(curr_k),' ','.','double');
                        hist4 = csvTextScan(histograms(curr_l),' ','.','double');
                        hist5 = csvTextScan(histograms(curr_m),' ','.','double');
                        
                        //resize so that cols are kept (no mix of different dimensions)
                        hist1 = matrix(hist1,nb_cols,-1);
                        hist2 = matrix(hist2,nb_cols,-1);
                        hist3 = matrix(hist3,nb_cols,-1);
                        hist4 = matrix(hist4,nb_cols,-1);
                        hist5 = matrix(hist5,nb_cols,-1);
                
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
                        curr_measure = size(unique(v),1);
                        //normalize
                        nb_bins = max([size(hist1,2),size(hist2,2),size(hist3,2),size(hist4,2),size(hist5,2)]);
                        curr_measure = curr_measure/nb_bins;
                
                        //save measures and indexes
                        measure = [measure; curr_measure];
                        i = [i; curr_i];
                        j = [j; curr_j];
                        k = [k; curr_k];
                        l = [l; curr_l];
                        m = [m; curr_m];                        
                    end
                end
            end
        end
    end
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
    for i = 1 : size(histograms,1)
        for j = i+1 : size(histograms,1)
            for k = j+1 : size(histograms,1)
                for l = k+1 :size(histograms,1)
                    for m = l+1 : size(histograms,1)

                        hist1 = csvTextScan(histograms(i),' ','.','double');
                        hist2 = csvTextScan(histograms(j),' ','.','double');
                        hist3 = csvTextScan(histograms(k),' ','.','double');
                        hist4 = csvTextScan(histograms(l),' ','.','double');
                        hist5 = csvTextScan(histograms(m),' ','.','double');
                        
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

//observations of interest
cols= [2];
//cols= [3];
//cols= [2,3];
//number of observations
nb_col = prod(size(cols));

////uncomment a line to process desired column
histograms = prepare_data("../../../../../data/HAXE/","all_data.csv",cols);

//histograms_recall = prepare_data("all_data_real.csv",cols);
//histograms_prec = prepare_data("all_data_real.csv",cols);


/////uncomment line to compose different histograms regarding desired measure
//[measure,i,j] = compose_2hist(histograms,nb_col);
//[measure,i,j] = compose_2hist_best(histograms,nb_col);
//[measure,i,j,k] = compose_3hist(histograms,nb_col);
//[measure,i,j,k] = compose_3hist_best(histograms,nb_col);
//[measure,i,j,k,l,m] = compose_5hist(histograms,nb_col);
[measure,i,j,k,l,m] = compose_5hist_best(histograms,nb_col);

////// uncomment to display what indexes have been returned from previous calls
disp(i);
disp(j);
disp(k);
disp(l);
disp(m);

////// display the dispersion score computed
disp(measure);

//////other way to compute distance between different histograms
//[dist,i,j] = distance(histograms);
//disp(dist);


