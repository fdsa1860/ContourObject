/*=========================================================================
 * function idx_knn = mex_knn_2d(query, feature, k);
 *=========================================================================
 * Find k nearest neighbors of 2D query points from feature points. This is a 
 * simple and fast implementation by chopping points into blocks. For higher 
 * dimensional data, KD tree would give a better performance but our simple 
 * algorithm suffices for 2D edge points
 *
 * INPUT
 *   query      nx2 query matrix where each row contains [x,y] coordinates.
 *   feature    mx2 feature matrix where each row contains [x,y] coordinates.
 *   k          The number of nearest neighbors to compute
 *
 * OUTPUT
 *   idx_knn    kxn matrix whose columns are k nearest neighbor indices of 
 *              query to feature. We have idx_knn(1, i)=i since the point 
 *              itself is the closest.
 *
 * Qihui Zhu <qihuizhu@seas.upenn.edu>
 * GRASP Lab, University of Pennsylvania
 * 02/01/2010
 *=========================================================================
 */

#include "mex.h"
#include "matrix.h"
#include "math.h"
#include "math.h"
#include "float.h"
#include <vector>
#include <utility>
#include <functional>
#include <algorithm>


using namespace std;


#define     MARGIN          0.001
#define     MIN_BLK_NUM     4  
#define     MAX_BLK_NUM     20

double dist_pt2bbox(double x, double y, const double *bbox){
    
    double dx, dy;
    
    /* bbox = [min_x, max_x, min_y, max_y] */
    dx = (x<bbox[0])?(bbox[0]-x):(x-bbox[1]);
    dx = (dx>=0)?dx:0.0;
    dy = (y<bbox[2])?(bbox[2]-y):(y-bbox[3]);
    dy = (dy>=0)?dy:0.0;
    return sqrt(dx*dx+dy*dy);
}


