(defproject clojure-jni-example
  "0.1.0-SNAPSHOT"

  :description "An example of calling JNI from Clojure."
  :license {:name "MIT"}

  :main clojure-jni-example.core

  :source-paths ["src"]
  :java-source-paths ["src-java"]
  :clean-targets ^{:protect false} [:target-path "resources/lib/"]

  :plugins [[lein-shell "RELEASE"]]

  :dependencies [[org.clojure/clojure "1.11.1"]]

  :profiles
  {:uberjar {:aot :all
             :compile-path "target/uberjar/classes"
             ;; NOTE
             ;;  don't remove `compile` from `:prep-tasks`
             ;;  see, https://github.com/technomancy/leiningen/issues/2129#issuecomment-336748666
             :prep-tasks [["shell" "make" "lib"] "javac" "compile"]}
   :dev {:prep-tasks [["shell" "make" "lib"] "javac"]
         :repl-options {:init-ns user}}
   :test {:compile-path "target/test/classes"}
   :cicd {:local-repo ".m2/repository"}})
