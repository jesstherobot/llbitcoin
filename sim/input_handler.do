#---------------------------------------------------------------------
# Project name         : input_handler
# Project description  : Input handler core for llbitcoin project
#
# File name            : input_handler.do
#
# Design Engineer      : cospan/jessb
# Quality Engineer     : cospan/jessb
# Version              : 1.0
# Last modification    : 2011-04-19
#---------------------------------------------------------------------

transcript off
# ------------------------------------------------------------------- #
# Directories location
# ------------------------------------------------------------------- #

set source_dir rtl
set tb_dir     bench
set work_dir   sim/modelsim_lib

# ------------------------------------------------------------------- #
# Mapping destination directory for core of model
# ------------------------------------------------------------------- #

vlib $work_dir
vmap SHA_LIB $work_dir
transcript on


# ------------------------------------------------------------------- #
# Compiling components of core
# ------------------------------------------------------------------- #

transcript off
vlog -work SHA_LIB +incdir+$source_dir $source_dir/input_handler.v


# ------------------------------------------------------------------- #
# Compiling Test Bench
# ------------------------------------------------------------------- #

vlog  -work SHA_LIB $tb_dir/input_handler_tb.v

transcript on


# ------------------------------------------------------------------- #
# Loading the Test Bench
# ------------------------------------------------------------------- #

transcript off
vsim +nowarnTFMPC +nowarnTSCALE -t ns -lib SHA_LIB input_handler_tb

transcript on


transcript on

do wave.do

run 1ms
