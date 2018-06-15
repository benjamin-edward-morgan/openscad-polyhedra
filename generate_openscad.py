#!/usr/bin/env python3



tetrahedron_vertices = \
 [[1,1,1], \
  [1,-1,-1], \
  [-1,1,-1], \
  [-1,-1,1]] \

tetrahedron_edges = \
  [[0,1],[1,2],[0,2], \
   [2,3],[1,3],[0,3]]

def find_adjacent_vertices(n, edges):
    result = []
    for i in range(0,n):
        adjacents = []
        for edge in edges:
            if(edge[0] == i):
                adjacents = adjacents+[edge[1]]
            if(edge[1] == i):
                adjacents = adjacents+[edge[0]]
        result = result + [adjacents]
    return result

def recursive_search(startIndex, currentIndex, adjacents):
    if(currentIndex == startIndex):
        return []
    for 


def find_faces(adjacents):
    result = {}
    for i in range(0,len(adjacents)):
        adjacents[i]

    return result



tetra_adjacents = find_adjacent_vertices(len(tetrahedron_vertices),tetrahedron_edges)

print(tetra_adjacents)

tetra_faces = find_faces(tetra_adjacents)

print(tetra_faces)
