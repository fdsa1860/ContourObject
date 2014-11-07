//
//  mexSlideWindowChopContour.cpp
//  
//
//  Created by Xikang Zhang on 11/6/14.
//
//

#include "mex.h"
#include "matrix.h"
#include <cmath>

mxArray *process(const mxArray *mx_X, const mxArray *mx_winSize)
{
    mwSize vel_diff_gap;
    mwSize winSize, velSize;
    mwSize m, n;
    mwSize nStruct_Y, nFields_Y;
    mxArray *mx_Y;
    mxArray *mx_seg_points, *mx_seg_vel, *mx_seg_loc;
    double *X;
    double *seg_points, *seg_vel, *seg_loc;
    mwIndex Y_points_fieldNum, Y_vel_fieldNum, Y_loc_fieldNum;
    mwIndex count;
    mwIndex iY, i, j;
    
    vel_diff_gap = 5;
    winSize = mxGetScalar(mx_winSize);
    m = mxGetM(mx_X);
    n = mxGetN(mx_X);
    velSize = winSize - vel_diff_gap + 1;
    nStruct_Y = m - winSize + 1;
    nFields_Y = 3;
    
    const char *fNames[nFields_Y];
    fNames[0] = "points";
    fNames[1] = "vel";
    fNames[2] = "loc";
    mx_Y = mxCreateStructMatrix(1, nStruct_Y, nFields_Y, fNames);
    
    Y_points_fieldNum = mxGetFieldNumber(mx_Y, "points");
    Y_vel_fieldNum = mxGetFieldNumber(mx_Y, "vel");
    Y_loc_fieldNum = mxGetFieldNumber(mx_Y, "loc");
    
    X = mxGetPr(mx_X);
    for (iY=0; iY<nStruct_Y; ++iY)
    {
        mx_seg_points = mxCreateDoubleMatrix(winSize, n, mxREAL);
        seg_points = mxGetPr(mx_seg_points);
        count = 0;
        for (j=0; j<n; ++j)
        {
            for (i=iY; i<iY+winSize; ++i)
            {
                seg_points[count++] = X[j*m+i];
            }
        }
        
        mx_seg_vel = mxCreateDoubleMatrix(velSize, n, mxREAL);
        seg_vel = mxGetPr(mx_seg_vel);
        count = 0;
        for (j=0; j<n; ++j)
        {
            for (i=0; i<velSize; ++i)
            {
                seg_vel[count++] = seg_points[j*winSize+i] - seg_points[j*winSize+i+vel_diff_gap-1];
            }
        }
        
        mx_seg_loc = mxCreateDoubleMatrix(1, 2, mxREAL);
        seg_loc = mxGetPr(mx_seg_loc);
        seg_loc[0] = seg_points[winSize+(winSize-1)/2];
        seg_loc[1] = seg_points[(winSize-1)/2];
        
        mxSetFieldByNumber(mx_Y, iY, Y_points_fieldNum, mx_seg_points);
        mxSetFieldByNumber(mx_Y, iY, Y_vel_fieldNum, mx_seg_vel);
        mxSetFieldByNumber(mx_Y, iY, Y_loc_fieldNum, mx_seg_loc);
    }
    return mx_Y;
}

// matlab entry point
// seg = mexContour2Seg(points, winSize)
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (nrhs != 2)
        mexErrMsgTxt("Wrong number of inputs");
    if (nlhs != 1)
        mexErrMsgTxt("Wrong number of outputs");
    plhs[0] = process(prhs[0], prhs[1]);
}
