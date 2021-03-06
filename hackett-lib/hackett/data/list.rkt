#lang hackett/base

(require hackett/data/maybe
         hackett/private/prim)

(provide (data List) head tail head! tail! take drop filter foldr foldl reverse zip-with sum
         repeat cycle! or and any? all? elem? not-elem? delete delete-by)

(defn head : (∀ [a] {(List a) -> (Maybe a)})
  [[{x :: _}] (just x)]
  [[nil     ] nothing])

(defn tail : (∀ [a] {(List a) -> (Maybe (List a))})
  [[{_ :: xs}] (just xs)]
  [[nil      ] nothing])

(defn head! : (∀ [a] {(List a) -> a})
  [[xs] (from-maybe (error! "head!: empty list") (head xs))])

(defn tail! : (∀ [a] {(List a) -> (List a)})
  [[xs] (from-maybe (error! "tail!: empty list") (tail xs))])

(defn take : (∀ [a] {Integer -> (List a) -> (List a)})
  [[n {x :: xs}]
   (if {n == 0}
       nil
       {x :: (take {n - 1} xs)})]
  [[_ nil]
   nil])

(defn drop : (∀ [a] {Integer -> (List a) -> (List a)})
  [[n {x :: xs}]
   (if {n == 0}
       {x :: xs}
       (drop {n - 1} xs))]
  [[_ nil]
   nil])

(defn filter : (∀ [a] {{a -> Bool} -> (List a) -> (List a)})
  [[f {x :: xs}] (let ([ys (filter f xs)]) (if (f x) {x :: ys} ys))]
  [[_ nil      ] nil])

(defn foldl : (∀ [a b] {{b -> a -> b} -> b -> (List a) -> b})
  [[f a {x :: xs}] (let ([b (f a x)]) {b seq (foldl f b xs)})]
  [[_ a nil      ] a])

(def reverse : (∀ [a] {(List a) -> (List a)})
  (foldl (flip ::) nil))

(defn zip-with : (∀ [a b c] {{a -> b -> c} -> (List a) -> (List b) -> (List c)})
  [[f {x :: xs} {y :: ys}] {(f x y) :: (zip-with f xs ys)}]
  [[_ _         _        ] nil])

(def sum : {(List Integer) -> Integer}
  (foldl + 0))

(defn repeat : (∀ [a] {a -> (List a)})
  [[x] (letrec ([xs {x :: xs}]) xs)])

(defn cycle! : (∀ [a] {(List a) -> (List a)})
  [[nil] (error! "cycle!: empty list")]
  [[xs ] (letrec ([ys {xs ++ ys}]) ys)])

(def or : {(List Bool) -> Bool}
  (foldr || false))

(def and : {(List Bool) -> Bool}
  (foldr && true))

(defn any? : (∀ [a] {{a -> Bool} -> (List a) -> Bool})
  [[f] {or . (map f)}])

(defn all? : (∀ [a] {{a -> Bool} -> (List a) -> Bool})
  [[f] {and . (map f)}])

(defn elem? : (∀ [a] (Eq a) => {a -> (List a) -> Bool})
  [[x] (any? (== x))])

(defn not-elem? : (∀ [a] (Eq a) => {a -> (List a) -> Bool})
  [[x] (all? {not . (== x)})])

(def delete : (∀ [a] (Eq a) => {a -> (List a) -> (List a)})
  (delete-by ==))

(defn delete-by : (∀ [a] {{a -> a -> Bool} -> a -> (List a) -> (List a)})
  [[=? x {y :: ys}]
   (if {y =? x}
       ys
       {y :: (delete-by =? x ys)})]
  [[_ _ nil]
   nil])
