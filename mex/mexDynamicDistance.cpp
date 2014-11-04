//
//  mexDynamicDistance.cpp
//  
//
//  Created by Xikang Zhang on 11/3/14.
//
//

#include <mex.h>
#include <matrix.h>
#include <cmath>

mxArray *process(const mxArray *mx_X, const mxArray *mx_center)
{
    mwSize nFields_X = mxGetNumberOfFields(mx_X);
    mwSize nStruct_X = mxGetNumberOfElements(mx_X);
    mwSize nFields_center = mxGetNumberOfFields(mx_center);
    mwSize nStruct_center = mxGetNumberOfElements(mx_center);
    
    mxArray *mx_D = mxCreateDoubleMatrix(nStruct_X, nStruct_center, mxREAL);
    double *D = (double *)mxGetPr(mx_D);
    
    mxArray *mx_X_HH;
    mxArray *mx_center_HH;
    
    mwSize ind = 0;
    
    double *X_HH = NULL;
    double *center_HH = NULL;
    
    for(mwSize i=0;i<nStruct_X;++i)
    {
        for(mwSize j=0;j<nStruct_center;++j)
        {
            mx_X_HH = mxGetField(mx_X, i, "HH");
            mx_center_HH = mxGetField(mx_center, j, "HH");
            X_HH = (double *)mxGetPr(mx_X_HH);
            center_HH = (double *)mxGetPr(mx_center_HH);
            mwSize X_rows = mxGetM(mx_X_HH);
            mwSize X_cols = mxGetN(mx_X_HH);
            mwSize center_rows = mxGetM(mx_center_HH);
            mwSize center_cols = mxGetN(mx_center_HH);

            ind = j*nStruct_X+i;
            for (mwSize k=0;k<X_rows*X_cols;++k)
            {
                D[ind] = D[ind] + pow((X_HH[k]+center_HH[k]),2.0);
            }
            D[ind] = sqrt(D[ind]);
            D[ind] = 2 - D[ind];
        }
    }
    
    return mx_D;
}

// matlab entry point
// D = mexDynamicDistance(X_HH, center_HH)
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (nrhs != 2)
        mexErrMsgTxt("Wrong number of inputs");
    if (nlhs != 1)
        mexErrMsgTxt("Wrong number of outputs");
    if (!mxIsStruct(prhs[0]) || !mxIsStruct(prhs[1]))
        mexErrMsgTxt("Not all inputs are struct");
    plhs[0] = process(prhs[0], prhs[1]);
}