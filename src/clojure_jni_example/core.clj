(ns clojure-jni-example.core
  (:gen-class)
  (:import Test))

(set! *warn-on-reflection* true)


(defn -main [& _]
  (println "Hello from Clojure!")
  (Test/print "User"))
