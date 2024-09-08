#!/bin/bash


# Compilation notes:
# The compilation commands are really long as to ensure a really strict compilation where the most kinds of
# warnings are treated as errors as to ensure a clean way of programming.
# Also the compilation commands are flagged with the heaviest set of optimizations to ensure maximum performance.

# Special variable:
# $? - represents the errorlevel from the previous command with any non-zero value being an error

# Echo formatting:
# echo -e - the -e option means that escaped (backslashed) strings will be interpreted
# \033[ - escaped sequence represents beginning/ending of the style
# lowercase m - indicates the end of the sequence
# [0m - resets all attributes, colors, formatting, etc.



# Compile source code to object code, thus passing trough expanded (preprocessed) and assembly code
gcc ../src/dir.c -c -o dir.o -std=c17 -Ofast -Werror -Wall -Wextra -Winit-self -Wuninitialized -Wmissing-declarations -Winit-self -Wfloat-equal -Wundef -Wshadow -Wpointer-arith -Wpointer-arith -Wstrict-prototypes -Wstrict-overflow -Wwrite-strings -Waggregate-return -Wcast-qual -Wswitch-default -Wswitch-enum -Wconversion -Wunreachable-code -pedantic

echo -e "\n\033[1m\033[0;35m [#] Starting compilation process!\n"

if [ $? -eq 0 ]; then
    echo -e "\033[1m\033[0;32m [#] Compiled object code Succesfully!\n"
else
    echo -e "\033[1m\033[0;31m [#] Compiling object code Failed!\n"
    exit
fi

# Compile object code to shared library binary, thus passing trough the linking stage
gcc dir.o -shared -o dir.so -std=c17 -Ofast -Werror -Wall -Wextra -Winit-self -Wuninitialized -Wmissing-declarations -Winit-self -Wfloat-equal -Wundef -Wshadow -Wpointer-arith -Wpointer-arith -Wstrict-prototypes -Wstrict-overflow -Wwrite-strings -Waggregate-return -Wcast-qual -Wswitch-default -Wswitch-enum -Wconversion -Wunreachable-code -pedantic

if [ $? -eq 0 ]; then
    echo -e "\033[1m\033[0;32m [#] Compiled shared library Succesfully!\n"
else
    echo -e "\033[1m\033[0;31m [#] Compiling shared library Failed!\n"
    exit
fi

# Remove the useless object code
rm -fr dir.o

if [ $? -eq 0 ]; then
    echo -e "\033[1m\033[0;32m [#] Deleted object code Succesfully!\n"
else
    echo -e "\033[1m\033[0;31m [#] Deleting object code Failed!\n"
    exit
fi

# Copy the compiled library to the parent folder
cp -fr dir.so ../dir.so

if [ $? -eq 0 ]; then
    echo -e "\033[1m\033[0;32m [#] Copied shared library to parent folder Succesfully!\n"
else
    echo -e "\033[1m\033[0;31m [#] Copying shared library to parent folder Failed!\n"
    exit
fi

echo -e "\033[1m\033[0;36m [#] Compiled Succesfully!\n"
