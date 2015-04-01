//
//  linearAlgebra.h
//  OPjective
//
//  Created by Kirk Roerig on 8/22/14.
//  Copyright (c) 2014 OPifex. All rights reserved.
//

#ifndef OPjective_linearAlgebra_h
#define OPjective_linearAlgebra_h

#include <math.h>
#include <GLKit/GLKit.h>
#include <Accelerate/Accelerate.h>

static inline int bet(GLfloat a, GLfloat m, GLfloat b){
	return fabs(a - m) + fabs(m - b) == fabs(a - b);
}

typedef GLfloat vec2[2];
typedef struct{
	vec2 p;
	vec2 n;
} ray2;
static inline void vec2_add(vec2 r, vec2 a, vec2 b){
	int i;
	for(i=2;i--;){
		r[i] = a[i] + b[i];
	}
}
static inline void vec2_sub(vec2 r, vec2 a, vec2 b){
	int i;
	for(i=2;i--;){
		r[i] = a[i] - b[i];
	}
}

/*
 y = m1x + b1	y = m2x + b2
 
 m1x + b1 = m2x + b2
 m1x = m2x + b2 - b1
 x(m1 - m2) = b2 - b1
 x = (b2 - b1) / (m1 - m2)
 */
static inline int vec2_ray_line(vec2 itrsec, ray2 ray, vec2 v1, vec2 v2){
	GLfloat m_ray  = ray.n[1] / ray.n[0];
	GLfloat m_line_rise = v2[1] - v1[1], m_line_run = v2[0] - v1[0];
	GLfloat m_line = (m_line_rise) / (m_line_run == 0 ? 0.1f : m_line_run);
	GLfloat yint_ray = (-ray.p[0] * m_ray) + ray.p[1], yint_line = (-v1[0] * m_line) + v1[1];
	GLfloat x = (yint_line - yint_ray) / (m_ray - m_line);
	GLfloat sx, sy;
    
	itrsec[0] = x;
	itrsec[1] = x * m_ray + yint_ray;
    
	sx = (itrsec[0] - ray.p[0]) / ray.n[0];
	sy = (itrsec[1] - ray.p[1]) / ray.n[1];
    
	return (bet(v1[0], itrsec[0], v2[0]) || bet(v1[1], itrsec[1], v2[1])) && (sx >= 0 || sy >= 0);
}

typedef GLfloat vec3[3];
static const vec3 VEC3_ZERO = {0};
static const vec3 VEC3_ONE = {1,1,1};
static const vec3 VEC3_FORWARD = { 0, 0, 1 };
static const vec3 VEC3_UP      = { 0, 1, 0 };
static const vec3 VEC3_LEFT    = { 1, 0, 0 };

static inline void vec3_set(vec3 r, vec3 v)
{
    r[0] = v[0];
    r[1] = v[1];
    r[2] = v[2];
}

static inline void vec3_add(vec3 r, vec3 a, vec3 b)
{
//    vDSP_vadd((float*)a, 1, (float*)b, 1, (float*)r, 1, 3);
    r[0] = a[0] + b[0];
    r[1] = a[1] + b[1];
    r[2] = a[2] + b[2];
}
static inline void vec3_sub(vec3 r, vec3 a, vec3 b)
{
//    vDSP_vsub((float*)a, 1, (float*)b, 1, (float*)r, 1, 3);
    r[0] = a[0] - b[0];
    r[1] = a[1] - b[1];
    r[2] = a[2] - b[2];
}
static inline void vec3_scale(vec3 r, vec3 v, GLfloat s)
{
    //vDSP_vsmul(v, 1, &s, r, 1, 3);
    r[0] = v[0] * s;
    r[1] = v[1] * s;
    r[2] = v[2] * s;
}
static inline void vec3_mul(vec3 r, vec3 a, vec3 b)
{
//    vDSP_vmul(a, 1, b, 1, r, 1, 3);
    r[0] = a[0] * b[0];
    r[1] = a[1] * b[1];
    r[2] = a[2] * b[2];
}
static inline GLfloat vec3_mul_inner(vec3 a, vec3 b)
{
//    float p = 0;
//    vDSP_dotpr(a, 1, b, 1, &p, 3);
//	return p;
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
}
static inline void vec3_mul_cross(vec3 r, vec3 a, vec3 b)
{
	r[0] = a[1]*b[2] - a[2]*b[1];
	r[1] = a[2]*b[0] - a[0]*b[2];
	r[2] = a[0]*b[1] - a[1]*b[0];
}

