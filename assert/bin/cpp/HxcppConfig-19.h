#ifndef HXCPP_CONFIG_INCLUDED
#define HXCPP_CONFIG_INCLUDED

#if !defined(HX_WINDOWS) && !defined(NO_HX_WINDOWS)
#define HX_WINDOWS 
#endif

#if !defined(HXCPP_VISIT_ALLOCS) && !defined(NO_HXCPP_VISIT_ALLOCS)
#define HXCPP_VISIT_ALLOCS 
#endif

#if !defined(HX_SMART_STRINGS) && !defined(NO_HX_SMART_STRINGS)
#define HX_SMART_STRINGS 
#endif

#if !defined(HXCPP_API_LEVEL) && !defined(NO_HXCPP_API_LEVEL)
#define HXCPP_API_LEVEL 430
#endif

#if !defined(_CRT_SECURE_NO_DEPRECATE) && !defined(NO__CRT_SECURE_NO_DEPRECATE)
#define _CRT_SECURE_NO_DEPRECATE 
#endif

#if !defined(_ALLOW_MSC_VER_MISMATCH) && !defined(NO__ALLOW_MSC_VER_MISMATCH)
#define _ALLOW_MSC_VER_MISMATCH 
#endif

#if !defined(_ALLOW_ITERATOR_DEBUG_LEVEL_MISMATCH) && !defined(NO__ALLOW_ITERATOR_DEBUG_LEVEL_MISMATCH)
#define _ALLOW_ITERATOR_DEBUG_LEVEL_MISMATCH 
#endif

#include <hxcpp.h>

#endif
