/*=========================================================================
 * function [im2, nc] = mex_sparse_bwlabel(im, n);
 *=========================================================================
 * Fast version of Matlab function bwlabel(). It handles sparse matrices.
 *
 * INPUT
 *   im     A sparse binary image.
 *   n      Number of neighbors. Must be 4, 8 or 24.
 *
 * OUTPUT
 *   im2    Index of the connected components.
 *   nc     Number of connected components.
 *
 *-------------------------------------------------------------------------
 * Qihui Zhu <qihuizhu@seas.upenn.edu>
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
    int *visited, *queue;
    double *im, *sr, *nconn;
    int h, w, x, y, x1, y1, pid, conn, cid, head, tail;
    int i, j, k;
    
    /* 4 or 8 neighborhood */
    /* New: 5*5 neighborhood */
    const int dx[24] = {-1, 0, 0, 1, -1, -1, 1, 1, 2,2,2,2,2,1,0,-1,-2,-2,-2,-2,-2,-1,0,1};
    const int dy[24] = {0, -1, 1, 0, -1, 1, -1, 1,-2,-1,0,1,2,2,2,2,2,1,0,-1,-2,-2,-2,-2};
    
    /* Check argument */
    if (nargin < 2) {
        mexErrMsgTxt("Two input arguments required!");
    }
    if (nargout > 2) {
        mexErrMsgTxt("Too many output arguments!");
    }

    /* Get image */
    irs = mxGetIr(prhs[0]);
    jcs = mxGetJc(prhs[0]);
	im = mxGetPr(prhs[0]);
    h = mxGetM(prhs[0]);
    w = mxGetN(prhs[0]);
    
    /* Get number of connectivity */
    conn = (int)mxGetScalar(prhs[1]);
    if (conn != 4 && conn != 8 && conn != 24){
        mexErrMsgTxt("Connectivity must be 4, 8 or 24!");
    }    
    
    /* Create arrays */
    plhs[0] = mxDuplicateArray(prhs[0]);
    visited = (int *)mxCalloc(h*w, sizeof(int));
    queue = (int *)mxCalloc(2*jcs[w]+1, sizeof(int));   /* in case empty */
    if (queue == NULL || visited == NULL){
        mexErrMsgTxt("Not enough memory!\n");
    }    
    
    /* visited: storing id, -1 for not visited */
    for (i=0; i<w; i++){
        for (j=jcs[i]; j<jcs[i+1]; j++){
            visited[i*h+irs[j]] = -1;
        }
    }
        
    /* Label connected components */
    sr = mxGetPr(plhs[0]);
    cid = 1;
    for (i=0; i<w; i++){
        for (j=jcs[i]; j<jcs[i+1]; j++){
            x = i;
            y = irs[j];
            if (visited[x*h+y] > 0){
                sr[j] = visited[x*h+y];
                continue;
            } else {
                visited[x*h+y] = cid;
            }
            /* Trace component containing (x,y) */
            sr[j] = cid;
            queue[0] = x;
            queue[1] = y;
            head = 0; 
            tail = 2;
            while (tail > head){
                /* Dequeue */
                x = queue[head];
                y = queue[head+1];
                head += 2;
                for (k=0; k<conn; k++){
                    x1 = x + dx[k];
                    y1 = y + dy[k];
                    pid = x1*h + y1;
                    if (x1>=0 && y1>=0 && x1<w && y1<h && visited[pid] == -1){
                        visited[pid] = cid;
                        /* Enqueue */
                        queue[tail]   = x1;
                        queue[tail+1] = y1;
                        tail += 2;
                    }
                }
            }
            cid ++;
        }
    }
    
    /* Number of connected components */
    if (nargout == 2){
        plhs[1] = mxCreateDoubleMatrix(1,1,mxREAL);
        nconn = (double *)mxGetData(plhs[1]);
        nconn[0] = cid-1;
    }
    
    /* Clear up*/
    mxFree(visited);
    mxFree(queue);
}  
