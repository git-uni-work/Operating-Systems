CXX = g++
CXXFLAGS = -O1 -Wall -lm -g -lrt
FILE = main.cpp
OUT = ./a.out
IMG1 = vit_small.ppm
IMG2 = vit_normal.ppm
CACHE_FILE = cache
LOG_FILE = log.txt
TEST_FILE = test/test.ppm
TEST_RESULT = test/output.ppm
TMP_IMG = output.ppm

compile : $(OUT)
run : $(OUT)
			$(OUT) $(IMG1)
			@ printf "RES = "
			@ md5sum $(TMP_IMG)
			@ printf "OUT = "
			@ cat output.txt
			@ printf "\nOG = 24432 16307 15192 54597 9472\n"
			@ printf "MD5 = 32554ccd9b09af5b660a17b05350959b\n"
check : $(OUT)
				$(OUT) $(TEST_FILE)
				@ printf "RES = "
				@md5sum $(TMP_IMG)
				@ printf "OUT = "
				@ cat output.txt
				@ printf "\nOG = "
				@ cat test/output.txt
				@ printf "\nMD5 = "
				@ md5sum test/output.ppm
				@ printf "\n"
				cmp $(TMP_IMG) $(TEST_RESULT)
test : $(OUT)
			 valgrind --tool=cachegrind --cachegrind-out-file=$(CACHE_FILE) --log-file=$(LOG_FILE) --I1=32768,8,64 --D1=32768,8,64 --LL=1048576,16,64 $(OUT) $(IMG2)
			 cat $(LOG_FILE)
			 dos2unix script && ./script
view :
			 cg_annotate $(CACHE_FILE)
			 rm $(CACHE_FILE)
			 rm $(LOG_FILE)
clean:
			@ rm $(OUT)
			@ rm output.txt
			@ rm $(TMP_IMG)


$(OUT) : $(FILE)
				 $(CXX) $(CXXFLAGS) $(FILE)
