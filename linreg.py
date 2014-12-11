import numpy as np
from scipy import stats
import sys

data = np.genfromtxt(sys.argv[1], delimiter=",", skip_header=1)
n = len(data)
x = range(1, n + 1)

def rsquared(y):
    return stats.linregress(x, y)[4]

print "standard error for ", sys.argv[1]
print "GPSdX: ", rsquared(data[:,2])
print "GPSdY: ", rsquared(data[:,3])
print "GPSdZ: ", rsquared(data[:,4])
print "CPDdX: ", rsquared(data[:,5])
print "CPDdY: ", rsquared(data[:,6])
print "CPDdZ: ", rsquared(data[:,7])
