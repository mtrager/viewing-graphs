## -------------------------------------------------------------- ##
## --------------------- Non-Solving Check ---------------------- ##
## -------------------------------------------------------------- ##

def adjacent_valence_two(G):

    for v in G.vertices():
        if (G.degree(v) == 2):
            for w in G.neighbors(v):
                if(G.degree(w) == 2):
                    return True
    return False

def non_solving_check(G):

    V = len(G.vertices())
    E = len(G.edges())

    if (7 * E - 11 * V + 15 < 0):
        return True

    if not G.is_biconnected():
        return True

    if (V > 3) and adjacent_valence_two(G):
        return True

    if diff_criterion_vertices(G):
        return True

    if diff_criterion_edges(G):
        return True

    return False


## -------------------------------------------------------------- ##
## ------------------ Difference Criterion ---------------------- ##
## -------------------------------------------------------------- ##


def diff(e, v):
    return 7 *e - 11 *v + 15


def diff_graph(G, block_check=False):
    # block_check: divides graph into biconnected components.

    if(block_check == True):
        C = G.connected_components_subgraphs()
        D = 0
        for c in C:
            if(len(c.vertices())>1):
                for vert_blocks in c.blocks_and_cut_vertices()[0]:
                    V = len(G.subgraph(vert_blocks).vertices())
                    E = len(G.subgraph(vert_blocks).edges())
                    D+= diff(E, V)

    else:
        V = len(G.vertices())
        E = len(G.edges())

        D = diff(E, V)

    return D


# def complete_diffs(G):

#     diffs = {}
#     for S in Subsets(G.vertices()):

#         if(len(S)>2):
#             diffs[str(S)] = diff_graph(G.subgraph(S))

#     return diffs


def diff_criterion_vertices(G):
    # True means graph is not solving (criterion is valid)

    D = diff_graph(G)
    if(D < 0):
        return True

    for S in Subsets(G.vertices()):
        if(len(S)>2):
            if(diff_graph(G.subgraph(S))>D):
                return True

    return False


def diff_criterion_edges(G):
    # True means graph is not solving (criterion is valid)

    D = diff_graph(G)
    if(D < 0):
        return True

    for S in Subsets(G.edges()):

        if(len(S)>1):
            H = G.subgraph(edges=S)
            if(diff_graph(H, True)>D):
                return True
    return False


## -------------------------------------------------------------- ##
## ------------------ Graph Moves Criterion --------------------- ##
## -------------------------------------------------------------- ##

def move_new_solid(G, H, verbose=False):
    # G is undirected and H is directed. Must have same size!!!

    MG = G.adjacency_matrix()
    MH = H.adjacency_matrix()
    V = MG.nrows()

    for i in range(V):
        for j in range(V):
            if(MG[i, j]==1):
                common_neighbors=[]
                for k in range(V):
                    if((MG[i, k]==1) and (MG[j, k]==1)):
                        common_neighbors.append(k)
                for t, a in enumerate(common_neighbors):
                    for b in common_neighbors[t +1:]:
                        if((a!=b) &(MG[a, b]!=1)):
                            MG[a, b]=1
                            MG[b, a]=1
                            MH[a, b]=1
                            MH[b, a]=1
                            if verbose:
                                print "Draw a (double) solid edge from %s to %s." %(a, b)

    return Graph(MG), DiGraph(MH)


def move_new_dashed(G, H, verbose=False):

    MG = G.adjacency_matrix()
    MH = H.adjacency_matrix()
    V = MH.nrows()

    for i in range(V):
        for j in range(V):
            if((MH[i, j]!=1) and (i!=j)):
                path_count = 0
                for k in range(V):
                    if((MH[i, k]==1) and (MG[j, k]==1) and (MG[k, j]==1)):
                        path_count +=1
                        if(path_count == 2):
                            MH[i, j]=1
                            if verbose:
                                print "Draw a directed dashed edge from %s to %s." %(i, j)
                            break

    return DiGraph(MH)


