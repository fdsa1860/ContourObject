/*=========================================================================
 * function [wa, wb, wc, wd] = egamisdual(x,y,gx,gy,[nr,nc],nb_r_out,sig_e, bending_factor, backward_ratio)
 *=========================================================================
 * Computes the affinity of edges in an image, dual directions are considered for each edgel.
 *
 * INPUT
 *   [x,y] = edgel location in pixel coordinates (integer, pixel id)
 *   [gx,gy] = edgel gradient
 *   [nr,nc] = image size
 *   nb_r_out = neighbourhood radius, [r_out,r_in]
 *   sig_e = sigma for elastic energy
 *
 * OUTPUT
 *   wa = edge affinity matrix, sparse, between edgels specified by [x,y,gx,gy]
 *   wb = edge affinity matrix, sparse, between edgels [x,y,gx,gy] and [x,y,-gx,-gy]
 *   wc = edge affinity matrix, sparse, between edgels [x,y, -gx, -gy] and [x,y,gx,gy]
 *   wd = edge affinity matrix, sparse, between edgels [x,y, -gx, -gy] and [x,y,-gx,-gy]
 *
 *   ******** NOTE: wa/wb/wc/wd[i,j]=weight from edgelet j to i (NOT i to j !!!)  ******
 *
 *   sig_e = sigma for cocircular case
 *
 * test sequence:
    edgemap_body_fill = fake_two_circle_edgemap();
    x = edgemap_body_fill.x;
    y = edgemap_body_fill.y;
    gx = edgemap_body_fill.gx;
    gy = edgemap_body_fill.gy;  
    imgh = edgemap_body_fill.imgh;
    imgw= edgemap_body_fill.imgw;
    bending = 3+1/16;
    nb_r = 10;
    sigma_e = 1 - cos(pi/2);
    [wa, wb, wc, wd] = mex_get_weight_dual(x,y,gx,gy,[imgh, imgw],nb_r, sigma_e, bending, backward_ratio);
    W = [wa', wb'; wc', wd']; % in mex files, wa/wb/wc/wd are stored in columun-first order
    figure(50); clf;
    edgemapex_body = extend_edgemap(edgemap_body_fill);
    check_edge_link_v3(W, edgemapex_body, 50);
 *
 * Modified from Gang Song 2006 & Stella X. Yu, 2002
 *-------------------------------------------------------------------------
 * Qihui Zhu <qihuizhu@seas.upenn.edu>
 * GRASP Lab, University of Pennsylvania
 * 01/20/2010
 *=========================================================================
 */

# include "mex.h"
# include "math.h"

#if !defined(MX_API_VER) || MX_API_VER<0x07040000
typedef int mwIndex;
typedef int mwSize;
#endif

double normalize_angle(double a_i)
{
    /* normalize the angle to [-pi, pi) */
    const double pi = 3.14159265359;
    a_i = a_i+21.0*pi - 2.0*pi* floor((a_i+21.0*pi)/(2.0*pi));
    a_i = (a_i < 0) ? (a_i=a_i+2.0*pi-pi) : (a_i-pi);
    return a_i;

}



