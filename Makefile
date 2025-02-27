LEIN ?= lein

JAVA_HOME  := $(shell dirname $$(dirname $$(readlink -f $$(which javac))))
GROUP_NAME := $(shell cat project.clj | tr -d '\n' | gawk 'match($$0,/defproject\s+([^ \/]+)\/([^ ]+)\s+"([^"]+)"/,m)  { print m[1] }')
PROJ_NAME  := $(shell cat project.clj | tr -d '\n' | gawk 'match($$0,/defproject\s+([^ \/]+\/)?([^ ]+)\s+"([^"]+)"/,m) { print m[2] }')
PROJ_VER   := $(shell cat project.clj | tr -d '\n' | gawk 'match($$0,/defproject\s+([^ \/]+\/)?([^ ]+)\s+"([^"]+)"/,m) { print m[3] }')

C_SRC_DIR    ?= src-c
JAVA_SRC_DIR ?= src-java
JNI_DIR      ?= target/jni
CLASS_DIR    ?= target/jni/classes

CLJ_FILES      := $(shell find . -name '*.clj' -or -name '*.clj[cs]' 2>/dev/null)
C_FILES        := $(shell find $(C_SRC_DIR)    -name '*.c'    2>/dev/null)
JAVA_FILES     := $(shell find $(JAVA_SRC_DIR) -name '*.java' 2>/dev/null)
RESOURCE_FILES := $(shell find resources -name '*' 2>/dev/null)
JNI_CLASS_FILES := $(foreach x,$(JAVA_FILES:.java=.class),$(subst $(JAVA_SRC_DIR)/,$(CLASS_DIR)/,$x))

JAR_FILE     := target/$(PROJ_NAME)-$(PROJ_VER).jar
UBERJAR_FILE := target/$(PROJ_NAME)-$(PROJ_VER)-standalone.jar
INSTALLED_JAR_FILE := $(HOME)/.m2/repository/$(GROUP_NAME)/$(PROJ_NAME)/$(PROJ_VER)/$(PROJ_NAME)-$(PROJ_VER).jar

INCLUDE_DIRS := $(shell find $(JAVA_HOME)/include -type d)
INCLUDE_ARGS := $(INCLUDE_DIRS:%=-I%) -I$(JNI_DIR)
LIB_NAME := test
LIB_DIR  := resources/lib
AARCH64_CC := aarch64-linux-gnu-gcc
AMD64_LINUX_LIB_FILE   := $(LIB_DIR)/lib$(LIB_NAME).amd64_linux
AARCH64_LINUX_LIB_FILE := $(LIB_DIR)/lib$(LIB_NAME).aarch64_linux
LIB_FILES := $(AMD64_LINUX_LIB_FILE) $(AARCH64_LINUX_LIB_FILE)

.PHONY: run
run: $(UBERJAR_FILE)
	java -jar $(UBERJAR_FILE)

.PHONY: build
build: $(JAR_FILE)

.PHONY: test
test: .test

.PHONY: auto-test
auto-test:
	$(LEIN) trampoline test-plus ':auto'
	@touch .test

.PHONY: isntall
install: $(INSTALLED_JAR_FILE)

.PHONY: jar
jar: $(JAR_FILE)

.PHONY: uberjar
uberjar: $(UBERJAR_FILE)

.PHONY: deploy
deploy: clean $(UBERJAR_FILE)
	$(LEIN) deploy

.PHONY: clean
clean:
	$(LEIN) clean


pom.xml: project.clj
	$(LEIN) pom

.test: $(CLJ_FILES)
	$(LEIN) trampoline test-plus ':once'
	@touch .test

$(JAR_FILE): project.clj $(CLJ_FILES) $(JAVA_FILES) $(C_FILES) $(RESOURCE_FILES)
# `lein install` will generate a jar file, so don't need generate it here.
ifneq (install,$(MAKECMDGOALS))
	$(LEIN) jar
endif
	@touch $@

$(UBERJAR_FILE): project.clj $(CLJ_FILES) $(JAVA_FILES) $(C_FILES) $(RESOURCE_FILES)
	$(LEIN) uberjar
	@touch $@

$(INSTALLED_JAR_FILE): $(JAR_FILE)
	$(LEIN) install
	@touch $@


define CLASS_FILE_template
$(2): $(1)
	@mkdir -p $$(JNI_DIR)
	@mkdir -p $$(CLASS_DIR)
	javac -h $$(JNI_DIR) -d $$(CLASS_DIR) -sourcepath $$(JAVA_SRC_DIR) $$^
endef

.PHONY: classes
classes: $(JNI_CLASS_FILES)

$(foreach x,$(JAVA_FILES),\
	$(eval $(call CLASS_FILE_template,\
		$x,\
		$(patsubst %.java,%.class,$(subst $(JAVA_SRC_DIR)/,$(CLASS_DIR)/,$x)))))

.PHONY: lib
lib: $(LIB_FILES)

$(AMD64_LINUX_LIB_FILE): $(C_FILES) $(JNI_CLASS_FILES)
	@mkdir -p $(LIB_DIR)
	$(CC) $(INCLUDE_ARGS) -shared -nostdlib -fPIC -o $@ $(filter %.c %.h,$^)

$(AARCH64_LINUX_LIB_FILE): $(C_FILES) $(JNI_CLASS_FILES)
	@mkdir -p $(LIB_DIR)
	$(AARCH64_CC) $(INCLUDE_ARGS) -shared -nostdlib -fPIC -o $@ $(filter %.c %.h,$^)
