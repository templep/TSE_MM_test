// a function to split data into two subsets
// data are stored into two different folders (split/training/ and split/test/) and returned by the function
// the decision of data going into one subset or another is done uniformly (every X files); if at some point indexes go out of range of the number of file, it loops to the begining of the ist of files
//inputs:
//  - path : the path to raw data (each file should be in the same folder)
//  - nb_file : the number of file that should be put in the test subset
//  - seed : the index from which files should be put in the test subset (including the first at index seed)
//output:
//  - train_idx : the index from the list of files that are in the training set
//  - test_idx : the index from the list of files that are in the test set
//
function [train_idx,test_idx] = partition(path,nb_file,seed)
    
    //not sorted list specifically
    csv_files=listfiles(path+'coco_*.csv');
    idx = 1:size(csv_files,1)*2;
    
    //step
    step = size(csv_files,1)/nb_file;
    step = round(step);
    
    disp(step);
    
    test_idx = modulo(idx,step) == 0;
    
    test_idx = find(test_idx == %t);
    test_idx = test_idx(1:nb_file);
    disp(test_idx);
    
    
    test_idx = test_idx - step + seed;
    
    test_idx(find(test_idx > size(csv_files,1))) = test_idx(find(test_idx > size(csv_files,1))) - size(csv_files,1);
    
    //fill train_idx
    train_idx = 1:size(csv_files,1);
    for i =1:size(test_idx,2)
        idx = find(train_idx == test_idx(i));
        train_idx(idx) = [];
    end
    
    //test_idx = test_idx + seed;
    
    //disp(idx);
    disp("results");
    disp(size(csv_files,1));
    disp(test_idx);
    disp(train_idx);
    
    //copy files from test to pre-established folder
    test_files = csv_files(test_idx);
    for i =1:size(test_files,1)
        copyfile(test_files(i),"../../../../../data/coco/split/test/");
    end
    
    //same for training
    train_files = csv_files(train_idx);
    for i =1:size(train_files,1)
        copyfile(train_files(i),"../../../../../data/coco/split/training/");
    end
    
endfunction

function [train_idx,test_idx] = partition2(path,nb_file,seed, step)
    
    //not sorted list specifically
    csv_files=listfiles(path+'coco_*.csv');
    idx = 1:size(csv_files,1)*2;
    
    disp(step);
    
    train_idx = idx(1:seed);
    test_idx = modulo(idx,step) == 0;
    
    test_idx = find(test_idx == %t);
    test_idx = test_idx(1:nb_file);
    disp(test_idx);
    
    
    test_idx = test_idx - step + seed;
    
        test_idx(find(test_idx > size(csv_files,1))) = test_idx(find(test_idx > size(csv_files,1))) - size(csv_files,1);
    
    //test_idx = test_idx + seed;
    
    //disp(idx);
    disp(size(csv_files,1));
    disp(test_idx);
    
    
endfunction

partition("../../../../../data/coco/Coco_Dev_2017/data/",10,52)