static inline GLfloat vec3_dot(vec3 v1, vec3 v2){
    float dot = 0;
    vDSP_dotpr(v1, 1, v2, 1, &dot, 3);
    return dot;
}

static inline GLfloat vec3_len(vec3 v)
{
    float len = 0;
//    vDSP_vdist(v, 1, (float*)VEC3_ZERO, 1, &len, 1, 3);
    len = sqrtf(vec3_dot(v, v));
    return len;
}
static inline GLfloat vec3_dist(vec3 v1, vec3 v2){
    float dist = 0;
    vDSP_vdist(v1, 1, v2, 1, &dist, 1, 3);
    return dist;
}
static inline void vec3_norm(vec3 r, vec3 v)
{
	GLfloat k = 1.f / vec3_len(v);
	vec3_scale(r, v, k);
}
static inline void vec3_reflect(vec3 r, vec3 v, vec3 n)
{
	GLfloat p  = 2.f*vec3_mul_inner(v, n);
	int i;
	for(i=0;i<3;++i)
		r[i] = v[i] - p*n[i];
}

typedef struct {
    vec3 p;
    vec3 n;
} ray3;

static inline void vec3_proj_point_vec3(vec3 p, vec3 v, vec3 s)
{
    GLfloat n = vec3_dot(v, s);
    GLfloat d = vec3_dot(s, s);
    
    vec3_scale(p, s, n / d);
}

static inline GLfloat vec3_angle_between_vec3(vec3 v1, vec3 v2)
{
    GLfloat n = vec3_dot(v1, v2);
    GLfloat d = vec3_len(v1) * vec3_len(v2);
    return acosf(n / d);
}

static inline int vec3_ray_sphere(vec3 itrsec, ray3 ray, vec3 spherePos, GLfloat r, GLfloat* t)
{
    //
    vec3 o = {0};
    vec3_sub(o, ray.p, spherePos);
    GLfloat A = vec3_dot(ray.n, ray.n);
    GLfloat B = 2 * vec3_dot(ray.n, o);
    GLfloat C = vec3_dot(o, o) - r * r;
    
    GLfloat disc = B * B - 4 * A * C;
    
    if(disc < 0) return 0;
    
    GLfloat distSqrt = sqrtf(disc);
    GLfloat q;
    
    if(B < 0)
        q = (-B - distSqrt) / 2;
    else
        q = (-B + distSqrt) / 2;
    
    GLfloat t0 = q / A;
    GLfloat t1 = C / q;
    
    if(t0 > t1){
        GLfloat temp = t0;
        t0 = t1;
        t1 = temp;
    }
    
    if(t1 < 0)
        return 0;
    
    if(t0 < 0){
        vec3_scale(itrsec, ray.n, t1);
        *t = t1;
    }
    else{
        vec3_scale(itrsec, ray.n, t0);
        *t = t0;
    }

    vec3_add(itrsec, itrsec, ray.p);
    
    return 1;
}

typedef GLfloat vec4[4];
static const vec4 VEC4_ZERO = { 0, 0, 0, 0 };
static const vec4 VEC4_ONE = { 1, 1, 1, 1 };
static const vec4 VEC4_FORWARD = { 0, 0, 1, 1 };
static const vec4 VEC4_UP      = { 0, 1, 0, 1 };
static const vec4 VEC4_LEFT    = { 1, 0, 0, 1 };