void mexFunction(
int nargout,
mxArray *out[],
int nargin,
const mxArray *in[]
)
{
    /* declare variables */
    int m[4], n[4], nr, nc, np, ne, nb, total;
    int js, je, is, ie;
    int i, j, k, s, eg;
    double sig_e, sig_g, sig_r, a, b, c, d, z, alpha, beta, t1, t2, r2, dx, dy, fm;
    double a2, b2, c2, d2;
    double *x, *y, *gx, *gy, *wa, *wb, *wc, *wd,
            *theta; /* edge normal direction */
    double *knn_id;
    int knn;
    mwIndex *ir, *jc;
    double bending_factor, colinear, a_ip,a_jp, a_im, a_jm;
    double bending_ip, bending_im, bending_jp, bending_jm, backward_ratio;
    double contradict_factor;
    int n_tmp;
    
    const double pi = 3.14159265359;
    
    
    /* debug intermeidate var */
    double *cocircular;
    
    bending_factor = 1.5625;
    
    /* check argument */
    if (nargin < 8) {
        mexErrMsgTxt("Not enough input arguments.");
    }
    if (nargout > 4) {
        mexErrMsgTxt("More than four output arguments found.");
    }
    
    /* get edgel information */
    for (k=0; k<4; k++) {
        m[k] = mxGetM(in[k]);
        n[k] = mxGetN(in[k]);
        if (k==0) {
            ne = m[0] * n[0];
        } else {
            if (m[k]*n[k] != ne) {
                mexErrMsgTxt("Edgel information: dimension mismatch");
            }
        }
    }
    x = mxGetPr(in[0]);
    y = mxGetPr(in[1]);
    gx = mxGetPr(in[2]);
    gy = mxGetPr(in[3]);
    
    /* image size not used */
    
    /* get k nearest neighbor */
    knn_id = mxGetPr(in[5]);
    knn = mxGetM(in[5]);
    
    /* get sigma parameters */
    sig_e = mxGetScalar(in[6]);
    
    /* get bending factor */
    bending_factor = mxGetScalar(in[7]);
    
    /* get backward ratio */
    if (nargin == 9){
        backward_ratio = mxGetScalar(in[8]);    
    }
    else{
        backward_ratio = 0.1;
    }
    
    
    /* create intermediate data */
    theta = mxCalloc(ne, sizeof(double)); /* angles */
    
    total = ne * 2*knn;
    ir = mxCalloc(total, sizeof(mwIndex));
    jc = mxCalloc(ne+1, sizeof(mwIndex));
    wa = mxCalloc(total, sizeof(double));
    wb = mxCalloc(total, sizeof(double));
    wc = mxCalloc(total, sizeof(double));
    wd = mxCalloc(total, sizeof(double));
    
    /* cocircular = mxCalloc(total, sizeof(double)); */
    
    if (ir==NULL || jc==NULL || wa==NULL || wb==NULL || wc==NULL || wd==NULL) {
        mexErrMsgTxt("Not enough space for my computation");
    }
    
    for (k=0; k<ne; k++) {
        theta[k] = atan2(gy[k], gx[k]);
    }
    
    
    /* computation */
    total = 0;
    for (s=0; s<ne; s++) {
        jc[s] = (mwIndex)total;
        
        /* scan */
        beta = theta[s];
        for (j=0; j<knn; j++) {
            eg = knn_id[j+s*knn]-1; /* edgel number */
            /* index into relative neighbourhood */
            dx = x[eg] - x[s];
            dy = y[eg] - y[s];
            r2 = dx * dx + dy * dy;
            if (r2 > 0) {
                alpha = atan2(dy,dx);
                a_ip = normalize_angle(beta - pi*0.5-alpha);
                a_im = normalize_angle(beta + pi*0.5-alpha);
                a_jp = 0.5*pi - theta[eg] + alpha;
                a_jm = -pi*0.5 - theta[eg] + alpha;
                bending_ip = cos(bending_factor *a_ip);
                bending_im = cos(bending_factor *a_im);
                bending_jp = cos(bending_factor *a_jp);
                bending_jm = cos(bending_factor *a_jm);
                
                contradict_factor = 0.1;
                
                /* 1/4. compute [gx,gy] and [gx,gy] */
                colinear = (1 - cos(a_ip - a_jp));
                z = exp( -colinear / sig_e);
                z = (z < contradict_factor) ? 0 : z;
                a = (bending_ip > 0) ? ( z  * bending_ip) : 0;
                
                /* 2/4 compute [gx,gy] and [-gx,-gy] */
                /* use a_i from 1/4 */
                colinear = (1 - cos(a_ip - a_jm));
                z = exp( -colinear / sig_e);
                z = (z < contradict_factor) ? 0 : z;
                b = (bending_ip > 0) ? (z * bending_ip) : 0;
                
                /* 3/4 compute [-gx,-gy] and [gx,gy] */
                colinear = (1 - cos(a_im - a_jp));
                z = exp( -colinear / sig_e);
                z = (z < contradict_factor) ? 0 : z;
                c = (bending_im > 0) ? (z * bending_im) : 0;
                
                /* 4/4 compute [-gx,-gy] and [-gx,-gy] */
                colinear = (1 - cos(a_im - a_jm));
                z = exp( -colinear / sig_e);
                z = (z < contradict_factor) ? 0 : z;
                d = (bending_im > 0) ? (z * bending_im) : 0;
                
                ir[total] = (mwIndex)eg;
                wa[total] = a;
                wb[total] = b;
                wc[total] = c;
                wd[total] = d;
                
                total = total + 1;
            }
            else{
                /* acceleration: preallocate space for W(i, i)*/
                if (eg == s){
                    ir[total] = (mwIndex)eg;
                            /* No self loop here */
                    wa[total] = 0;
                    wb[total] = 0;
                    wc[total] = 0;
                    wd[total] = 0;
                    total = total + 1;
                }
            }
        } /* k */
    } /* s */
    jc[ne] = (mwIndex)total;
    
    /* shrink it to the right size */
    out[0] = mxCreateSparse(ne, ne, total, mxREAL);
    out[1] = mxCreateSparse(ne, ne, total, mxREAL);
    out[2] = mxCreateSparse(ne, ne, total, mxREAL);
    out[3] = mxCreateSparse(ne, ne, total, mxREAL);

    if (out[0]==NULL || out[1]==NULL || out[2]==NULL || out[3]==NULL) {
        mexErrMsgTxt("Not enough space for the output matrix");
    }
    memcpy(mxGetJc(out[0]), jc, (ne+1) * sizeof(mwIndex));    
    memcpy(mxGetIr(out[0]), ir, total * sizeof(mwIndex));
    memcpy(mxGetPr(out[0]), wa, total * sizeof(double)); 
    
    memcpy(mxGetJc(out[1]), jc, (ne+1) * sizeof(mwIndex));
    memcpy(mxGetIr(out[1]), ir, total * sizeof(mwIndex));
    memcpy(mxGetPr(out[1]), wb, total * sizeof(double)); 
    

    memcpy(mxGetJc(out[2]), jc, (ne+1) * sizeof(mwIndex));
    memcpy(mxGetIr(out[2]), ir, total * sizeof(mwIndex));
    memcpy(mxGetPr(out[2]), wc, total * sizeof(double)); 

    memcpy(mxGetJc(out[3]), jc, (ne+1) * sizeof(mwIndex));
    memcpy(mxGetIr(out[3]), ir, total * sizeof(mwIndex));
    memcpy(mxGetPr(out[3]), wd, total * sizeof(double)); 

    mxFree(theta);
    mxFree(ir);
    mxFree(jc);
    mxFree(wa);
    mxFree(wb);
    mxFree(wc);
    mxFree(wd);
    
}
