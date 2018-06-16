#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-


""" Do stuff.

"""


from collections import defaultdict, deque

import os
import re
import argparse
import itertools


def get_args():
    """ Get command line arguments. """
    parser = argparse.ArgumentParser(
        description='Run STXing detector in parallel.'
    )
    parser.add_argument(
        '-i', '--input-directory',
        dest='indir',
        required=True,
        help='Path to directory containing fastq reads.'
    )
    return parser.parse_args()


def get_unique(l):
    """ Combine list of lists into one big-ass list. """
    return list(set([item for sublist in l for item in sublist]))


def get_adjacent_vertices(edges):
    """ Turn a set of edges into a set of vertices. """
    # build lookups for vertices
    big_ole_dict = defaultdict(set)
    adjacent_vertices = []
    for a, b in edges:
        big_ole_dict[a] |= {b}
        big_ole_dict[b] |= {a}

    for v in big_ole_dict.values():
        adjacent_vertices.append(list(v))

    return adjacent_vertices


def facetize(edges):
    """ Turn a set of edges into a set of consistently numbered faces. """

    def conflict(f1, f2):
        """ Returns true if the order of two faces conflict with one another. """
        return any(
            e1 == e2
            for e1, e2 in itertools.product(
                (f1[0:2], f1[1:3], f1[2:3] + f1[0:1]),
                (f2[0:2], f2[1:3], f2[2:3] + f2[0:1])
            )
        )

    # build lookups for vertices
    adjacent_vertices = defaultdict(set)
    for a, b in edges:
        adjacent_vertices[a] |= {b}
        adjacent_vertices[b] |= {a}

    orderless_faces = set()
    adjacent_faces = defaultdict(set)
    print(adjacent_vertices)
    for a, b in edges:
        # create faces initially with increasing vertex numbers
        f1, f2 = (tuple(sorted([a, b, c])) for c in adjacent_vertices[a] & adjacent_vertices[b])

        # print(adjacent_vertices[a], adjacent_vertices[b])
        # for c in adjacent_vertices[a] & adjacent_vertices[b]:
        #     print(a, b, c)
        #     print(tuple(sorted([a, b, c]))
        print(f1, f2)

        orderless_faces |= {f1, f2}
        adjacent_faces[f1] |= {f2}
        adjacent_faces[f2] |= {f1}

    # state for BFS
    processed = set()
    to_visit = deque()

    # result of BFS
    needs_flip = {}

    # define the first face as requiring no flip
    first = next(iter(orderless_faces))
    needs_flip[first] = False
    to_visit.append(first)

    while to_visit:
        face = to_visit.popleft()
        for next_face in adjacent_faces[face]:
            if next_face not in processed:
                processed.add(next_face)
                to_visit.append(next_face)
                if conflict(next_face, face):
                    needs_flip[next_face] = not needs_flip[face]
                else:
                    needs_flip[next_face] = needs_flip[face]

    return [f[::-1] if needs_flip[f] else f for f in orderless_faces]


if __name__ == '__main__':

    # edges = [(0, 1), (1, 2), (0, 2), (2, 3), (1, 3), (0, 3)]
    edges = [(0, 1), (0, 2), (1, 3), (2, 3), (4, 5), (4, 6), (5, 7), (6, 7), (0, 4), (1, 5), (2, 6), (3, 7)]

    # print adjacent vertices, returns defaultdict object
    adjacent_vertices = get_adjacent_vertices(edges)
    # print('Adjacent Vertices: {}'.format(adjacent_vertices))

    # print faces
    x = facetize(edges)
    print('Faces: {}'.format(map(list, x)))


    # hexahedron
    # hexahedron_vertices =
    # [[-1, -1, -1],
    #  [1, -1, -1],
    #  [-1, 1, -1],
    #  [1, 1, -1],
    #  [-1, -1, 1],
    #  [1, -1, 1],
    #  [-1, 1, 1],
    #  [1, 1, 1]] / 2;
    #
    # hexahedron_edges =
    # [[0, 1], [0, 2], [1, 3], [2, 3],
    #  [4, 5], [4, 6], [5, 7], [6, 7],
    #  [0, 4], [1, 5], [2, 6], [3, 7]];
    #
    # hexahedron_adjacent_vertices =
    # [1, 3, 3, 7, 5, 7, 7, 6];










    # tetrahedron_real_adjacent_vertices =
    #   [[1,2,3],[0,2,3],[0,1,3],[0,1,2]];
    #
    # tetrahedron_faces =
    #   [[0,2,1],[3,0,1],[1,2,3],[3,2,0]];


    # vertices = [[1, 1, 1], [1, -1, -1], [-1, 1, -1], [-1, -1, 1]]
    #
    # print(facetize(edges))
    # f = '/Users/sim/PycharmProjects/stxing/edges.txt'
    # with open(f, 'rU') as fh:
    #     line = fh.read()
    #     l = line[1:-1].split(', ')
    #     print(l)
    #     new_list = []
    #     for i in l:
    #         p = list(i)
    #         for item in p:
    #             m = re.search('^[0-9]+$', item)
    #             print(m.group(0))
    #         new_list.append(i)
