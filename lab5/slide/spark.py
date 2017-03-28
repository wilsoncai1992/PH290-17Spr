# =====================================================================================
# preprocess data
# =====================================================================================
from operator import add
import numpy as np

lines = sc.textFile('/data/airline').cache()
numLines = lines.count()

# particularly for in-class demo - good to repartition the 3 files to more partitions
lines = lines.repartition(36).cache()

# mapper
def stratify(line):
	vals = line.split(',')
	return(vals[16], 1)

result = lines.map(stratify).reduceByKey(add).collect()
# reducer is simply the addition function

# >>> result
#[(u'Origin', 22), (u'CIC', 7281), (u'LAN', 67897), (u'LNY', 289), (u'DAB', 86656), (u'APF', 4074), (u'ATL', 6100953), (u'BIL', 92503), (u'JAN', 190044), (u'GTR', 7520), (u'ISO', 5945), (u'SEA', 1984077), (u'PIT', 2072303), (u'ONT', 774679), (u'ROW', 1196), (u'PWM', 161602), (u'FAY', 44564), (u'SAN', 1546835), (u'ADK', 589), (u'ADQ', 10327), (u'IAD', 1336957), (u'ANI', 475), (u'CHO', 19324), (u'HRL', 116018), (u'ACV', 23782), (u'DAY', 380459), (u'ROA', 69361), (u'VIS', 1993), (u'PSC', 38408), (u'MDW', 1170344), (u'MRY', 67926), (u'MCO', 1967493), (u'EKO', 12808), (u'RNO', 510023), (u'TPA', 1321652), (u'OME', 21403), (u'DAL', 952216), (u'GJT', 34921), (u'ALB', 292764), (u'SJT', 16590), (u'CAK', 80821), (u'TUP', 1971), (u'MKG', 396), (u'DEN', 3319905), (u'MDT', 167293), (u'RKS', 954), (u'GSP', 200147), (u'LAW', 18019), (u'MCN', 7203), (u'PIA', 44780), (u'ROC', 368099), (u'BQK', 6934), (u'MSP', 2754997), (u'ACT', 21081), (u'SBA', 119959), (u'HPN', 125500), (u'RFD', 1560), (u'CCR', 4465), (u'BWI', 1717380), (u'SJU', 461019), (u'SAV', 185855), (u'HOU', 1205951), (u'BPT', 8452), (u'RDU', 103678 ....

# this counting by key could have been done
# more easily using countByKey()

vals = [x[1] for x in result]
sum(vals) == numLines  # a bit of a check
# True
[x[1] for x in result if x[0] == "SFO"]  # SFO result
# [2733910]

# if don't collect, can grab a few results
output = lines.map(stratify).reduceByKey(add)
output.take(5)
#[(u'Origin', 22), (u'CIC', 7281), (u'LAN', 67897), (u'LNY', 289), (u'DAB', 86656)]

# also, you can have interim results stored as objects
mapped = lines.map(stratify)
result = mapped.reduceByKey(add).collect()


lines.filter(lambda line: "SFO" in line.split(',')[16]).saveAsTextFile('/data/airline-SFO')

## make sure it's all in one chunk for easier manipulation on master
lines.filter(lambda line: "SFO" in line.split(',')[16]).repartition(1).saveAsTextFile('/data/airline-SFO2')
#lines.filter(lambda line: "SFO" in line.split(',')[16]).repartition(1).
#saveAsTextFile('/data/airline-SFO2')
#



# =====================================================================================
# compute median
# =====================================================================================
def computeKeyValue(line):
	vals = line.split(',')
	# key is carrier-month-origin-destination
	keyVals = '-'.join([vals[x] for x in [8,1,16,17]])
	if vals[0] == 'Year':
		return('0', [0,0,1,1])
	cnt1 = 1
	cnt2 = 1
	# 14 and 15 are arrival and departure delays
	if vals[14] == 'NA':
		vals[14] = '0'
		cnt1 = 0
	if vals[15] == 'NA':
		vals[15] = '0'
		cnt2 = 0
	return(keyVals, [int(vals[14]), int(vals[15]), cnt1, cnt2])


def medianFun(input):
	if len(input) == 2:  # input[0] should be key and input[1] set of values
		if len(input[1]) > 0:
			# iterate over set of values
			# input[1][i][0] is arrival delay
			# input[1][i][1] is departure delay
			m1 = np.median([val[0] for val in input[1] if val[2] == 1])
			m2 = np.median([val[1] for val in input[1] if val[3] == 1])
			return((input[0], m1, m2)) # m1, m2))
		else:
			return((input[0], -999, -999))
	else:
		return((input[0], -9999, -9999))


output = lines.map(computeKeyValue).groupByKey().cache()
medianResults = output.map(medianFun).collect()
medianResults[0:5]
# [(u'DL-8-PHL-LAX', 85.0, 108.0), (u'OO-12-IAH-CLL', -6.0, 0.0), (u'AA-4-LAS-JFK', 2.0, 0.0), (u'WN-8-SEA-GEG', 0.0, 0.0), (u'MQ-1-ORD-MDT', 3.0, 1.0)]



# =====================================================================================
# OLS
# =====================================================================================
lines = sc.textFile('/data/airline')

def screen(vals):
	vals = vals.split(',')
	return(vals[0] != 'Year' and vals[14] != 'NA' and
		   vals[18] != 'NA' and vals[3] != 'NA' and
		   float(vals[14]) < 720 and float(vals[14]) > (-30) )
# 0 field is Year
# 14 field is ArrDelay
# 18 field is Distance
# 3 field is DayOfWeek

lines = lines.filter(screen).repartition(192).cache()
# 192 is a multiple of the total number of cores: 24 (12 nodes * 2 cores/node)

n = lines.count()

import numpy as np
from operator import add

P = 8
bc = sc.broadcast(P)

#######################
# calc xtx and xty
#######################
def crossprod(line):
	vals = line.split(',')
	y = float(vals[14])
	dist = float(vals[18])
	dayOfWeek = int(vals[3])
	xVec = np.array([0.0] * P)
	xVec[0] = 1.0
	xVec[1] = float(dist)/1000
	if dayOfWeek > 1:
		xVec[dayOfWeek] = 1.0
	xtx = np.outer(xVec, xVec)
	xty = xVec * y
	return(np.c_[xtx, xty])

xtxy = lines.map(crossprod).reduce(add)
# 11 minutes

# now just solve system of linear equations!!
mle = np.linalg.solve(xtxy[0:P,0:P], xtxy[0:P,P])






#######################
# OPTIONAL calc xtx and xty w/ mapPartitions
#######################

# dealing with x matrix via mapPartitions

def readPointBatch(iterator):
	strs = list(iterator)
	matrix = np.zeros((len(strs), P+1))
	for i in xrange(len(strs)):
		vals = strs[i].split(',')
		dist = float(vals[18])
		dayOfWeek = int(vals[3])
		xVec = np.array([0.0] * (P+1))
		xVec[8] = float(vals[14]) # y
		xVec[0] = 1.0  # int
		xVec[1] = float(dist) / 1000
		if(dayOfWeek > 1):
			xVec[dayOfWeek] = 1.0
		matrix[i] = xVec
	return([matrix.T.dot(matrix)])

xtxyBatched = lines.mapPartitions(readPointBatch).reduce(add)
# 160 seconds

mle = np.linalg.solve(xtxy[0:P,0:P], xtxy[0:P,P])