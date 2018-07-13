
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
function x=load_csv_files(path,fileregex,idx_test,idx_prop,is_obj_class)
    x=[];
    //not sorted list specifically
    csv_files=listfiles(path+fileregex+'.csv');
    
    //lut between idx_test and label of the tests
    all_data =[];
    if(is_obj_class)
        all_data = csvRead("../../../../../data/coco/"+"all_data_dev_obj_class.csv",",",".","string");
    else
        //all_data = csvRead("../../../../../data/coco/"+"all_data_dev.csv",",",".","string");
        all_data = csvRead("../../../../../data/coco/"+"data_dev_class_best_obj_class.csv",",",".","string");
    end
    all_data(find(all_data(:,1)=="[all]: [all]"),:) = [];
    unique_text_file = unique(all_data(:,1));
    
    set_label = unique_text_file(idx_test);
    
    

    //for each file; read data and put them in a matrix to be returned
    for i=1:size(csv_files,1)
        ////@DEBUG : display the name of the current file to be read
        //disp(csv_files(i))
        
        //read the file and remove first element (name of the different columns)
        curr=read_csv(csv_files(i));
        curr(1,:)=[];
        
        curr_i = [];
        for i=1:prod(size(set_label))
            curr_i = [curr_i, curr(find(curr(:,1) == set_label(i)),idx_prop)];
        end
        
        /*
        //decompose into object classes and others
        curr_obj_class = curr(grep(curr(:,1),': [all]'),:);
        //disp(size(curr_obj_class));
        curr_others = curr;
        disp(size(curr_others));
        
        curr_others(grep(curr(:,1), ': [all]'),:) = [];
        disp(size(curr_others));
        
        curr_i=[];
        if(is_obj_class)
            curr_i = curr_obj_class(idx_test,idx_prop);
        else
            disp(size(curr_i));
            curr_i = curr_others(idx_test,idx_prop);
        end*/
        //concatenate to previous data
        x=[x;curr_i];
    end
endfunction

//
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

//a function to save a matrix in a specified filename
function save_result(m,path,filename)
    csvWrite(m,path+filename);
endfunction


is_obj_class=%t;
//retrieve test cases of interest (index)
if(is_obj_class)
    //s = load_best_set("../../../../../data/coco/best_sets/","best_set_5_dev_obj_class.txt",5);
    s = load_best_set("../../../../../results/coco/","best_5set_dev_training_obj_class.txt",5);
else
    //s = load_best_set("../../../../../data/coco/best_sets/","best_set_5_dev_reduced.txt",5);
    s = load_best_set("../../../../../results/coco/","best_set_5dev_training_reduced.txt",5);
end
disp(s);
s_d = strtod(s); //index in double or integers
//disp(s_d)

//indx of properties of interest
index = [2];

//retrieve data for all files
//data=load_csv_files("../../../../../data/coco/Coco_Dev_2017/data/","*",s_d,index,is_obj_class)
data=load_csv_files("../../../../../data/coco/split/test/","*",s_d,index,is_obj_class)
data_d = strtod(data); //convert into double
//resize
data_form = matrix(data_d,-1,prod(size(s_d)))
//disp(data_form);

//mean of performance of all test cases of interest
data_mean = mean(data_form,'c');
//disp(data_mean)

//sort in descending order
data_mean_sort = gsort(data_mean,'g','d');
//disp(data_mean_sort)

//retrieve from list of files the correct ranking
//files=listfiles("../../../../../data/coco/Coco_Dev_2017/data/*"+'.csv');
files=listfiles("../../../../../data/coco/split/test/*"+'.csv');

l_final=[];
for i=1:prod(size(data_mean_sort))
    idx = find(data_mean==data_mean_sort(i))
    l_final=[l_final;files(idx), string(data_mean(idx)), string(data_form(idx,:))];
end

filename="";
if(is_obj_class)
    //filename="rank_obj_class.csv"
    filename = "rank_obj_class_split_test.csv"
else
    //filename="rank_reduced.csv"
    //filename="rank_reduced_best_obj_class.csv"
    filename="rank_reduced_best_obj_class_split_training.csv"
end
save_result(l_final,"../../../../../results/coco/",filename)
