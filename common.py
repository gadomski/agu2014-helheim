from itertools import tee, izip
import os.path


def pairwise(iterable):
    a, b = tee(iterable)
    next(b, None)
    return izip(a, b)


def get_name(x, y):
    xname, _ = os.path.splitext(x)
    yname, _ = os.path.splitext(y)
    return xname + "-" + yname


def print_toplevel_target(name, targets):
    print "%s: %s\n.PHONY: %s" % (name, ' '.join(targets), name)
