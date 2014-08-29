% loading contours
clear all
close all
%%
addpath(genpath('../3rdParty/contourCut'));
% para = current_para;
min_len = 15;

% datapath = 'F:\dataset';
dataset = '../3Dobject/car';
outputPath = fullfile('..','raw_contour');
[~,name_subject,num_subject] = folderList(dataset);

% Using first 5 subjects as the training, the others as testing
% Only using sacle 1 in training
for s = 1:num_subject
    info_pics = dir([dataset, '/', name_subject{s}, '/*.bmp']);
    for i = 1:length(info_pics)
        tmp_cont = {};
%         if (isempty(strfind(info_pics(i).name, 'S1')))
%             continue;
%         end
        img = im2double(imread([dataset,'/',name_subject{s},'/',info_pics(i).name]));
        [cont_info] = run_contour(img, 100, 500);
        for c = 1:length(cont_info.pixel_order)
            x = cont_info.x(cont_info.pixel_order{c});
            y = cont_info.y(cont_info.pixel_order{c});
            if (length(x)<min_len)
                continue;
            end
            tmp_cont = [tmp_cont;[x,y]];
        end
        fig = figure;
        subplot2(1,1,1,1);
        imshow(img);
        hold on;
        c = rand(numel(tmp_cont),3);
        for p = 1:numel(tmp_cont)
            plot(tmp_cont{p}(:,1),tmp_cont{p}(:,2),'.-', 'color', c(p,:));
        end
%         saveas(fig,['trainImg/',info_pics(i).name]);
        hold off;
        close all;
        [~,picName,~] = fileparts(info_pics(i).name);
        outputFileName = [name_subject{s} '_' picName];
        save(fullfile(outputPath,outputFileName),'tmp_cont');
    end

%     save('contour.mat','r','s','i','-v7.3');
end

rmpath(genpath('../3rdParty/contourCut'));