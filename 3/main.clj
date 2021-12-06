(require 'clojure.string)

(defn read-lines [path]
  (clojure.string/split-lines (slurp path)))

(defn nth-bits [values i]
  (map (fn [value] (get value i)) values))

(defn most-frequent-bit [values i]
  (->> (nth-bits values i)
       frequencies
       (sort-by key)
       (sort-by val)
       reverse
       (take 1)
       first
       first))

(defn least-frequent-bit [values i]
  (->> (nth-bits values i)
       frequencies
       (sort-by key)
       (sort-by val)
       (take 1)
       first
       first))

(defn bin-to-int [bin]
  (->> bin
       (map (fn [x] (Integer/parseInt (str x))))
       (map-indexed (fn [i x] (bit-shift-left x (- (count bin) (+ 1 i)))))
       (reduce +)))

(defn bit-count [values]
  (count (first values)))

(defn gamma-rate [values]
  (bin-to-int (map (fn [idx] (most-frequent-bit values idx)) (range 0 (bit-count values)))))

(defn epsilon-rate [values]
  (bin-to-int (map (fn [idx] (least-frequent-bit values idx)) (range 0 (bit-count values)))))

(defn nth-bit-matching [values i bit]
  (filter (fn [val] (= (nth val i) bit)) values))

(defn most-frequent-bit-matching [values i]
  (nth-bit-matching values i (most-frequent-bit values i)))

(defn least-frequent-bit-matching [values i]
  (nth-bit-matching values i (least-frequent-bit values i)))

(defn oxygen-generator-rating [values]
  (bin-to-int (first (nth (nth (iterate (fn [[n v]] [(+ n 1) (most-frequent-bit-matching v n)]) [0 values]) (bit-count values)) 1))))

(defn co2-scrubber-rating [values]
  (bin-to-int (first (nth (nth (iterate (fn [[n v]] [(+ n 1) (least-frequent-bit-matching v n)]) [0 values]) (bit-count values)) 1))))

(let [values (read-lines "input.txt")]
  ; Part one
  (println (* (gamma-rate values) (epsilon-rate values)))
  ; Part two
  (println (* (oxygen-generator-rating values) (co2-scrubber-rating values))))