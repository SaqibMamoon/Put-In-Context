clear all; close all; clc;

system('sqlite3 -header -csv db/expA_what_2.db "select * from expA_what_2;" > csv/results_expA_what_2.csv');

fid = fopen('csv/results_expA_what_2.csv');
out = textscan(fid,'%s');
strtotal = out{1,1};
pattern = 'http://kreiman.hms.harvard.edu/mturk/mengmi/expA_what_data/';

mturkData = [];
answer = [];  
for i = 1:length(strtotal)

    str = strtotal{i,1};    
    k = strfind(str,pattern);    
    if isempty(k)
        continue;
    end
    
    if isempty(strfind(strtotal{i-12},'""uniqueid"":'))
        continue;
    end
    
    if isempty(strfind(strtotal{i-8},'{""current_trial"":'))
        continue;
    end
    
    if isempty(strfind(strtotal{i-5},'{""rt"":'))
        continue;
    end
    
    if isempty(strfind(strtotal{i-3},'""hit"":'))
        continue;
    end
    
    if isempty(strfind(strtotal{i-1},'""imageID"":'))
        continue;
    end
    
    if isempty(strfind(strtotal{i+1},'""trial"":'))
        continue;
    end
    
    if isempty(strfind(strtotal{i+3},'""counterbalance"":'))
        continue;
    end
    
    if isempty(strfind(strtotal{i+7},'""response"":'))
        continue;
    end
    
    strpart = strtotal{i-11};
    strpart = strsplit(strpart,':');
    workerid = strpart{1}(3:end);
    assignmentid = strpart{2}(1:end-3);
    imageID = strtotal{i}(3:end-3);
    response = strtotal{i+8}(3:end-4);
    hit = str2num(strtotal{i-2}(1:end-1));
    counterbalance = str2num(strtotal{i+4}(1:end-1));
    rt = str2num(strtotal{i-4}(1:end-1));
    trial = str2num(strtotal{i+2}(1:end-1));
    
    ans = struct();
    ans.workerid = workerid;
    ans.assignmentid = assignmentid;
    ans.imageID = imageID;
    ans.response = response;
    ans.hit = hit;
    ans.counterbalance = counterbalance;
    ans.rt = rt;
    ans.trial = trial;

    if length(answer) > 0 
        if strcmp(answer(end).workerid,ans.workerid) && strcmp(answer(end).assignmentid,ans.assignmentid)
            answer = [answer ans];
        else
            subj.workerid = ans.workerid;
            subj.assignmentid = assignmentid;
            subj.numhits = length(answer);
            subj.answer = answer;
            subj.videorecord = 0;
            mturkData = [mturkData subj];
            answer = [];
            answer = [answer ans];
        end
    else
        answer = [answer ans];
    end
  
end
subj.workerid = ans.workerid;
subj.assignmentid = assignmentid;
subj.numhits = length(answer);
subj.answer = answer;
subj.videorecord = 0;
mturkData = [mturkData subj];

fclose(fid);
save('Mat/mturk_expA_what_2.mat','mturkData');