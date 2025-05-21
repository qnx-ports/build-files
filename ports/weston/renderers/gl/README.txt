fragment-shader.h and vertex-shader.h are simply hex dump representations of 
vertex.glsl and fragment.glsl need by the renderer-gl module. The Meson build
system generates these on the fly.

To re-generate these files here (picked up by QNX build system):

python $(DIST_ROOT)/tools/xxd.py -n vertex_shader $(DIST_ROOT)/libweston/renderer-gl/vertex.glsl vertex-shader.h
python $(DIST_ROOT)/tools/xxd.py -n fragment_shader $(DIST_ROOT)/libweston/renderer-gl/fragment.glsl fragment-shader.h
