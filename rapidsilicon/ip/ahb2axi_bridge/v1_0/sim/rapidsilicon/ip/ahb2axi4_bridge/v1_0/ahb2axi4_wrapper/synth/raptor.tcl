create_design ahb2axi4_wrapper
target_device GEMINI
add_include_path ../src
add_library_path ../src
add_library_ext .v .sv
add_design_file ../src/ahb2axi4_wrapper.v
set_top_module ahb2axi4_wrapper
synthesize