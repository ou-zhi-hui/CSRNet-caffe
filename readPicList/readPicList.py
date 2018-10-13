#!/usr/bin/python3
# -*- coding: UTF-8 -*-

import sys, getopt
import os

def main(argv):
	inputpath = ''
	outputfile = ''
	try:
		opts, args = getopt.getopt(argv,"hi:o:",["ipath=","ofile="])
	except getopt.GetoptError:
		print('python3 readPicList.py -i <data_path> -o <pic_list>')
		sys.exit(2)
	for opt, arg in opts:
		if opt == '-h':
			print('python3 readPicList.py -i <data_path> -o <pic_list>')
			sys.exit()
		elif opt in ("-i", "--ipath"):
			inputpath = arg
		elif opt in ("-o", "--ofile"):
			outputfile = arg
	print('data path is ：', inputpath)
	print('picture list is :', outputfile)
	
	names = os.listdir(inputpath)
	i=0  
	train_val = open(outputfile,'w')
	for name in names:
		index = name.rfind('.')
		name = name[:index]
		train_val.write(name+'\n')
		print(name)
		i=i+1

if __name__ == "__main__":
   main(sys.argv[1:])