static inline void vec4_set(vec4 r, vec4 v)
{
    r[0] = v[0];
    r[1] = v[1];
    r[2] = v[2];
    r[3] = v[3];
}

static inline void vec4_add(vec4 r, vec4 a, vec4 b)
{
	int i;
	for(i=0; i<4; ++i)
		r[i] = a[i] + b[i];
}
static inline void vec4_sub(vec4 r, vec4 a, vec4 b)
{
	int i;
	for(i=0; i<4; ++i)
		r[i] = a[i] - b[i];
}
static inline void vec4_scale(vec4 r, vec4 v, GLfloat s)
{
	int i;
	for(i=0; i<4; ++i)
		r[i] = v[i] * s;
}
static inline GLfloat vec4_mul_inner(vec4 a, vec4 b)
{
	GLfloat p = 0.f;
	int i;
	for(i=0; i<4; ++i)
		p += b[i]*a[i];
	return p;
}
static inline void vec4_mul_cross(vec4 r, vec4 a, vec4 b)
{
	r[0] = a[1]*b[2] - a[2]*b[1];
	r[1] = a[2]*b[0] - a[0]*b[2];
	r[2] = a[0]*b[1] - a[1]*b[0];
	r[3] = 1.f;
}
static inline GLfloat vec4_len(vec4 v)
{
	return sqrtf(vec4_mul_inner(v, v));
}
static inline void vec4_norm(vec4 r, vec4 v)
{
	GLfloat k = 1.f / vec4_len(v);
	vec4_scale(r, v, k);
}
static inline void vec4_reflect(vec4 r, vec4 v, vec4 n)
{
	GLfloat p  = 2.f*vec4_mul_inner(v, n);
	int i;
	for(i=0;i<4;++i)
		r[i] = v[i] - p*n[i];
}

static inline void vec4_lerp(vec4 r, vec4 a, vec4 b, float p)
{
    vec4 temp;
    vec4_scale(temp, b, p);
    vec4_scale(r, a, 1.0f - p);
    vec4_add(r, r, temp);
}

