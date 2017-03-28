# count # of lines
bzip2 -dck ss13hus.csv.bz2 | wc -l
# look at the headers
bzip2 -dck ss13hus.csv.bz2 | head -n 1
# look at first line of data
bzip2 -dck ss13hus.csv.bz2 | head -n 2 | tail -n 1
# count number of columns
bzip2 -dck ss13hus.csv.bz2 | head -n 1 | sed -e $'s/,/\\\n/g' | wc -l