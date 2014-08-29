function pixel_order = gen_good_contours(res_info, x, y, imgh, imgw);
% pixel_order = gen_good_contours(res_info, x, y, imgh, imgw);
% 
% 
% Qihui Zhu <qihuizhu@seas.upenn.edu>
% GRASP Lab, University of Pennsylvania
% 02/02/2010


test_cts.res_info = res_info;
test_cts.x = x(:, 1);
test_cts.y = y(:, 1);
test_cts.imgh = imgh; 
test_cts.imgw = imgw;
test_cts = find_loop(test_cts);

jct_id1 = get_jct_overlap(test_cts);
jct_id2 = get_jct_extend(test_cts);
jct_id0 = [jct_id1; jct_id2];
[jct_id, idx] = unique(jct_id0);
test_cts2 = extend_contours(test_cts, jct_id);

pixel_order = test_cts2.pixel_order;