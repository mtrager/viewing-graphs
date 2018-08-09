## Computational Tests for Solvability

The file `view-graphs.sage` contains code in [Sage](http://www.sagemath.org)  for verifying whether a viewing graph is solvable [1]. A viewing graph is represented as an undirected "Graph" object in Sage. Such an object can be defined in different ways, for example as a list of edges:

```
G = Graph([(0,1),(1,2),(2,3),(3,0),(1,4),(4,5),(5,2)])
```

In an interactive notebook environment, the graph `G` can be visualized with the command `G.show()`. 

#### 1. Test for Non-Solvability

The function `non_solving_check()` can be used to prove that a graph is **not** solvable. Running `non_solving_check(G)` returns `True` if `G` is definitely not solvable, and `False` if `G` is a "candidate" for being solvable (although even in this case it may still be possible for G to be not solvable: see Example 5 in [1]).  The function runs the following tests (all
references are from [1]):

* *Basic edge/vertex count* (Theorem 1): returns `True` if d(e,n) = 7e - 11n + 15<0, where e and n are respectively the number of edges and vertices of `G`.
* *Bi-connected criterion* (Proposition 3): returns `True` if `G` is not bi-connected, i.e., if it is possible to make the graph disconnected by removing one vertex.
* *"Adjacent-valence" criterion* (Proposition 2): returns `True` if `G` contains two adjacent vertices of valence two.
* *"d-condition" with vertices* (Theorem 2): returns `True` if there exists a subset of vertices of `G` inducing a subgraph `H` with with e' edges and v' vertices and d(e',n')>d(e,n).
* *"d-condition" with edges* (Theorem 2): returns `True` if there exists a subgraph `H` with e' edges and v' vertices such that d(e',n')>d(e,n).

The last "d-condition" criterion is actually stronger than all the previous ones, but it is computationally more expensive.


#### 2. Test for Solvability

The function `move_completion()` can be used to prove that a graph is solvable. Running `move_completion(G)` returns a graph `K` that is obtained from `G` by applying the three "moves" from Theorem 3 in [1] cyclically, until no new move is possible. If the resulting graph `K` is a complete graph (that can be verified with the command `K.is_clique()`) then `G` is solvable. Note that in special cases it may be possible that `K` is not complete even though `G` is solvable (see Examples 4 and 6 in [1]). 

Running the function `move_completion()` with the optional parameter `verbose` set to `True` (i.e.,`move_complection(G,verbose=True)`) also prints a sequence of moves that produce `K` starting from `G`. 


#### 3. Test for Finite-Solvability

The function `degrees_of_freedom()` can be used to verify whether or not a graph is *finite solvable*. The output of `degrees_of_freedom(G)` is the dimension of the set *T_G(c_1,...,c_n)* defined in Section 4 of [1]. This number is zero if and only if the graph is finite solvable. If this number is greater than zero, then the viewing graph generically identifies an infinite number of camera configurations. The dimensionality of *T_G(c_1,...,c_n)* is computed by verifying the rank of a matrix, corresponding to the linear compatibility equations described in Proposition 6 in [1] (after randomly fixing the camera pinholes).


#### References

<!-- [1] Developers, T.S.: *SageMath, the Sage Mathematics Software System* (Version 8.0.0). (2017) http://www.sagemath.org. -->

[1] Matthew Trager, Brian Osserman, Jean Ponce: *On Solvability of Viewing graphs*, ECCV 2018 (https://arxiv.org/abs/1808.02856).