typedef vec4 mat4x4[4];
static inline void mat4x4_identity(mat4x4 M)
{
	int i, j;
	for(i=0; i<4; ++i)
		for(j=0; j<4; ++j)
			M[i][j] = i==j ? 1.f : 0.f;
}
static inline void mat4x4_dup(mat4x4 M, mat4x4 N)
{
	int i, j;
	for(i=0; i<4; ++i)
		for(j=0; j<4; ++j)
			M[i][j] = N[i][j];
}
static inline void mat4x4_row(vec4 r, mat4x4 M, int i)
{
	int k;
	for(k=0; k<4; ++k)
		r[k] = M[k][i];
}
static inline void mat4x4_col(vec4 r, mat4x4 M, int i)
{
	int k;
	for(k=0; k<4; ++k)
		r[k] = M[i][k];
}
static inline void mat4x4_transpose(mat4x4 M, mat4x4 N)
{
	int i, j;
	for(j=0; j<4; ++j)
		for(i=0; i<4; ++i)
			M[i][j] = N[j][i];
}
static inline void mat4x4_add(mat4x4 M, mat4x4 a, mat4x4 b)
{
	int i;
	for(i=0; i<4; ++i)
		vec4_add(M[i], a[i], b[i]);
}
static inline void mat4x4_sub(mat4x4 M, mat4x4 a, mat4x4 b)
{
	int i;
	for(i=0; i<4; ++i)
		vec4_sub(M[i], a[i], b[i]);
}
static inline void mat4x4_scale(mat4x4 M, mat4x4 a, GLfloat k)
{
	int i;
	for(i=0; i<4; ++i)
		vec4_scale(M[i], a[i], k);
}
static inline void mat4x4_scale_aniso(mat4x4 M, mat4x4 a, GLfloat x, GLfloat y, GLfloat z)
{
	vec4_scale(M[0], a[0], x);
	vec4_scale(M[1], a[1], y);
	vec4_scale(M[2], a[2], z);
}
static inline void mat4x4_mul(mat4x4 M, mat4x4 a, mat4x4 b)
{
	int k, r, c;
	for(c=0; c<4; ++c) for(r=0; r<4; ++r) {
		M[c][r] = 0.f;
		for(k=0; k<4; ++k)
			M[c][r] += a[k][r] * b[c][k];
	}
}
static inline void mat4x4_mul_vec4(vec4 r, mat4x4 M, vec4 v)
{
	int i, j;
	for(j=0; j<4; ++j) {
		r[j] = 0.f;
		for(i=0; i<4; ++i)
			r[j] += M[i][j] * v[i];
	}
}
static inline void mat4x4_translate(mat4x4 T, GLfloat x, GLfloat y, GLfloat z)
{
	mat4x4_identity(T);
	T[3][0] = x;
	T[3][1] = y;
	T[3][2] = z;
}
static inline void mat4x4_translate_in_place(mat4x4 M, GLfloat x, GLfloat y, GLfloat z)
{
	vec4 t = {x, y, z, 0};
	vec4 r;
	int i;
	for (i = 0; i < 4; ++i) {
		mat4x4_row(r, M, i);
		M[3][i] += vec4_mul_inner(r, t);
	}
}
static inline void mat4x4_from_vec3_mul_outer(mat4x4 M, vec3 a, vec3 b)
{
	int i, j;
	for(i=0; i<4; ++i) for(j=0; j<4; ++j)
		M[i][j] = i<3 && j<3 ? a[i] * b[j] : 0.f;
}
static inline void mat4x4_rotate(mat4x4 R, mat4x4 M, GLfloat x, GLfloat y, GLfloat z, GLfloat angle)
{
	GLfloat s = sinf(angle);
	GLfloat c = cosf(angle);
	vec3 u = {x, y, z};
	vec3_norm(u, u);
    
	{
		mat4x4 T;
		mat4x4_from_vec3_mul_outer(T, u, u);
        
		mat4x4 S = {
			{  0.f,  u[2], -u[1], 0.f},
			{-u[2],   0.f,  u[0], 0.f},
			{ u[1], -u[0],   0.f, 0.f},
			{  0.f,   0.f,   0.f, 0.f}
		};
		mat4x4_scale(S, S, s);
        
		mat4x4 C;
		mat4x4_identity(C);
		mat4x4_sub(C, C, T);
        
		mat4x4_scale(C, C, c);
        
		mat4x4_add(T, T, C);
		mat4x4_add(T, T, S);
        
		T[3][3] = 1.f;
		mat4x4_mul(R, M, T);
	}
}
static inline void mat4x4_rotate_X(mat4x4 Q, mat4x4 M, GLfloat angle)
{
	GLfloat s = sinf(angle);
	GLfloat c = cosf(angle);
	mat4x4 R = {
		{1.f, 0.f, 0.f, 0.f},
		{0.f,   c,   s, 0.f},
		{0.f,  -s,   c, 0.f},
		{0.f, 0.f, 0.f, 1.f}
	};
	mat4x4_mul(Q, M, R);
}
static inline void mat4x4_rotate_Y(mat4x4 Q, mat4x4 M, GLfloat angle)
{
	GLfloat s = sinf(angle);
	GLfloat c = cosf(angle);
	mat4x4 R = {
		{   c, 0.f,   s, 0.f},
		{ 0.f, 1.f, 0.f, 0.f},
		{  -s, 0.f,   c, 0.f},
		{ 0.f, 0.f, 0.f, 1.f}
	};
	mat4x4_mul(Q, M, R);
}
static inline void mat4x4_rotate_Z(mat4x4 Q, mat4x4 M, GLfloat angle)
{
	GLfloat s = sinf(angle);
	GLfloat c = cosf(angle);
	mat4x4 R = {
		{   c,   s, 0.f, 0.f},
		{  -s,   c, 0.f, 0.f},
		{ 0.f, 0.f, 1.f, 0.f},
		{ 0.f, 0.f, 0.f, 1.f}
	};
	mat4x4_mul(Q, M, R);
}
static inline void mat4x4_invert(mat4x4 T, mat4x4 M)
{
	GLfloat s[6];
	GLfloat c[6];
	s[0] = M[0][0]*M[1][1] - M[1][0]*M[0][1];
	s[1] = M[0][0]*M[1][2] - M[1][0]*M[0][2];
	s[2] = M[0][0]*M[1][3] - M[1][0]*M[0][3];
	s[3] = M[0][1]*M[1][2] - M[1][1]*M[0][2];
	s[4] = M[0][1]*M[1][3] - M[1][1]*M[0][3];
	s[5] = M[0][2]*M[1][3] - M[1][2]*M[0][3];
    
	c[0] = M[2][0]*M[3][1] - M[3][0]*M[2][1];
	c[1] = M[2][0]*M[3][2] - M[3][0]*M[2][2];
	c[2] = M[2][0]*M[3][3] - M[3][0]*M[2][3];
	c[3] = M[2][1]*M[3][2] - M[3][1]*M[2][2];
	c[4] = M[2][1]*M[3][3] - M[3][1]*M[2][3];
	c[5] = M[2][2]*M[3][3] - M[3][2]*M[2][3];
	
	/* Assumes it is invertible */
	GLfloat idet = 1.0f/( s[0]*c[5]-s[1]*c[4]+s[2]*c[3]+s[3]*c[2]-s[4]*c[1]+s[5]*c[0] );
	
	T[0][0] = ( M[1][1] * c[5] - M[1][2] * c[4] + M[1][3] * c[3]) * idet;
	T[0][1] = (-M[0][1] * c[5] + M[0][2] * c[4] - M[0][3] * c[3]) * idet;
	T[0][2] = ( M[3][1] * s[5] - M[3][2] * s[4] + M[3][3] * s[3]) * idet;
	T[0][3] = (-M[2][1] * s[5] + M[2][2] * s[4] - M[2][3] * s[3]) * idet;
    
	T[1][0] = (-M[1][0] * c[5] + M[1][2] * c[2] - M[1][3] * c[1]) * idet;
	T[1][1] = ( M[0][0] * c[5] - M[0][2] * c[2] + M[0][3] * c[1]) * idet;
	T[1][2] = (-M[3][0] * s[5] + M[3][2] * s[2] - M[3][3] * s[1]) * idet;
	T[1][3] = ( M[2][0] * s[5] - M[2][2] * s[2] + M[2][3] * s[1]) * idet;
    
	T[2][0] = ( M[1][0] * c[4] - M[1][1] * c[2] + M[1][3] * c[0]) * idet;
	T[2][1] = (-M[0][0] * c[4] + M[0][1] * c[2] - M[0][3] * c[0]) * idet;
	T[2][2] = ( M[3][0] * s[4] - M[3][1] * s[2] + M[3][3] * s[0]) * idet;
	T[2][3] = (-M[2][0] * s[4] + M[2][1] * s[2] - M[2][3] * s[0]) * idet;
    
	T[3][0] = (-M[1][0] * c[3] + M[1][1] * c[1] - M[1][2] * c[0]) * idet;
	T[3][1] = ( M[0][0] * c[3] - M[0][1] * c[1] + M[0][2] * c[0]) * idet;
	T[3][2] = (-M[3][0] * s[3] + M[3][1] * s[1] - M[3][2] * s[0]) * idet;
	T[3][3] = ( M[2][0] * s[3] - M[2][1] * s[1] + M[2][2] * s[0]) * idet;
}
static inline void mat4x4_frustum(mat4x4 M, GLfloat l, GLfloat r, GLfloat b, GLfloat t, GLfloat n, GLfloat f)
{
	M[0][0] = 2.f*n/(r-l);
	M[0][1] = M[0][2] = M[0][3] = 0.f;
	
	M[1][1] = 2.*n/(t-b);
	M[1][0] = M[1][2] = M[1][3] = 0.f;
    
	M[2][0] = (r+l)/(r-l);
	M[2][1] = (t+b)/(t-b);
	M[2][2] = -(f+n)/(f-n);
	M[2][3] = -1.f;
	
	M[3][2] = -2.f*(f*n)/(f-n);
	M[3][0] = M[3][1] = M[3][3] = 0.f;
}
static inline void mat4x4_ortho(mat4x4 M, GLfloat l, GLfloat r, GLfloat b, GLfloat t, GLfloat n, GLfloat f)
{
	M[0][0] = 2.f/(r-l);
	M[0][1] = M[0][2] = M[0][3] = 0.f;
    
	M[1][1] = 2.f/(t-b);
	M[1][0] = M[1][2] = M[1][3] = 0.f;
    
	M[2][2] = -2.f/(f-n);
	M[2][0] = M[2][1] = M[2][3] = 0.f;
	
	M[3][0] = -(r+l)/(r-l);
	M[3][1] = -(t+b)/(t-b);
	M[3][2] = -(f+n)/(f-n);
	M[3][3] = 1.f;
}
static inline void mat4x4_perspective(mat4x4 m, GLfloat y_fov, GLfloat aspect, GLfloat n, GLfloat f)
{
	/* NOTE: Degrees are an unhandy unit to work with.
	 * linmath.h uses radians for everything! */
	GLfloat const a = 1.f / tan(y_fov / 2.f);
    
	m[0][0] = a / aspect;
	m[0][1] = 0.f;
	m[0][2] = 0.f;
	m[0][3] = 0.f;
    
	m[1][0] = 0.f;
	m[1][1] = a;
	m[1][2] = 0.f;
	m[1][3] = 0.f;
    
	m[2][0] = 0.f;
	m[2][1] = 0.f;
	m[2][2] = -((f + n) / (f - n));
	m[2][3] = -1.f;
    
	m[3][0] = 0.f;
	m[3][1] = 0.f;
	m[3][2] = -((2.f * f * n) / (f - n));
	m[3][3] = 0.f;
}
static inline void mat4x4_look_at(mat4x4 m, vec3 eye, vec3 center, vec3 up)
{
	/* Adapted from Android's OpenGL Matrix.java.                        */
	/* See the OpenGL GLUT documentation for gluLookAt for a description */
	/* of the algorithm. We implement it in a straightforward way:       */
    
	/* TODO: The negation of of can be spared by swapping the order of
	 *       operands in the following cross products in the right way. */
	vec3 f;
	vec3_sub(f, center, eye);
	vec3_norm(f, f);
	
	vec3 s;
	vec3_mul_cross(s, f, up);
	vec3_norm(s, s);
    
	vec3 t;
	vec3_mul_cross(t, s, f);
    
	m[0][0] =  s[0];
	m[0][1] =  t[0];
	m[0][2] = -f[0];
	m[0][3] =   0.f;
    
	m[1][0] =  s[1];
	m[1][1] =  t[1];
	m[1][2] = -f[1];
	m[1][3] =   0.f;
    
	m[2][0] =  s[2];
	m[2][1] =  t[2];
	m[2][2] = -f[2];
	m[2][3] =   0.f;
    
	m[3][0] =  0.f;
	m[3][1] =  0.f;
	m[3][2] =  0.f;
	m[3][3] =  1.f;
    
	mat4x4_translate_in_place(m, -eye[0], -eye[1], -eye[2]);
}

