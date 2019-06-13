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

//a function to save a matrix in a specified filename
//inputs :
//  - m : matrix of data to be saved
//  - path : the path to the directory in which data will be saved
//  - filename : the name of the file containing data to be saved
function save_result(m,path,filename)
    csvWrite(m,path+filename);
endfunction

//a function to load all csv files from a given directory
// inputs : 
//  - path : the path where files containing observations over executions
//  - fileregex : a simple regex  containing data to process
//files containing data to process must be in a csv format with columns separated by ';'
//decimal float values given by a '.' and every cell will be intepreted as a string
// outputs :
//  - x : a matrix containing every read data contained in files

function avg = process_data(nb_idx, nb_line,test_filename, cols)
    
    avg=[];
    //choose tc randomly
    idx_tc = choose_random_index(nb_idx,nb_line);

    for i=1:prod(size(test_filename))
        curr=read_csv(test_filename(i));
        
        if(size(curr,2) == 1)
            curr = csvTextScan(curr,';','.','string');
        end
        
        curr(1,:)=[];
        
        
        //concatenate to previous data
        curr = curr(idx_tc,cols);
        
        ////// @DEBUG
        //disp(curr);
        
        //convert -nan into 0 and from string to double
        curr(find(curr=="-nan")) = "0";
        curr = strtod(curr);
        
        disp(curr');
        
        
        //avg=[avg (sum(curr,2)/nb_idx)];
        // !!!! median instead of average
        //avg=[avg median(curr,'r')];
        avg=[avg curr]
        
    end

endfunction


//////////////////////////  generalization (RQ4) v2    ///////////////////////////////

cols = [9];
//cols = [10];
//cols = [11,12,13];


///// @DEBUG
nb_cols = prod(size(cols));

test_filename = ["../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_1.csv"; "../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_2.csv"; "../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_10_2.csv"; "../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_10_7.csv"; "../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_16.csv"; "../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_24.csv"; "../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_32.csv"; "../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_70.csv"; "../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_89.csv"; "../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_34_208.csv"; "../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_10_105.csv"; "../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_34_212.csv"; "../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_19_111.csv"; "../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_34_216.csv"; "../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_19_116.csv"; "../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_11_208.csv"; "../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_11_303.csv"; "../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_10.csv"; "../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_10_107.csv"; "../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_11_212.csv"; "../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_19.csv"; "../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_19_101.csv"; "../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_19_107.csv"; "../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_19_108.csv"; "../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_19_114.csv"; "../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_19_127.csv"; "../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_19_131.csv"; "../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_19_132.csv"; "../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_44.csv"; "../../../../../../data/OpenCV/execution_measures/motiv_metrics_product_69.csv"];

all_data =[];
nb_file = prod(size(test_filename));

//compute # tc
tmp=read_csv(test_filename(1));
tmp(1,:)=[];
nb_line = size(tmp,1);
disp(nb_line);


nb_iter = 10;
nb_idx = 5;


all_avg = [];
for i =1:nb_iter
    averages = process_data(nb_idx, nb_line,test_filename, cols)
    
    all_avg = [all_avg;averages];
end

save_result(all_avg', "../../../../../../results/OpenCV/RQ2/","test_generalization_10_times_part2.csv");








