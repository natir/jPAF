#!/usr/bin/env python3

import sys
import json

import gzip
import bz2
import lzma

def main(args):
    in_file = open(args[0], "r")

    reads_index = dict()
    out_data = list()

    read_index = 0;
    for l in in_file:
        l = l.strip().split()

        if l[0] not in reads_index:
            reads_index[l[0]] = (int(l[1]), read_index)
            read_index += 1
        if l[5] not in reads_index:
            reads_index[l[5]] = (int(l[6]), read_index)
            read_index +=1

        tmp = [
        reads_index[l[0]][1],
        int(l[2]),
        int(l[3]),
        l[4],
        reads_index[l[5]][1],
        int(l[7]),
        int(l[8]),
        int(l[9]),
        int(l[10]),
        int(l[11]),
        l[12]
        ]
        out_data.append(tmp)

    index = dict()
    for name, (length, i) in reads_index.items():
        index[i] = {"name": name, "len": length}
      
    header_index = {
        0:  "read_a",
        1:  "begin_a",
        2:  "end_a",
        3:  "strand",
        4:  "read_b",
        5:  "begin_b",
        6:  "end_b",
        7:  "nb_match",
        8:  "match_length",
        9:  "qual",
        10: "optional",
    }
    val = json.dumps({"header_index": header_index, "read_index": [val for _, val in sorted(index.items(), key=lambda x: x[0])], "match": out_data})
    
    out_file = open(args[1], "w")
    out_file.write(val)
    
    out_file = gzip.open(args[1]+".gz", "wb", compresslevel=9)
    out_file.write(val.encode())
    
    out_file = bz2.open(args[1]+".bz2", "wb", compresslevel=9)
    out_file.write(val.encode())
    
    out_file = lzma.open(args[1]+".xz", "wb", preset=9)
    out_file.write(val.encode())

if __name__ == '__main__':
    main(sys.argv[1:])
