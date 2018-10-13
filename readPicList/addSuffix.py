#!/usr/bin/python3
# -*- coding: UTF-8 -*-

import sys, getopt
import os

def main(argv):
	inputfile = ''
	outputfile_csv = ''
	outputfile_jpg = ''
	try:
		opts, args = getopt.getopt(argv,"h",["inputfile=","outputfile_csv=","outputfile_jpg="])
	except getopt.GetoptError:
		print('python3 addSuffix.py --inputfile <inputfile> --outputfile_csv <csv_list> --outputfile_jpg <pic_list>')
		sys.exit(2)
	for opt, arg in opts:
		if opt == '-h':
			print('python3 addSuffix.py --inputfile <inputfile> --outputfile_csv <csv_list> --outputfile_jpg <pic_list>')
			sys.exit()
		elif opt in ("--inputfile"):
			inputfile = arg
		elif opt in ("--outputfile_csv"):
			outputfile_csv = arg
		elif opt in ("--outputfile_jpg"):
			outputfile_jpg = arg
	print('input path is ：', inputfile)
	print('csv list is :', outputfile_csv)
	print('jpg list is :', outputfile_jpg)
	
	f = open(inputfile)
	lines = f.readlines()
	f.close()
	for line in lines:
		rs = line.rstrip('\n')
		newname=rs.replace(rs,rs+'.csv')
		newfile=open(outputfile_csv,'a')
		newfile.write(newname+'\n')
		
		newname=rs.replace(rs,rs+'.jpg')
		newfile=open(outputfile_jpg,'a')
		newfile.write(newname+'\n')
		
		newfile.close()

if __name__ == "__main__":
   main(sys.argv[1:])
   