def move_dashed_upgrade(G, H, verbose=False):
    # G is undirected and H is directed. Must have same size!

    MG = G.adjacency_matrix()
    MH = H.adjacency_matrix()
    V = MG.nrows()

    for i in range(V):
        for j in range(V):
            if((MG[i, j]!=1) and (MH[i, j]==1) and (MH[j, i]==1)):
                path_count = 0
                for k in range(V):
                    if((k!=i) and (k!=j) and (MH[k, i]==1) and (MH[k, j]==1)):
                        path_count+=1
                        if(path_count == 3):
                            MG[i, j]=1
                            MG[j, i]=1
                            if verbose:
                                print "Make the double dashed edge from %s to %s solid." %(i, j)
                            break

    return Graph(MG)


def move_completion(G0, verbose=False):

    H0 = DiGraph(G0)

    while True:

        G1, H1 = move_new_solid(G0, H0, verbose)
        H1 = move_new_dashed(G1, H1, verbose)
        G1 = move_dashed_upgrade(G1, H1, verbose)

        if((G0==G1) and (H0==H1)):
            break
        G0 = G1
        H0 = H1

    return G1

## -------------------------------------------------------------- ##
## ---------------- Linear Degrees of Freedom ------------------- ##
## -------------------------------------------------------------- ##



def degrees_of_freedom(graph):

    G = [(g[0], g[1]) for g in graph.edges()]
    E = len(G)
    N = len(graph.vertices())

    # Create variables
    centers = ['c%s%s' %(d, i) for d in range(4) for i in range(N)]
    pairwise_transformations = ['m%s%s%s%s' %(d1, d2, i, j) for d1 in range(4) for d2 in range(4) for i in range(N) for j in range(i +1, N)]

    # Create ring
    KK = QQ
    R = PolynomialRing(KK, centers +pairwise_transformations)
    R.inject_variables()

    # Create matrices and centers
    for i in range(N):
        for j in range(i +1, N):
            mat = Matrix(0, 4)
            for d1 in range(4):
                mat = mat.stack(Matrix([R('m%s%s%s%s' %(d1, d2, i, j)) for d2 in range(4)]))

            mat_name = "M%s%s" %(i, j)
            exec("%s = %s" % (mat_name, 'mat'))

    for i in range(N):
        c = Matrix([[R('c0%s' %i), R('c1%s' %i), R('c2%s' %i), R('c3%s' %i)]]).T
        c_name = "C%s" %(i)
        exec("%s = %s" % (c_name, 'c'))

    # Impose constraints from graph
    neighbors = {}
    for i in range(N):
        neighbor_set =[]
        for pairs in G:
            if(pairs[0]==i):
                neighbor_set.append(pairs[1])
            if(pairs[1]==i):
                neighbor_set.append(pairs[0])
        neighbors[i] = neighbor_set

    constraints = ideal(R, 0)
    for i in range(N):
        exec("C = C%s" %i)
        for a in range(len(neighbors[i]) -1):
            j1 = neighbors[i][a]
            if i<j1:
                exec("M1 = M%s%s" %(i, j1))
            elif j1<i:
                exec("M1 = M%s%s" %(j1, i))
            j2 = neighbors[i][a +1]
            if i<j2:
                exec("M2 = M%s%s" %(i, j2))
            elif j2<i:
                exec("M2 = M%s%s" %(j2, i))
            new_constraints = compatibility(M1, M2, C)
            constraints = constraints + new_constraints

    # Fix one transformation
    M = M01  # transformation that is fixed
    constraints = constraints.subs(dict(zip(M.list(), identity_matrix(4).list())))

    # Fix random centers
    s = {}
    for i in range(N):
        for d in range(4):
            exec('s[c%s%s]=KK.random_element(100,10)' %(d, i)) # better random
            constraints = constraints.subs(s)

    # Compute dimension
    variables = set([])
    for g in constraints.gens():
        variables = variables.union(list(g.variables()))
    variables = list(variables)
    constraints = constraints.change_ring(PolynomialRing(KK, variables))
    dof = constraints.dimension() -(E -1)  # remove one dof for each matrix for scale

    # Clear output
    from IPython.display import clear_output
    clear_output()

    return dof

    # Constraint function


