(defproject clojure-jni-example
  "0.1.0-SNAPSHOT"

  :description "An example of calling JNI from Clojure."
  :license {:name "MIT"}

  :main clojure-jni-example.core

  :source-paths ["src"]
  :clean-targets ^{:protect false} [:target-path "resources/lib/"]

  :plugins [[lein-shell "RELEASE"]]

  :dependencies [[org.clojure/clojure "1.11.1"]]

  :prep-tasks [["shell" "make" "lib"]]

  :profiles
  {:uberjar {:aot :all
             :compile-path "target/uberjar/classes"
             ;; NOTE
             ;;  don't remove `compile` from `:prep-tasks`
             ;;  see, https://github.com/technomancy/leiningen/issues/2129#issuecomment-336748666
             :prep-tasks ^:replace [["shell" "env" "CLASS_DIR=target/uberjar/classes" "make" "lib"] "compile"]}
   :dev {:repl-options {:init-ns user}}
   :test {:compile-path "target/test/classes"}
   :cicd {:local-repo ".m2/repository"}})
