import sys, string, os, gzip

def loadval():
    f = open('FRBGamm.val')
    lines = f.readlines()
    f.close()
    del lines[0]
    for i in range(len(lines)):
        l = lines[i]
        v = string.split(l)
        l = string.join(v, '')
        lines[i] = l
    return lines
    
def writeQsub(val):
    str = """/vlsci/VR0062/jordan/nrn/x86_64/bin/nrniv -mpi \
     -c e2e2=%c \
     -c e2e5=%c \
     -c e2e6=%c \
     -c e2i2=%c \
     -c e2i6=%c \
     -c e4e2=%c \
     -c e4e4=%c \
     -c e4e5=%c \
     -c e4e6=%c \
     -c e4i2=%c \
     -c e4i6=%c \
     -c e5e2=%c \
     -c e5e4=%c \
     -c e5e5=%c \
     -c e5e6=%c \
     -c e5i2=%c \
     -c e5i6=%c \
     -c e6e2=%c \
     -c e6e4=%c \
     -c e6e5=%c \
     -c e6e6=%c \
     -c e6i2=%c \
     -c e6i6=%c \
     -c i2e2=%c \
     -c i2e4=%c \
     -c i2e5=%c \
     -c i2e6=%c \
     -c i2i2=%c \
     -c i2i6=%c \
     -c i6e4=%c \
     -c i6e5=%c \
     -c i6e6=%c \
     -c i6i6=%c \
     evan.hoc
    """ % tuple(val)


    qsub = """#!/bin/bash
#PBS -l walltime=8:00:00
#PBS -l pvmem=3gb
#PBS -l procs=16
#PBS -N %s
#PBS -j oe
    
cd ~/FRBGamma

mpiexec %s

gzip -f data/efs/en*_%s.dat
gzip -f data/spikes/sn*_%s.dat
gzip -f data/traces/trace_*_%s.dat

""" % (val, str, val, val, val)
    file = 'x'
    f = open(file, 'w')
    f.write(qsub)
    f.close()
    os.system('qsub x')
    return

def testFile(val):
    s = string.join(val, '')
    fn = 'data/efs/en0_%s.dat.gz' % s
    if os.access(fn, os.F_OK):
        return True
    fn = 'data/efs/en0_%s.dat' % s
    if os.access(fn, os.F_OK):
        return True
    return False

vals = loadval()
startN = 0
stopN  = len(vals)
cnt = 0
for i in range(startN, stopN):
    v = vals[i]
    writeQsub(v)
    cnt = cnt + 1
print '\n\n%d runs started' % cnt