def compatibility(M1, M2, C):

    for d1 in range(4):
        for d2 in range(4):
            s1 ='m%s%s' %(d1, d2)
            s2 = 'M1[%s,%s]' %(d1, d2)
            s3 = 'M2[%s,%s]' %(d1, d2)
            exec("%s = %s - %s" % (s1, s2, s3))  # mij = M1[i,j]-M2[i,j]

    for d1 in range(4):
        s = 'c%s' %(d1)
        exec("%s = C[%s,0]" % (s, d1))  # ci = C[i]

    # relation
    I = ideal([m31 *c2 - m21 *c3, m30 *c2 - m20 *c3, m32 *c1 - m12 *c3, m31 *c1 - m32 *c2 - m11 *c3 + m22 *c3,
               m30 *c1 - m10 *c3, m23 *c1 - m13 *c2, m22 *c1 - m33 *c1 - m12 *c2 + m13 *c3,
               m21 *c1 - m11 *c2 + m33 *c2 - m23 *c3, m20 *c1 - m10 *c2, m32 *c0 - m02 *c3,
               m31 *c0 - m01 *c3, m30 *c0 - m32 *c2 - m00 *c3 + m22 *c3, m23 *c0 - m03 *c2,
               m22 *c0 - m33 *c0 - m02 *c2 + m03 *c3, m21 *c0 - m01 *c2, m20 *c0 - m00 *c2 + m33 *c2 - m23 *c3,
               m13 *c0 - m03 *c1, m12 *c0 - m02 *c1, m11 *c0 - m33 *c0 - m01 *c1 + m03 *c3,
               m10 *c0 - m00 *c1 + m33 *c1 - m13 *c3])

    return I


# ideal for M = kId + cv^T
# KK = QQ
# R = PolynomialRing(KK, 'm00, m01, m02, m03, m10, m11, m12, m13, m20, m21, m22, m23, m30, m31, m32, m33, c0, c1,c2,c3,v0,v1,v2,v3,k')
# R.inject_variables()

# M = Matrix([[m00+k, m01, m02, m03],
#             [m10, m11+k, m12, m13],
#             [m20, m21, m22+k, m23],
#             [m30, m31, m32, m33+k]])

# C = Matrix([[c0,c1,c2,c3]]).T
# V = Matrix([[v0,v1,v2,v3]]).T

# I = ideal((M-C*V.T).list())
# I = I.elimination_ideal([v0,v1,v2,v3])
# I = I.elimination_ideal(k)


# # I1 = ideal([f for f in I.gens() if(f.degree()==2)])

# I2 = ideal([m31*c2 - m21*c3, m30*c2 - m20*c3, m32*c1 - m12*c3, m31*c1 - m32*c2 - m11*c3 + m22*c3,
#            m30*c1 - m10*c3, m23*c1 - m13*c2, m22*c1 - m33*c1 - m12*c2 + m13*c3,
#            m21*c1 - m11*c2 + m33*c2 - m23*c3, m20*c1 - m10*c2, m32*c0 - m02*c3,
#            m31*c0 - m01*c3, m30*c0 - m32*c2 - m00*c3 + m22*c3, m23*c0 - m03*c2,
#            m22*c0 - m33*c0 - m02*c2 + m03*c3, m21*c0 - m01*c2, m20*c0 - m00*c2 + m33*c2 - m23*c3,
#            m13*c0 - m03*c1, m12*c0 - m02*c1, m11*c0 - m33*c0 - m01*c1 + m03*c3,
#            m10*c0 - m00*c1 + m33*c1 - m13*c3])

# I2.primary_decomposition()[1]==I
