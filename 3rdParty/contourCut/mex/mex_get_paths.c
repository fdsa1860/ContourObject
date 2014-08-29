/*=========================================================================
 * function [si, sj] = mex_get_paths(x, y, gx, gy, [nr,nc], nb_r);
 *=========================================================================
 * Compute 1D paths from edge points to determine backslash ratio.
 *
 * INPUT
 *   x,y,gx,gy  Edge points
 *   [nr,nc]    Image size [#rows, #columns]
 *   nb_r       Connection radius
 *
 * OUTPUT
 *   si,sj      Indices to construct a sparse matrix W. The ith row W(i, :) 
 *              stores edge points on the 1D path starting from i.
 *    
 *-------------------------------------------------------------------------
 * Qihui Zhu <qihuizhu@seas.upenn.edu>
 * GRASP Lab, University of Pennsylvania
 * 01/20/2010
 *=========================================================================
 */


#include "mex.h"
#include "math.h"
#include "string.h"

#define PI 3.1415926535

void mexFunction(
int nargout,
mxArray *out[],
int nargin,
const mxArray *in[]
)
{
    /* Declare variables */
    int m[4], n[4], nr, nc, np, ne, nb, total;
    int r_out, nb_r, js, je, is, ie, cx, cy, px, py, px2, py2, ind;
    int i, j, k, s, eg, nnz, head, tail;
    double *x, *y, *gx, *gy, *si, *sj;
    int *ei, *ej, *px2eg, *visited, *queue, *prev;
    int dx[] = {0, 0,  1,-1, 1, 1,-1,-1};
    int dy[] = {1, -1, 0, 0, 1,-1, 1,-1};
    
    /* Check argument */
    if (nargin < 6) {
        mexErrMsgTxt("Not enough input arguments.");
    }
    if (nargout > 2) {
        mexErrMsgTxt("More than two output arguments found.");
    }
    
    /* Get edgel information */
    for (k=0; k<4; k++) {
        m[k] = mxGetM(in[k]);
        n[k] = mxGetN(in[k]);
        if (k==0) {
            ne = m[0];
        } else {
            if (k==1){
                if (n[k] != n[0]){
                    mexErrMsgTxt("Edgel information: dimension mismatch for x,y");
                }
                n[k] = 1;
            }
            if (m[k]*n[k] != ne) {
                mexErrMsgTxt("Edgel information: dimension mismatch");
            }
        }
    }
    x = mxGetPr(in[0]);
    y = mxGetPr(in[1]);
    gx = mxGetPr(in[2]);
    gy = mxGetPr(in[3]);
    
    /* Get image size */
    i = mxGetM(in[4]) * mxGetN(in[4]);
    if (i<=0) {
        mexErrMsgTxt("Image size missing");
    }
    si = mxGetData(in[4]);
    nr = (int)si[0];
    if (i>1) {
        nc = (int)si[1];
    } else {
        nc = nr;
    }
    np = nr * nc;
    
    /* Get neighbourhood size */
    i = mxGetM(in[5]) * mxGetN(in[5]);
    if (i<=0) {
        mexErrMsgTxt("Neighborhood radii missing");
    }
    si = mxGetData(in[5]);
    r_out = (int)si[0];
    
    nb_r = r_out + r_out + 1;
    nb = nb_r * nb_r;
    
    /* Create intermediate data */
    px2eg = (int*)malloc(np*sizeof(int));
    ei = (int*)malloc(ne*sizeof(int));         /* edge loc */
    ej = (int*)malloc(ne*sizeof(int));
    si = (double *)malloc(ne*nb_r*nb_r*sizeof(double));
    sj = (double *)malloc(ne*nb_r*nb_r*sizeof(double));
    visited = malloc(nb_r*nb_r*sizeof(int));    
    queue = malloc(nb_r*nb_r*sizeof(int));    
    prev = malloc(nb_r*nb_r*sizeof(int));
    
    if (px2eg==NULL || ei==NULL || ej==NULL || si==NULL || sj==NULL) {
        mexErrMsgTxt("Not enough space for my computation");
    }
    
    /* Address mapping: associate edgel id with its pixel id 
       Assume edgelets are ordered */
    for (i=0; i<np; i++) {
        px2eg[i] = -1;  /* initialization: no edgels */
    }
    for (k=0; k<ne; k++) {
        i = floor(y[k]) - 1;
        j = floor(x[k]) - 1;
        s = i + j * nr;
        px2eg[s] = k;        
        ei[k] = i;
        ej[k] = j;
    }
    for (i=0; i<nb_r*nb_r; i++)  
        visited[i] = 0;
    
    /* Computation */
    nnz = 0;    
    for (s=0; s<ne; s++) {
        
        /* j range */
        js = ej[s] - r_out;
        je = ej[s] + r_out;
        if (js<0)  { js = 0;  }
        if (je>=nc) { je = nc-1; }
        
        /* i range */
        is = ei[s] - r_out;
        ie = ei[s] + r_out;
        if (is<0)  { is = 0;  }
        if (ie>=nr) { ie = nr-1; }
        
        /* Find 1D path */
        for (j=0; j<2; j++){
            /* Two edgel directions */
            head = 0;
            tail = 0;
            queue[0] = nb_r*r_out+r_out;
            prev[0] = -1;
            visited[nb_r*r_out+r_out] = 6*s+3*j+1;
            /* Forward */
            while (tail>=head){
                cx = queue[head]/nb_r-r_out+ej[s];
                cy = queue[head]%nb_r-r_out+ei[s];
                for (i=0; i<8; i++){
                    if (cx+dx[i]<js || cx+dx[i]>je || cy+dy[i]<is || cy+dy[i]>ie || px2eg[cy+dy[i]+(cx+dx[i])*nr] == -1)
                        continue;
                    /* Check if it's along the edgel direction */
                    px = queue[head]/nb_r+dx[i];
                    py = queue[head]%nb_r+dy[i];
                    ind = px2eg[cy+cx*nr];
                    if (head == 0 && -dx[i]*gy[ind]*(1-2*j)+dy[i]*gx[ind]*(1-2*j)>=0){
                        visited[py+px*nb_r] = 6*s+3*j+2;    /* Discard the pixel */
                        continue;
                    }
                    
                    ind = py+px*nb_r;
                    if (visited[ind]<6*s+3*j)  visited[ind] = 6*s+3*j;
                    if (visited[ind]==6*s+3*j){
                        /* Not visited == 6*s & 6*s+3, visited = 6*s+1 & 6*s+4 */
                        tail++;
                        queue[tail] = ind;
                        prev[tail] = head;
                        visited[ind]++;
                    }
                }
                head++;
            }
            /* Backward */
            i = tail;
            while (i>0){
                cx = queue[i]/nb_r-r_out+ej[s];
                cy = queue[i]%nb_r-r_out+ei[s];
                if (visited[queue[i]] < 6*s+3*j+2){
                    si[nnz] = s+1+j*ne;  /* Matlab index is 1-based */
                    sj[nnz] = px2eg[cy+cx*nr]+1;
                    nnz++;
                    visited[queue[i]]++;
                }
                /* Dilate to cover adacent edgels */                
                for (k=0; k<4; k++){
                    px = cx+dx[k];
                    py = cy+dy[k];
                    px2 = px+r_out-ej[s];
                    py2 = py+r_out-ei[s];                    
                    ind = (py+r_out-ei[s])+(px+r_out-ej[s])*nb_r;
                    if (px<0 || py<0 || px>=nc || py>=nr || px2eg[py+px*nr] == -1 || 
                        px2<0 || py2<0 || px2>=nb_r || py2>=nb_r || visited[ind] == 6*s+3*j+2)
                        continue;
                    si[nnz] = s+1+j*ne;  
                    sj[nnz] = px2eg[py+px*nr]+1;
                    nnz++;
                    visited[ind]++;
                }
                i = prev[i];
            }
        } /* j */
    } /* s */
    
    /* Fill in output structure */
    out[0] = mxCreateDoubleMatrix(nnz, 1, mxREAL);
    out[1] = mxCreateDoubleMatrix(nnz, 1, mxREAL);
    memcpy(mxGetPr(out[0]), si, nnz*sizeof(double));
    memcpy(mxGetPr(out[1]), sj, nnz*sizeof(double));
    
    free(px2eg);
    free(ei);
    free(ej);
    free(visited);
    free(queue);
    free(prev);    
    free(si);
    free(sj);    
    
}

