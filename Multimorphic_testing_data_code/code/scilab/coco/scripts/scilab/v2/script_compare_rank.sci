function data = load_rank(path,filename,score_idx)
    
    //load file
    all_data = csvRead(path+filename,",",".","string");
    
    //concatenate name of technique (1st column) to the indexes to retrieve
    score_idx = [1, score_idx];
    
    //extract the correct columns for each row of the file
    data=all_data(:,score_idx);
endfunction

function [score,relative_idx] = compare_ranks(init_rank,computed_rank)
     score = 0;
     relative_idx=[];
    for i=1:size(init_rank,1)
        //disp(init_rank(i,1));
        
        idx = find(computed_rank(:,1) == init_rank(i,1));
        //disp(idx);
        relative_idx = [relative_idx;init_rank(i,1), string(i), string(idx)];
        
        //score is higher than the real number of modif
        score = score + abs(idx-i);
    end
   
endfunction


function [score,relative_idx] = compare_ranks_spearman(init_rank,computed_rank)
     score = 0;
     relative_idx=[];
     nb_elem = size(init_rank,1);
     for i=1: nb_elem
        //disp(init_rank(i,1));
        
        idx = find(computed_rank(:,1) == init_rank(i,1));
        //disp(idx);
        relative_idx = [relative_idx;init_rank(i,1), string(i), string(idx)];
        
        //score is higher than the real number of modif
        score = score + (idx-i)*(idx-i);
     end
     
     score = 1-(6*score/(nb_elem*nb_elem*nb_elem - nb_elem));
   
endfunction


idx_col=[2];
rebuilt_rank = load_rank("../../../../../results/coco/","rank_reconstructed_from_training_and_test.csv",idx_col);

initial_rank = load_rank("../../../../../data/coco/Coco_Dev_2017/final_ranking/","coco_all_average_dev_bbox_format.csv",idx_col);

initial_rank(1,:) = [];

//[score,diff] = compare_ranks(initial_rank,rebuilt_rank);
[score,diff] = compare_ranks_spearman(initial_rank,rebuilt_rank);
disp(score);
