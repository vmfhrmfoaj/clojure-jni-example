# clojure-jni-example

An example project demonstrating how to call a C shared library through JNI in Clojure.

I couldn't find a really complete example of this on the internet,
so I decided to put what I made as a proof of concept out for anyone to see.


## How to run it

I wrote up a Dockerfile, so it's as easy as

```bash
docker build -t <YOUR-DOCKER-IMAGE-NAME> .
docker run --rm --interactive --tty -v $PWD:/workspace <YOUR-DOCKER-IMAGE-NAME> make
```

you should see:

```
Hello from Clojure!
Loading C library from Java!
Hello from C, User!
```


## Explanation

JNI works in a few steps.

1. Compile a Java file with `native` methods to a `.class` file.
2. Generate a C header with `javac`.
3. Use that header in a `.c` file. This is the entrypoint into native code from your JVM code.
4. Compile your C code into a shared library.
5. Compile your JVM code into a JAR.

You use the methods definted in the wrapper Java class to call into native code.
When you run the JAR Java will try to find the shared lib, and if it does it'll call the code as needed.

For Clojure, there's just the additional step of Java interop.


## Gotchas

1. I couldn't get `System.loadLibrary` to work with my shared library. I am unsure if this is by design or not.
2. Make sure that `JAVA_HOME` is set, so that the C compiler can find the right header.
