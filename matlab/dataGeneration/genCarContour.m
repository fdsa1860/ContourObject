% filter contours according to mask

maskPath = fullfile('..','3Dobject','car');
[~, name_subject, num_subject] =  folderList(maskPath);
numA = 8;
numH = 2;
numS = 3;
numCar = 10;

for iCar=9:numCar
    for iA=1:numA
        for iH=1:numH
            for iS=1:numS
                
                % load mask
                maskFileName = sprintf('/car_%02d/mask/car%d_A%d_H%d_S%d.mask',iCar,iCar,iA,iH,iS);
                Msk = importdata(fullfile(maskPath,maskFileName));
                % Msk = importdata('/car_01/mask/car_A1_H1_S1.mask');
                Msk = Msk';
                Msk = reshape(Msk(3:end),Msk(1),Msk(2));
                
                % load contours
                rawContourPath = fullfile('..','raw_contour');
                rawContourFileName = sprintf('car_%02d_car%d_A%d_H%d_S%d.mat',iCar,iCar,iA,iH,iS);
                contours = importdata(fullfile(rawContourPath, rawContourFileName));
                % contours = importdata('../expData/contourData_zhangxiao/car1.mat');
                
                % set output
                outputPath = fullfile('..','filtered_contour');
                outputFileName = sprintf('car_%02d_car_A%d_H%d_S%d.mat',iCar,iA,iH,iS);
                
                contours = filterContours(contours,Msk);
                
%                 % filter coutours
%                 validVec = true(length(contours),1);
%                 for i=1:length(contours)
%                     currContour = contours{i};
%                     ind = sub2ind(size(Msk),currContour(:,2),currContour(:,1));
%                     if ~all(Msk(ind))
%                         validVec(i) = false;
%                     end
%                 end
%                 contours(~validVec) = [];
                
                % save filtered contours
                save(fullfile(outputPath,outputFileName),'contours');
                
            end
        end
    end
end