void find_knn(const double *query, int nq, const double *feature, int nf, int k, double *idx_knn){

    int i, j, m, n, p, t, ix, iy, lb, ub, pivot;
    int nx, ny, nblk, nk;
    int *blk_ir, *blk_jc;
    double min_x, max_x, min_y, max_y, len, bound;
    const double *x, *y;
    double *blk_all;
    typedef pair<double, int> pdist;
    vector<pdist> dist_arr = vector<pdist>(nq, pdist(0.0, 0));
    vector<pdist> order;    
    vector<vector<int> > pv;
    
    /* Compute bounding boxes */
    min_x = feature[0];
    max_x = feature[0];
    min_y = feature[nf];
    max_y = feature[nf];    
    x = feature;
    y = feature+nf;
    for (i=1; i<nf; i++){
        min_x = (x[i]<min_x)?x[i]:min_x;
        max_x = (x[i]>max_x)?x[i]:max_x;        
        min_y = (y[i]<min_y)?y[i]:min_y;
        max_y = (y[i]>max_y)?y[i]:max_y;                
    }    
    min_x = (1+MARGIN)*min_x-MARGIN*max_x;
    max_x = (1+MARGIN)*max_x-MARGIN*min_x;
    min_y = (1+MARGIN)*min_y-MARGIN*max_y;
    max_y = (1+MARGIN)*max_y-MARGIN*min_y;
    
    /* Generate blocks */    
    len = sqrt((max_x-min_x)*(max_y-min_y)*k/nf);
    nx = ceil((max_x-min_x)/len);
    ny = ceil((max_y-min_y)/len);
    if (nx<MIN_BLK_NUM || ny<MIN_BLK_NUM){
        len = (((max_x-min_x)>(max_y-min_y))?(max_x-min_x):(max_y-min_y)) / MIN_BLK_NUM;        
    }
    if (nx>MAX_BLK_NUM || ny>MAX_BLK_NUM){
        len = (((max_x-min_x)>(max_y-min_y))?(max_x-min_x):(max_y-min_y)) / MAX_BLK_NUM;        
    }
    nx = ceil((max_x-min_x)/len);
    ny = ceil((max_y-min_y)/len);
    nblk = nx*ny;
    
    /* Construct point-block incidence matrix 
       (a sparse matrix represented by blk_ir, blk_jc) */
    blk_all = (double *)malloc(4*nblk*sizeof(double));
	blk_jc = (int *)malloc((nblk+1)*sizeof(double));
    blk_ir = (int *)malloc(nf*sizeof(double));
    pv = vector<vector<int> >(nf, vector<int>(0));
    
    for (i=0; i<nq; i++){
        ix = (int)((x[i]-min_x)/len);
        iy = (int)((y[i]-min_y)/len);
        pv[iy+ix*ny].push_back(i);
    }
    n = 0;
    for (i=0; i<nblk; i++){
        blk_jc[i] = n;
        for (j=0; j<pv[i].size(); j++){
            blk_ir[n] = pv[i][j];
            n++;
        }
        blk_all[4*i] = i/ny*len+min_x;
        blk_all[4*i+1] = blk_all[4*i]+len;
        blk_all[4*i+2] = i%ny*len+min_y;
        blk_all[4*i+3] = blk_all[4*i+2]+len;        
    }
    blk_jc[nblk] = nf;
    order = vector<pdist>(nblk, pdist(0.0, 0));
        
    /* Find nearest neighbors */
    x = query;
    y = query+nq;
    for (i=0; i<nq; i++){
        for (j=0; j<nblk; j++){
            order[j].first = dist_pt2bbox(x[i], y[i], blk_all+4*j);
            order[j].second = j;            
        }
        sort(order.begin(), order.end(), less<pdist>());
        
        n = 0;
        nk = 0; // Number of nearest neighbors found
        for (j=0; j<nblk; j++){
            /* Add blocks until k nearest neighbors are found */
            p = n;
            for (m=blk_jc[order[j].second]; m<blk_jc[order[j].second+1]; m++){
                t = blk_ir[m];
                dist_arr[n].first = sqrt((feature[t]-x[i])*(feature[t]-x[i])+
                                         (feature[t+nf]-y[i])*(feature[t+nf]-y[i]));
                dist_arr[n].second = t;
                n++;
            }
            if (p==n)  continue;
            
            /* Merge the distance array with the new block */
            sort(dist_arr.begin()+p, dist_arr.begin()+n, less<pdist>());
            inplace_merge(dist_arr.begin()+nk, dist_arr.begin()+p, dist_arr.begin()+n, less<pdist>());
            
            /* Update bound */
            if (j==nblk)  break;
            
            lb = nk;
            ub = n;
            while (lb<ub){
                /* Search for the new distance bound - 
                   the mininum distance greater than that to the next block order[j+1].first */
                pivot = (lb+ub)/2;
                if (dist_arr[pivot].first <= order[j+1].first){
                    lb = pivot+1;
                } else {
                    ub = pivot;
                }
            }
            nk = lb;
            if (nk >= k)  break;
        }
        
        /* Fill in output vector */
        for (j=0; j<k; j++){
            idx_knn[i*k+j] = dist_arr[j].second+1;
        }
    }
    
    free(blk_all);
    free(blk_ir);
    free(blk_jc);    
}

void mexFunction(
		 int nargout,       mxArray *plhs[],
		 int nargin,  const mxArray *prhs[]
		 )
{
    /* Declare variables */
    int k, nq, nf;
    double *query, *feature, *idx_knn;
    
    /* Check argument */
    if (nargin != 3) {
        mexErrMsgTxt("Three input arguments required!");
        return;
    }
    if (nargout > 1) {
        mexErrMsgTxt("Too many output arguments!");
        return;
    }

    /* Get points */
    nq = mxGetM(prhs[0]);
    nf = mxGetM(prhs[1]);    
    if (mxGetN(prhs[0])!=2 || mxGetN(prhs[1])!=2){
        mexErrMsgTxt("Only 2D points are supported!");
        return;
    }
    query = mxGetPr(prhs[0]);
    feature = mxGetPr(prhs[1]);    
    idx_knn = mxGetPr(prhs[2]);
    k = (int)idx_knn[0];
        
    if (nargout > 0){
        plhs[0] = mxCreateDoubleMatrix(k, nq, mxREAL);
        idx_knn = mxGetPr(plhs[0]);
        find_knn(query, nq, feature, nf, k, idx_knn);
    }
    
}  
