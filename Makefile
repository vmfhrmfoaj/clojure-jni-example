JAR_FILE=target/out-standalone.jar

.PHONY: run
run: lib jar
	java -jar $(JAR_FILE)


JNI_DIR=target/jni
CLASS_DIR=target/classes
CLASS_NAME=Test
CLASS_FILE=$(CLASS_DIR)/$(CLASS_NAME).class
C_HEADER=$(JNI_DIR)/$(CLASS_NAME).h
JAVA_FILE=src-java/$(CLASS_NAME).java
JAVA_SRC_DIR=src-java

.PHONY: jar
jar: $(JAR_FILE)

$(JAR_FILE): $(CLASS_FILE) $(C_HEADER)
	lein uberjar

$(CLASS_FILE): $(JAVA_FILE)
	mkdir -p $(JNI_DIR)
	javac -h $(JNI_DIR) -d $(CLASS_DIR) -sourcepath $(JAVA_SRC_DIR) $^


.PHONY: header
header: $(C_HEADER)

$(C_HEADER): $(CLASS_FILE)
	touch $(C_HEADER)


C_FILE=src-c/Test.c
JAVA_HOME:=$(shell dirname $$(dirname $$(readlink -f $$(which javac))))
INCLUDE_DIRS:=$(shell find $(JAVA_HOME)/include -type d)
INCLUDE_ARGS=$(INCLUDE_DIRS:%=-I%) -I$(JNI_DIR)
LIB_DIR=resources/lib
AMD64_LIB_FILE=$(LIB_DIR)/libtest.amd64_linux
AARCH64_LIB_FILE=$(LIB_DIR)/libtest.aarch64_linux
AARCH64_CC=aarch64-linux-gnu-gcc

.PHONY: lib
lib: $(AMD64_LIB_FILE) $(AARCH64_LIB_FILE)

$(AMD64_LIB_FILE): $(C_FILE) $(C_HEADER)
	mkdir -p $(LIB_DIR)
	$(CC) $(INCLUDE_ARGS) -shared -fPIC -o $@ $^

$(AARCH64_LIB_FILE): $(C_FILE) $(C_HEADER)
	mkdir -p $(LIB_DIR)
	$(AARCH64_CC) $(INCLUDE_ARGS) -shared -fPIC -o $@ $^

.PHONY: clean
clean:
	lein clean
