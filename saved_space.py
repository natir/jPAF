#!/usr/bin/env python3

import os
import bz2
import sys
import json
import gzip
import lzma
import itertools

from collections import defaultdict

def main(args):

    files = args
    print(files)

    file2size = dict()
    
    for f in files:
        file2size[f] = os.stat(f).st_size

    files2files2save_space = defaultdict(dict)

    for f1, f2 in itertools.product(files, files):
        if f1 == f2:
            files2files2save_space[f1][f2] = 0.0
        else:
            files2files2save_space[f1][f2] = 1 - (file2size[f1] / file2size[f2])

    print(" ,", ",".join(files))
    for f1 in files:
        print(",".join([f1] + [str(files2files2save_space[f1][f2]) for f2 in files]))

if __name__ == '__main__':
    main(sys.argv[1:])

