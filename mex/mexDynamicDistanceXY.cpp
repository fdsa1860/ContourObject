//
//  mexDynamicDistanceXY.cpp
//  
//
//  Created by Xikang Zhang on 2/25/15.
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
    double Dx[nStruct_X*nStruct_center], Dy[nStruct_X*nStruct_center];
    
    mxArray *mx_X_HHx, *mx_X_HHy;
    mxArray *mx_center_HHx, *mx_center_HHy;
    
    mwSize ind = 0;
    
    double *X_HHx = NULL, *X_HHy = NULL;
    double *center_HHx = NULL, *center_HHy = NULL;
    
    for(mwSize i=0;i<nStruct_X;++i)
    {
        for(mwSize j=0;j<nStruct_center;++j)
        {
            mx_X_HHx = mxGetField(mx_X, i, "HHx");
            mx_X_HHy = mxGetField(mx_X, i, "HHy");
            mx_center_HHx = mxGetField(mx_center, j, "HHx");
            mx_center_HHy = mxGetField(mx_center, j, "HHy");
            X_HHx = (double *)mxGetPr(mx_X_HHx);
            X_HHy = (double *)mxGetPr(mx_X_HHy);
            center_HHx = (double *)mxGetPr(mx_center_HHx);
            center_HHy = (double *)mxGetPr(mx_center_HHy);
            mwSize X_rows = mxGetM(mx_X_HHx);
            mwSize X_cols = mxGetN(mx_X_HHx);
            mwSize center_rows = mxGetM(mx_center_HHx);
            mwSize center_cols = mxGetN(mx_center_HHx);
            
            if (X_rows!=mxGetM(mx_X_HHy) || X_cols!=mxGetN(mx_X_HHy))
                mexErrMsgTxt("The size of the X_HHx are not the same as X_HHy!");
            if (center_rows!=mxGetM(mx_center_HHy) || center_cols!=mxGetN(mx_center_HHy))
                mexErrMsgTxt("The size of the center_HHx are not the same as center_HHy!");
            if (X_rows!=center_rows || X_cols!=center_cols)
                mexErrMsgTxt("The size of the input hankel matrices are not the same!");
            
            ind = j*nStruct_X+i;
            Dx[ind] = 0.0;
            Dy[ind] = 0.0;
            for (mwSize k=0;k<X_rows*X_cols;++k)
            {
                Dx[ind] = Dx[ind] + pow((X_HHx[k]+center_HHx[k]),2.0);
                Dy[ind] = Dy[ind] + pow((X_HHy[k]+center_HHy[k]),2.0);
            }
            Dx[ind] = sqrt(Dx[ind]);
            Dy[ind] = sqrt(Dy[ind]);
            D[ind] = 2 - 0.5*Dx[ind] - 0.5*Dy[ind];
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