typedef GLfloat quat[4];
static inline void quat_identity(quat q)
{
	q[0] = q[1] = q[2] = 0.f;
	q[3] = 1.f;
}
static inline void quat_add(quat r, quat a, quat b)
{
	int i;
	for(i=0; i<4; ++i)
		r[i] = a[i] + b[i];
}
static inline void quat_sub(quat r, quat a, quat b)
{
	int i;
	for(i=0; i<4; ++i)
		r[i] = a[i] - b[i];
}
static inline void quat_mul(quat r, quat p, quat q)
{
	vec3 w;
	vec3_mul_cross(r, p, q);
	vec3_scale(w, p, q[3]);
	vec3_add(r, r, w);
	vec3_scale(w, q, p[3]);
	vec3_add(r, r, w);
	r[3] = p[3]*q[3] - vec3_mul_inner(p, q);
}
static inline void quat_scale(quat r, quat v, GLfloat s)
{
	int i;
	for(i=0; i<4; ++i)
		r[i] = v[i] * s;
}
static inline GLfloat quat_inner_product(quat a, quat b)
{
	GLfloat p = 0.f;
	int i;
	for(i=0; i<4; ++i)
		p += b[i]*a[i];
	return p;
}
static inline void quat_conj(quat r, quat q)
{
	int i;
	for(i=0; i<3; ++i)
		r[i] = -q[i];
	r[3] = q[3];
}
#define quat_norm vec4_norm
static inline void quat_mul_vec3(vec3 r, quat q, vec3 v)
{
	quat v_ = {v[0], v[1], v[2], 0.f};
    
	quat_conj(r, q);
	quat_norm(r, r);
	quat_mul(r, v_, r);
	quat_mul(r, q, r);
}
static inline void mat4x4_from_quat(mat4x4 M, quat q)
{
	GLfloat a = q[3];
	GLfloat b = q[0];
	GLfloat c = q[1];
	GLfloat d = q[2];
	GLfloat a2 = a*a;
	GLfloat b2 = b*b;
	GLfloat c2 = c*c;
	GLfloat d2 = d*d;
	
	M[0][0] = a2 + b2 - c2 - d2;
	M[0][1] = 2.f*(b*c + a*d);
	M[0][2] = 2.f*(b*d - a*c);
	M[0][3] = 0.f;
    
	M[1][0] = 2*(b*c - a*d);
	M[1][1] = a2 - b2 + c2 - d2;
	M[1][2] = 2.f*(c*d + a*b);
	M[1][3] = 0.f;
    
	M[2][0] = 2.f*(b*d + a*c);
	M[2][1] = 2.f*(c*d - a*b);
	M[2][2] = a2 - b2 - c2 + d2;
	M[2][3] = 0.f;
    
	M[3][0] = M[3][1] = M[3][2] = 0.f;
	M[3][3] = 1.f;
}
static inline void mat4x4_mul_quat(mat4x4 R, mat4x4 M, quat q)
{
	quat_mul_vec3(R[0], M[0], q);
	quat_mul_vec3(R[1], M[1], q);
	quat_mul_vec3(R[2], M[2], q);
    
	R[3][0] = R[3][1] = R[3][2] = 0.f;
	R[3][3] = 1.f;
}
static inline void quat_from_mat4x4(quat q, mat4x4 M)
{
	GLfloat r=0.f;
	int i;
    
	int perm[] = { 0, 1, 2, 0, 1 };
	int *p = perm;
    
	for(i = 0; i<3; i++) {
		GLfloat m = M[i][i];
		if( m < r )
			continue;
//		m = r;
		p = &perm[i];
	}
    
	r = sqrtf(1.f + M[p[0]][p[0]] - M[p[1]][p[1]] - M[p[2]][p[2]] );
    
	if(r < 1e-6) {
		q[0] = 1.f;
		q[1] = q[2] = q[3] = 0.f;
		return;
	}
    
	q[0] = r/2.f;
	q[1] = (M[p[0]][p[1]] - M[p[1]][p[0]])/(2.f*r);
	q[2] = (M[p[2]][p[0]] - M[p[0]][p[2]])/(2.f*r);
	q[3] = (M[p[2]][p[1]] - M[p[1]][p[2]])/(2.f*r);
}

#endif