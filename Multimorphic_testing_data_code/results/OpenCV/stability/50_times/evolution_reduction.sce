function save_result(m,filename)
    csvWrite(m,filename);
endfunction


//display results with three different curves
// first curve is the curve representing the mean of computed data
// second and third are respectively data-std_dev and data+std_dev
function [a,b] = display(m,legs,colors,pos)
    
    //clf();
    
    upper_bound = size(m,1);
    x=[1:upper_bound];
    y=m(:,2);
    
    //compute min and max for each iteration
    last_col_idx = size(m,2);
    data = m(:,4:last_col_idx);
    mi = [];
    ma = [];
    res2=[];
    for i = 1:upper_bound
        [idx1,idx2] = find(strtod(data(i,:)) == min(strtod(data(i,:))));
        mi = [mi;data(i,idx2(1))];
        
        [idx3,idx4] = find(strtod(data(i,:)) == max(strtod(data(i,:))));
        ma = [ma;data(i,idx4(1))];
        
        
        //res2=[res2;m(i,1),m(i,2),data(i,idx2(1)),data(i,idx4(1))];
    end
    
    //save_result(res2,filename);
    
    //compute std_dev
    //err = m(:,3);
    //err(1) = "0";
    
    //plot2d(x,strtod(y),1, rect = [0,0,120,0.45]);
    
    //plot min and max
    //plot2d(x,[strtod(y) strtod(mi) strtod(ma)],[1,2,3], leg="average@minimum values@maximumvalues", rect = [0,0,100,1]);
    //plot2d(x,strtod(mi),1, leg="minimum values", rect = [0,0,120,1]);
    //plot2d(x,strtod(ma),1, leg="maximum values", rect = [0,0,120,1]);
    plot2d(x,[strtod(ma) strtod(y) strtod(mi) ],colors, rect = [0,0,100,1.0]);
    //legends(legs,colors)
//    e=gce();
//    hl=legend(legs,pos);
    
    //plot std_dev
    //plot2d(x,strtod(y)-strtod(err),12);
    //plot2d(x,strtod(y)+strtod(err),5);
    
    [a,b] = reglin(x,strtod(y)');
//    plot2d(x,a*x+b,4)
    
endfunction

function [data_rows] = gather_data(video_id)
    files=listfiles("metrics_hist_precision_reduced_*.csv");
    data_rows=[];

    //for each file
    for i = 0 : size(files,1)-1
    //i=0;
        //open in desired order
        curr_file = "metrics_hist_precision_reduced_"+string(i)+".csv";
        
        data = csvRead(curr_file,",",".","string");
        ////for each video
        row_name = "./test/videos_config/MOTIV_GT_Char_000000"+string(video_id)+".xml";
        //retrieve row idexes
        idx = find(data(:,1) == row_name);
        //retrieve data (dispersion score)
        data_tmp = [data(idx,2)]
        //compute mean and std_dev of the video for the desired file
        m = mean(strtod(data_tmp));
        std_dev = stdev(strtod(data_tmp));
        
        //put into matrix
        data_rows= [data_rows; curr_file, string(m), string(std_dev), data_tmp']
    end

endfunction

function everything()
    for i = 1:52
        if( i < 10)
            index = "0"+string(i);
        else
            index = string(i);
        end
        //disp(index)
        res=gather_data(index);

        save_result(res,"./res_stat/res_stat_vid_"+index+".csv");
    end
endfunction

index = "10";

res=gather_data(index);

save_result(res,"./res_stat/res_stat_vid_"+index+".csv");
[a,b] = display(res,[],[5,1,2],"by_coordinates");

disp(a);
disp(b);

index = "51";

res=gather_data(index);

save_result(res,"./res_stat/res_stat_vid_"+index+".csv");
[a,b] = display(res,[],[4,1,3],"");

e=gce();
h=legend(['maximum top','average top','minimum top','maximum bottom','average bottom','minimum bottom'],"by_coordinates")

disp(a);
disp(b);

//everything();


