/*================================================================
* function [i,j] = cimgnbmap([nr,nc], nb_r, sample_rate, ind)
*   computes the neighbourhood index matrix of an image,
*   with each neighbourhood sampled.
* Input:
*   [nr,nc] = image size
*   nb_r = neighbourhood radius, could be [r_i,r_j] for i,j
*   sample_rate = sampling rate, default = 1
* Output:
*   [i,j] = each is a column vector, give indices of neighbour pairs
*     UINT32 type
*       i is of total length of valid elements, 0 for first row
*       j is of length nr * nc + 1
* Revised from 
* Stella X. Yu, Nov 12, 2001.

*=================================================================*/

# include "mex.h"
# include "math.h"

void mexFunction(
    int nargout,
    mxArray *out[],
    int nargin,
    const mxArray *in[]
)
{
    /* declare variables */
    int nr, nc, np, nb, total;
	double *dim, sample_rate, *xy;
    int r_i, r_j, a1, a2, b1, b2, self, neighbor;
    int i, j, k, s, t, nsamp, th_rand, no_sample;
    /* unsigned long *p, *qi, *qj; */
    unsigned int *p, *qi, *qj, *mask;
    
    /* check argument */
    if (nargin < 2) {
        mexErrMsgTxt("Two input arguments required");
    }
    if (nargout> 2) {
        mexErrMsgTxt("Too many output arguments.");
    }

    /* get image size */
    i = mxGetM(in[0]);
    j = mxGetN(in[0]);
    dim = mxGetData(in[0]);
    nr = (int)dim[0];
    if (j>1 || i>1) {
        nc = (int)dim[1];
    } else {
        nc = nr;
    }
    np = nr * nc;
    
    /* get neighbourhood size */
    i = mxGetM(in[1]);
    j = mxGetN(in[1]);
    dim = mxGetData(in[1]);
    r_i = (int)dim[0];
    if (j>1 || i>1) {
        r_j = (int)dim[1];		
    } else {
        r_j = r_i;
    }
    if (r_i<0) { r_i = 0; }
	if (r_j<0) { r_j = 0; }

	/* get sample rate */
	if (nargin==3) {		
		sample_rate = (mxGetM(in[2])==0) ? 1: mxGetScalar(in[2]);
    } else {
		sample_rate = 1;
    }
    
    /* Get indices */
    mask = mxCalloc(np, sizeof(unsigned int));
    if (nargin == 4){
        for (i=0; i<np; i++){
            mask[i] = 0;
        }   
        i = mxGetM(in[3]);
        j = mxGetN(in[3]);
        j = (i>j) ? i : j;
        xy = mxGetData(in[3]);
        /* xy must be unique */
        for (i=0; i<j; i++){
            mask[(int)xy[i]-1] = i+1;
        }
    } else {
        for (i=0; i<np; i++){
            mask[i] = i+1;
        }
    }
    
    
	/* prepare for random number generator */
	if (sample_rate<1) {
        srand( (unsigned)time( NULL ) );
        th_rand = (int)ceil((double)RAND_MAX * sample_rate);
        no_sample = 0;
    } else {
		sample_rate = 1;
        th_rand = RAND_MAX;
        no_sample = 1;
    }
    
	/* figure out neighbourhood size */

    nb = (r_i + r_i + 1) * (r_j + r_j + 1); 
    if (nb>np) {
        nb = np;
    }
    nb = (int)ceil((double)nb * sample_rate);    
    p = mxCalloc(np * (nb+1), sizeof(unsigned int));
	if (p==NULL) {
        mexErrMsgTxt("Not enough space for my computation.");
	}
	
    /* computation */    
	total = 0;
	for (j=0; j<nc; j++) {
    for (i=0; i<nr; i++) {

		self = i + j * nr;

        if (mask[self] == 0)    {   continue;   }
        
		/* put self in, otherwise the index is not ordered */
		p[self] = p[self] + 1;
		p[self+p[self]*np] = mask[self];
   
        /* j range */
		b1 = j;
        b2 = j + r_j;
        if (b2>=nc) { b2 = nc-1; }                
 
		/* i range */
        a1 = i - r_i;
		if (a1<0) { a1 = 0; }
        a2 = i + r_i;
        if (a2>=nr) { a2 = nr-1; }
     
		/* number of more samples needed */
		nsamp = nb - p[self];
		k = 0;		
		t = b1;
		s = i + 1;
		if (s>a2) {
			s = a1;
			t = t + 1;
		}
		   
		
		while (k<nsamp && t<=b2) {
		
            neighbor = s + t * nr;
			if (mask[neighbor] && (no_sample || (rand()<th_rand))) {
				k = k + 1;
				p[self] = p[self] + 1;					
				p[self+p[self]*np] = mask[neighbor];
				p[neighbor] = p[neighbor] + 1;
				p[neighbor+p[neighbor]*np] = mask[self];
            }
				  	    
			s = s + 1;
			if (s>a2) {
                s = a1;
				t = t + 1;
			}
		} /* k */
  	} /* i */
  	   
    } /* j */
   
    /* i, j */
    total = 0;
    for (i=0; i<np; i++){
        total += p[i];
    }
    
    
    out[0] = mxCreateNumericMatrix(total, 1, mxUINT32_CLASS, mxREAL);
	out[1] = mxCreateNumericMatrix(total, 1, mxUINT32_CLASS, mxREAL);
	qi = mxGetData(out[0]);
	qj = mxGetData(out[1]);
	  
	if (out[0]==NULL || out[1]==NULL) {
	    mexErrMsgTxt("Not enough space for the output matrix.");
	}

	total = 0;
    for (j=0; j<np; j++) {
        if (mask[j] == 0)   {   continue;   }
		s = j + np;
		for (t=0; t<p[j]; t++) {
            /* Matlab index starts from 1 */
		    qi[total] = p[s];
            qj[total] = mask[j];
			total = total + 1;
			s = s + np;
		}
    }
    
	mxFree(mask);
	mxFree(p);
	
}  
