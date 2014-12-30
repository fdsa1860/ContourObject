
#include <math.h>
#include "mex.h"

// small value, used to avoid division by zero
#define eps 0.0001

static inline float min(float x, float y) { return (x <= y ? x : y); }
static inline float max(float x, float y) { return (x <= y ? y : x); }

static inline int min(int x, int y) { return (x <= y ? x : y); }
static inline int max(int x, int y) { return (x <= y ? y : x); }

// main function:
// takes histogram matrix
// returns normalized feature matrix
mxArray *process(const mxArray *mxHist)
{
    float *hist = (float *)mxGetPr(mxHist);
    const int *dims = mxGetDimensions(mxHist);
    if (mxGetNumberOfDimensions(mxHist) != 3 ||
        mxGetClassID(mxHist) != mxSINGLE_CLASS)
        mexErrMsgTxt("Invalid input");
    
    // memory for norms
    float *norm = (float *)mxCalloc(dims[0]*dims[1], sizeof(float));
    
    // memory for normalized features
    int out[3];
    out[0] = max(dims[0]-2, 0);
    out[1] = max(dims[1]-2, 0);
    out[2] = 4*dims[2];
    mxArray *mxfeat = mxCreateNumericArray(3, out, mxSINGLE_CLASS, mxREAL);
    float *feat = (float *)mxGetPr(mxfeat);
    
    // compute energy in each block
    for (int o = 0; o < dims[2]; o++) {
        float *src = hist + o*dims[0]*dims[1];
        float *dst = norm;
        float *end = norm + dims[1]*dims[0];
        while (dst < end) {
            *(dst++) += (*src * *src);
            src++;
        }
    }
    
    // compute features
    for (int x = 0; x < out[1]; x++) {
        for (int y = 0; y < out[0]; y++) {
            float *dst = feat + x*out[0] + y;
            float *src, *p, n1, n2, n3, n4;
            
            p = norm + x*dims[0] + y;
            n1 = 1.0 / sqrt(*p + *(p+1) + *(p+dims[0]) + *(p+dims[0]+1) + eps);
            p = norm + (x+1)*dims[0] + y;
            n2 = 1.0 / sqrt(*p + *(p+1) + *(p+dims[0]) + *(p+dims[0]+1) + eps);
            p = norm + x*dims[0] + y+1;
            n3 = 1.0 / sqrt(*p + *(p+1) + *(p+dims[0]) + *(p+dims[0]+1) + eps);
            p = norm + (x+1)*dims[0] + y+1;
            n4 = 1.0 / sqrt(*p + *(p+1) + *(p+dims[0]) + *(p+dims[0]+1) + eps);
            
            // contrast-sensitive features
            src = hist + (x+1)*dims[0] + (y+1);
            for (int o = 0; o < dims[2]; o++) {
                *dst = min(*src * n1, 0.2);
                dst += out[0]*out[1];
                *dst = min(*src * n2, 0.2);
                dst += out[0]*out[1];
                *dst = min(*src * n3, 0.2);
                dst += out[0]*out[1];
                *dst = min(*src * n4, 0.2);
                dst += out[0]*out[1];
                src += dims[0]*dims[1];
            }
        }
    }
    mxFree(norm);
    return mxfeat;
}

// matlab entry point
// feat = mexBlockNormalization_cellwise(hist)
// image should be color with double values
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    if (nrhs != 1)
        mexErrMsgTxt("Wrong number of inputs");
    if (nlhs != 1)
        mexErrMsgTxt("Wrong number of outputs");
    plhs[0] = process(prhs[0]);
}
