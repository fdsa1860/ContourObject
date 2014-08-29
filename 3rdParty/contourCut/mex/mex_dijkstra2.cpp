/*=========================================================================
 * function [dist, prev] = mex_dijkstra2(W, src);
 *=========================================================================
 * Implementation of Dijkstra's shortest path algorithm.
 *
 * INPUT
 *      W       A sparse distance matrix arranged by columns (nxn). W(i,j) 
 *              stores the distance from j to i. 
 *      src     Source node indices (kx1).
 *
 * OUTPUT
 *      dist    Shortest distance (kxn). 
 *      prev    Indices of the previous node in the shortest path (nxk). 
 *
 * Test code:
 * A = sparse([0,2,1;0,0,3;0,0,0]);
 * [dist2, prev2] = mex_dijkstra2(A', 1:3);
 *-------------------------------------------------------------------------
 * Qihui Zhu <qihuizhu@seas.upenn.edu>
 * GRASP Lab, University of Pennsylvania
 * 11/30/2009
 *=========================================================================
 */

#include "math.h"
#include "mex.h"
#include "matrix.h"

#if !defined(MX_API_VER) || MX_API_VER<0x07040000
typedef int mwIndex;
typedef int mwSize;
#endif

// Class definition for heap nodes
class HeapNode{
    public:
        double dist;
        long int ind;
        bool operator < (const HeapNode &n1){
            return (dist<n1.dist);
        }
};

// Decrease key value of a node in the min heap
void decrease_key(HeapNode ** H, long int idx, double val){
    long int parent;
    HeapNode *tmp = H[idx];
    H[idx]->dist = val;
    parent = (idx-1) / 2;
    while (idx>0 && val<H[parent]->dist) {
        H[idx] = H[parent];
        H[idx]->ind = idx;
        idx = parent;
        parent = (parent-1) / 2;
    }
    H[idx] = tmp;
    H[idx]->ind = idx;
}

// Extract the minimal element and remove it from the heap
void extract_min(HeapNode ** H, long int size){
    long int i,left,right,child;
    double dist;
    
    if (size == 0) return;
    i = 0;
    dist = H[size-1]->dist;
    while (i<size) {
        left = 2*i+1;
        right = 2*i+2;
        if (right>=size) {
            if (left>=size)
                break;
            else {
                child = left;
            }    
        } else {
            if (*H[left]<*H[right]) 
                child = left;
            else 
                child = right;
        }
        if (H[child]->dist<dist){
            H[i] = H[child];
            H[i]->ind = i;
            i = child;
        } else
            break;
    }
    H[i] = H[size-1];
    H[i]->ind = i;
}


void dijkstra_sparse(
    long int M,
    long int N,
    long int S,
    double   *D,
    double   *sr,
    mwIndex  *irs,
    mwIndex  *jcs,
    HeapNode *A,
    HeapNode **pHeap,
    double   *prev){
    
    int      finished;
    long int i,startind,endind,whichneighbor,ndone,closest;
    double   closestD,arclength;
    double   INF,SMALL,olddist;
    HeapNode *tmp;
    
    INF   = mxGetInf();
    SMALL = mxGetEps();
    
    for (i=0; i<M; i++){
        if (i==S){
            A[i].dist = (double) SMALL;
            D[i] = (double) SMALL;
            
        } else {
            A[i].dist = (double) INF;
            D[i] = (double) INF;
        }
        A[i].ind = (long int)i;
        pHeap[i] = &A[i];
    }
    // Swap 0 and S
    pHeap[0] = &A[S];
    pHeap[S] = &A[0];
    A[0].ind = S;
    A[S].ind = 0;
    
    // Loop over nonreached nodes
    finished = 0;
    ndone    = 0;
    while ((finished==0) && (ndone < M)){
        closest  = (long int)(pHeap[0]-A); 
        closestD = A[closest].dist;
        
        // pHeap[0] is min for heap
        extract_min(pHeap, M-ndone);
        if ((closest<0) || (closest>=M)) 
            mexErrMsgTxt( "Minimum Index out of bound..." );
        
        D[closest] = closestD;
        
        if (closestD == INF) 
            finished = 1; 
        else {
            // Add the closest to the determined list
            ndone++;
            
            // Relax all nodes adjacent to closest
            startind = jcs[closest];
            endind   = jcs[closest+1] - 1;
            
            for (i=startind; i<=endind; i++){
                whichneighbor = irs[i];
                arclength = sr[i];
                olddist   = D[whichneighbor];
                
                if (olddist > (closestD + arclength)){
                    D[whichneighbor] = closestD + arclength;
                    decrease_key(pHeap, A[whichneighbor].ind, closestD + arclength);
                    
                    // Set previous node
                    prev[whichneighbor] = closest + 1;
                }
            }
        }
    }
}


void mexFunction(
    int          nlhs,
    mxArray      *plhs[],
    int          nrhs,
    const mxArray *prhs[]){
    
    double   *sr,*D,*P,*SS,*Dsmall,*Psmall,*prev;
    mwIndex  *irs,*jcs;
    long int M,N,S,MS,NS,i,j,in;
    HeapNode *A;
    HeapNode **pA;
    
    if (nrhs != 2){
        mexErrMsgTxt( "Only 2 input arguments allowed." );
    } else if (nlhs > 2) {
        mexErrMsgTxt( "Too many output arguments." );
    }
    
    M = mxGetM(prhs[0]);
    N = mxGetN(prhs[0]);
    
    if (M != N) mexErrMsgTxt( "Input matrix needs to be square." );
    
    SS = mxGetPr(prhs[1]);
    MS = mxGetM(prhs[1]);
    NS = mxGetN(prhs[1]);
    
    if ((MS==0) || (NS==0) || ((MS>1) && (NS>1))){
        mexErrMsgTxt( "Source nodes are specified in one dimensional matrix only" );
    }
    if (NS>MS) MS=NS;
    
    plhs[0] = mxCreateDoubleMatrix(MS,M,mxREAL);
    D = mxGetPr(plhs[0]);
    Dsmall = (double *)mxCalloc(M, sizeof(double));
    
    plhs[1] = mxCreateDoubleMatrix(M,MS, mxREAL);
    prev = (double *)mxGetData(plhs[1]);
    
    if (mxIsSparse(prhs[0]) == 1){
        // Dealing with sparse array
        sr      = mxGetPr(prhs[0]);
        irs     = mxGetIr(prhs[0]);
        jcs     = mxGetJc(prhs[0]);

        
        A = new HeapNode[M];
        pA = new HeapNode *[M];

        for (i=0; i<MS; i++){
            
            S = (long int) *( SS + i );
            S--;
            
            if ((S < 0) || (S > M-1))
                mexErrMsgTxt( "Source node(s) out of bound" );
            
            // Run the dijkstra code
            dijkstra_sparse(M,N,S,Dsmall,sr,irs,jcs,A,pA,prev+i*M);
            
            for (j=0; j<M; j++){
                *( D + j*MS + i ) = *( Dsmall + j );
            }           
        }
        delete[] A;
        delete[] pA;
    } else {
        mexErrMsgTxt( "Function not implemented for full arrays" );
    }
}
