/*  Single translation unit that triggers STB's `_IMPLEMENTATION`
 *  macros to instantiate the bodies of every header we ship Ada
 *  bindings for. STB is header-only — without these defines, the
 *  headers are pure interface declarations. With them, the C
 *  source for the implementation is generated here, in this .c
 *  file, exactly once.
 *
 *  As new headers get bound on the Ada side, add an
 *  IMPLEMENTATION block here.
 */

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

/*  Future headers (uncomment as Ada bindings are added):
 *
 *  #define STB_IMAGE_WRITE_IMPLEMENTATION
 *  #include "stb_image_write.h"
 *
 *  #define STB_TRUETYPE_IMPLEMENTATION
 *  #include "stb_truetype.h"
 *
 *  #define STB_RECT_PACK_IMPLEMENTATION
 *  #include "stb_rect_pack.h"
 */
