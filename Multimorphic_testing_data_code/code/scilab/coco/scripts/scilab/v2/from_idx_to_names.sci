function s = from_idx_to_name(path_idx,filename_idx,path_names,filename_names)
    //retrieve indexes
    idx = csvRead(path_idx+filename_idx,",",".","double");
    idx($,:)=[];
    //s=idx;
    
    //retrieve names
    all_data = csvRead(path_names+filename_names,",",".","string");
    all_data(find(all_data(:,1)=="[all]: [all]"),:) = [];
    unique_text_file = unique(all_data(:,1));
    s= unique_text_file(idx);
    
end

//names = from_idx_to_name("../../../../../results/coco/","best_5set_dev_reduced.txt","../../../../../data/coco/","all_data_dev_reduced.csv");
//names = from_idx_to_name("../../../../../results/coco/","best_5set_dev_training_obj_class.txt","../../../../../data/coco/","all_data_dev_split_training_obj_class.csv");
//names = from_idx_to_name("../../../../../results/coco/","best_5set_dev_obj_class.txt","../../../../../data/coco/","all_data_dev_obj_class.csv");
names = from_idx_to_name("../../../../../results/coco/","best_3set_dev_obj_class.txt","../../../../../data/coco/","all_data_dev_obj_class.csv");
disp(names);
