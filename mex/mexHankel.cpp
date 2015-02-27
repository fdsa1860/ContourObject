//
//  mexHankel.cpp
//  
//
//  Created by Xikang Zhang on 11/6/14.
//
//

#include "mex.h"
#include "matrix.h"
#include <cmath>

mxArray *process(const mxArray *mx_X)
{
    mwSize m, n;
    mwSize nr, nc;
    mxArray *mx_H;
    double *X, *H;
    mwIndex i, j, offset;
    
    m = mxGetM(mx_X);
    n = mxGetN(mx_X);
    nr = ceil(n/(m+1.0));
    nc = n-nr+1;
    mx_H = mxCreateDoubleMatrix(m*nr, nc, mxREAL);
    
    X = mxGetPr(mx_X);
    H = mxGetPr(mx_H);
    offset = 0;
    for (j=0; j<nc; ++j)
    {
        for(i=0; i<m*nr; ++i)
        {
            H[j*m*nr+i] = X[offset+i];
        }
        offset = offset + m;
    }
    return mx_H;
}

mxArray *process(const mxArray *mx_X, const mxArray *mx_D)
{
    mwSize m, n;
    mwSize nr, nc;
    mxArray *mx_H;
    double *X, *H, *D;
    mwIndex i, j, offset;
    
    m = mxGetM(mx_X);
    n = mxGetN(mx_X);
    D = mxGetPr(mx_D);
    nr = (mwSize)floor(D[0]/m);
    nc = (mwSize)D[1];
    if (nr>n || nc>n || nr+nc>n+1 )
        mexErrMsgTxt("nr+nc should not be larger than n+1\n");
    mx_H = mxCreateDoubleMatrix(m*nr, nc, mxREAL);
    
    X = mxGetPr(mx_X);
    H = mxGetPr(mx_H);
    offset = 0;
    for (j=0; j<nc; ++j)
    {
        for(i=0; i<m*nr; ++i)
        {
            H[j*m*nr+i] = X[offset+i];
        }
        offset = offset + m;
    }
    return mx_H;
}

// matlab entry point
// H = mexHankel(X)
// H = mexHankel(X, nrnc)
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (nrhs != 1 && nrhs != 2)
        mexErrMsgTxt("Wrong number of inputs");
    if (nlhs != 1)
        mexErrMsgTxt("Wrong number of outputs");
    if (!mxIsDouble(prhs[0]))
        mexErrMsgTxt("input is not double");
    if (nrhs==1)
        plhs[0] = process(prhs[0]);
    if (nrhs==2)
        plhs[0] = process(prhs[0], prhs[1]);
}
