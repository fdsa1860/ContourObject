/*=========================================================================
 * function im2 = mex_sparse_imdilate(im, se);
 *=========================================================================
 * Fast version of Matlab function imdilate(). It handles sparse matrices.
 *
 * INPUT
 *   im     A sparse binary image.
 *   se     Structural element for image dilation.
 *
 * OUTPUT
 *   im2    Dilated image.
 *
 *-------------------------------------------------------------------------
 * Qihui Zhu
 * GRASP Lab, University of Pennsylvania
 * 12/17/2008
 *=========================================================================
 */


# include "mex.h"
# include "matrix.h"
# include "math.h"

#if !defined(MX_API_VER) || MX_API_VER<0x07040000
typedef int mwIndex;
typedef int mwSize;
#endif

void mexFunction(
		 int nargout,       mxArray *plhs[],
		 int nargin,  const mxArray *prhs[]
		 )
{
    /* Declare variables */
    mwIndex *irs, *jcs;
    int *tmp_im, *idx;
    double *im, *se, *dx, *dy, *sr;
    int m, n, h, w, cx, cy, nnz, x, y, id, nzmax;
    int i, j, k;
    
    /* Check argument */
    if (nargin < 2) {
        mexErrMsgTxt("Two input arguments required");
    }
    if (nargout > 1) {
        mexErrMsgTxt("Too many output arguments.");
    }

    /* Get image */
    irs = mxGetIr(prhs[0]);
    jcs = mxGetJc(prhs[0]);
	im = mxGetPr(prhs[0]);
    h = mxGetM(prhs[0]);
    w = mxGetN(prhs[0]);
    
    /* Get structure element */
    se = mxGetData(prhs[1]);
    m = mxGetM(prhs[1]);
    n = mxGetN(prhs[1]);
    cy = (int)floor((m-1)/2);
    cx = (int)floor((n-1)/2);
    
    /* Create arrays */
    dx = (double *)mxCalloc(m*n, sizeof(double));
    dy = (double *)mxCalloc(m*n, sizeof(double));
    tmp_im = (int *)mxCalloc(h*w, sizeof(int));
    idx = (int *)mxCalloc((h+1)*w, sizeof(int));
    if (dx == NULL || dy == NULL || tmp_im == NULL){
        mexErrMsgTxt("Not enough memory!\n");
    }
    
    /* Fill in offset array */
    nnz = 0;
    for (i=0; i<m; i++){
        for (j=0; j<n; j++){
            if (se[i+j*m] > 0){
                dx[nnz] = j-cx;
                dy[nnz] = i-cy;
                nnz++;
            }
        }
    }
    
    /* Dilate */ 
    nzmax = 0;
    for (i=0; i<w; i++){
        for (j=jcs[i]; j<jcs[i+1]; j++){
            for (k=0; k<nnz; k++){
                y = irs[j] + dy[k];
                x = i + dx[k];
                id = y+x*h;
                if (x>=0 && y>=0 && x<w && y<h && tmp_im[id]==0){
                    tmp_im[id] ++;
                    nzmax ++;
                    /* idx: (h+1)*w */
                    idx[x*(h+1)] ++;
                    idx[x*(h+1)+idx[x*(h+1)]] = y;
                }
            }
        }
    }
    
    /* Create result matrix */
    plhs[0] = mxCreateSparse(h, w, nzmax, mxREAL);
    sr  = mxGetPr(plhs[0]);
    irs = mxGetIr(plhs[0]);
    jcs = mxGetJc(plhs[0]);
    
    /* Collect jcs,irs from idx */
    jcs[0] = 0;
    for (i=0; i<w; i++){
        jcs[i+1] = jcs[i] + idx[i*(h+1)];
    }
    for (i=0; i<w; i++){
        for (j=jcs[i]; j<jcs[i+1]; j++){
            irs[j] = idx[i*(h+1)+j-jcs[i]+1];
            sr[j] = 1;
        }
    }    
    
    /* Clear up*/
    mxFree(dx);
    mxFree(dy);
    mxFree(tmp_im);
    mxFree(idx);
}  
