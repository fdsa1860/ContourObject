//
//  mexIsMember.cpp
//  
//
//  Created by Xikang Zhang on 11/4/14.
//
//

#include <mex.h>
#include <matrix.h>
#include <cmath>

mxArray *process(const mxArray *mx_X, const mxArray *mx_Y)
{
    mwSize nX = mxGetM(mx_X);
    mwSize nY = mxGetM(mx_Y);
    double *X = mxGetPr(mx_X);
    double *Y = mxGetPr(mx_Y);
    
    mxArray *mx_isInside = mxCreateLogicalMatrix(nX, 1);
    bool *isInside = (bool *)mxGetPr(mx_isInside);

    for (mwSize i=0; i<nX; ++i)
    {
        isInside[i] = false;
        for (mwSize j=0; j<nY; ++j)
        {
            if (X[i]==Y[j] && X[i+nX]==Y[nY+j])
            {
                isInside[i] = true;
                break;
            }
        }
    }
    return mx_isInside;
}

// matlab entry point
// D = mexDynamicDistance(X_HH, center_HH)
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (nrhs != 2)
        mexErrMsgTxt("Wrong number of inputs");
    if (nlhs != 1)
        mexErrMsgTxt("Wrong number of outputs");
    if (!mxIsDouble(prhs[0]) || !mxIsDouble(prhs[1]))
        mexErrMsgTxt("Not all inputs are double");
    if (mxGetN(prhs[0]) != 2 || mxGetN(prhs[1]) != 2)
        mexErrMsgTxt("input matrix should have two columns");
    plhs[0] = process(prhs[0], prhs[1]);
}
