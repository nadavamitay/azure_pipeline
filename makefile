GD = gcc -ansi -pedantic-errors -Wall -Wextra -g
GC = gcc -ansi -pedantic-errors -Wall -Wextra -DNDEBUG -O3

CTESTS := $(wildcard *test.c)

OUT_TESTS := $(patsubst %_test.c, %_test.out, $(CTESTS))
DB_OUT_TESTS:= $(addprefix debug_, $(OUT_TESTS))

NOT_TESTS := $(filter-out $(CTESTS), $(wildcard *.c))

OBJ := $(patsubst %.c, %.o, $(NOT_TESTS))

OBJDB := $(addprefix debug_, $(OBJ))	

run : run_debug run_release

#******************************************************************************

run_debug : $(DB_OUT_TESTS)
	$(foreach OUT, $(DB_OUT_TESTS), ./$(OUT) && ) echo 'finish'

run_release : $(OUT_TESTS)
	$(foreach OUT, $(OUT_TESTS), ./$(OUT) && ) echo 'finish'

#******************************************************************************
	
%_test.out : %_test.o libds_debug.so
	$(GD) $< -L. -lds_debug -o $@ 

#******************************************************************************

libds.so : $(OBJ)   
		$(GC) -shared $(OBJ) -o $@
		rm *.o 

libds_debug.so : $(OBJDB)
		$(GD) -shared $(OBJDB) -o $@ 
		rm *.o 

#******************************************************************************

%.o : %.c %.h
		$(GC) -fPIC -c $< -o $@ 

.SECONDEXPANSION:
debug_%.o : $$(subst debug_,,%.c) $$(subst debug_,,%.h)
		$(GD) -fPIC -c $< -o $@

#******************************************************************************

%_test.o : %_test.c  
		$(GC) -c $< 

.SECONDEXPANSION:
debug_%_test.o : $$(subst debug_,,%.c) $$(subst debug_,,%.h)  
		$(GD) -c $< 

.PHONY: all test release debug clean print run
clean:
		rm -f *.so *.out *.o

all : debug release

release : libds.so

debug : libds_debug.so

test : $(OUT_TESTS) 

print:
	@echo $(NOT_TESTS)
	@echo $(OUT_TESTS)
	@echo $(DB_OUT_TESTS)




