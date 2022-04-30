#ifndef PH1NIX_TYPES_H
#define PH1NIX_TYPES_H

#define EOF // End of file
#define NULL 0 // Empty pointer

#define bool _BOOL
#define true 1
#define false 0

#define _packed __attribute__((packed)) // for defining special structral body

typedef unsigned size_t;

typedef char int8;
typedef short int16;
typedef int int32;
typedef long long int64;

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;

#endif