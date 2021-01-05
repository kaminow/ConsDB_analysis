import sys
from random import random

fns = [open(sys.argv[1].format(i), 'w+') for i in range(2)]

fn_dict = {}
for line in sys.stdin:
    if line[0] == '@':
        for fp in fns:
            fp.write(line)
        continue

    read_id = line.split()[0]
    try:
        fp_id = fn_dict[read_id]
    except KeyError:
        fp_id = fn_dict[read_id] = 0 if random() < 0.5 else 1

    fns[fp_id].write(line)

for fp in fns:
    fp.close()