//
//  mexHankel.cpp
//  
//
//  Created by Xikang Zhang on 11/6/14.
//
//

#include "mex.h"
#include "matrix.h"

mxArray *process(const mxArray *mx_X)
{
    mwSize m, n;
    mwSize nr, nc;
    mxArray *mx_H;
    double *X, *H;
    mwIndex i, j, offset;
    
    m = mxGetM(mx_X);
    n = mxGetN(mx_X);
    nr = (n+1)/3+1;
    nc = n-nr+1;
    mx_H = mxCreateDoubleMatrix(2*nr, nc, mxREAL);
    
    X = mxGetPr(mx_X);
    H = mxGetPr(mx_H);
    offset = 0;
    for (j=0; j<nc; ++j)
    {
        for(i=0; i<2*nr; ++i)
        {
            H[j*2*nr+i] = X[offset+i];
        }
        offset = offset + 2;
    }
    return mx_H;
}

// matlab entry point
// H = mexHankel(X)
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (nrhs != 1)
        mexErrMsgTxt("Wrong number of inputs");
    if (nlhs != 1)
        mexErrMsgTxt("Wrong number of outputs");
    if (!mxIsDouble(prhs[0]))
        mexErrMsgTxt("input is not double");
    if (mxGetM(prhs[0])!=2)
        mexErrMsgTxt("number of rows is not 2");
    plhs[0] = process(prhs[0]);
}
