(ns clojure-jni-example.core
  (:import Test)
  (:gen-class))

(defn -main
  []
  (println "Hello from Clojure!")
  (Test/print "User"))
