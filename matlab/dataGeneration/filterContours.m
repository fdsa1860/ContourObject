% filter coutours

function contours = filterContours(contours,Msk)

validVec = true(length(contours),1);
for i=1:length(contours)
    currContour = contours{i};
    ind = sub2ind(size(Msk),currContour(:,2),currContour(:,1));
    if ~all(Msk(ind))
        validVec(i) = false;
    end
end
contours(~validVec) = [];

end