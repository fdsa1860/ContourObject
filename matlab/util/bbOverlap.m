function ov = bbOverlap(bbgt, bb)

ov = 0;

bi=[max(bb(1),bbgt(1)) ; max(bb(2),bbgt(2)) ; min(bb(3),bbgt(3)) ; min(bb(4),bbgt(4))];
iw=bi(3)-bi(1)+1;
ih=bi(4)-bi(2)+1;
if iw>0 && ih>0
    % compute overlap as area of intersection / area of union
    ua=(bb(3)-bb(1)+1)*(bb(4)-bb(2)+1)+...
        (bbgt(3)-bbgt(1)+1)*(bbgt(4)-bbgt(2)+1)-...
        iw*ih;
    ov=iw*ih/ua;
end

end