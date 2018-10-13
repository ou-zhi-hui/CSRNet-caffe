#include "ml.h"
#include <stdio.h>
#include "caffe/caffe.hpp"
#include <iostream>
#include <lmdb.h>
#include <stdint.h>
#include <fstream>  // NOLINT(readability/streams)
#include <string>
#include <sys/stat.h>
#include "caffe/proto/caffe.pb.h"// 解析caffe中proto类型文件的头文件

#include <opencv2/ml/ml.hpp>

using namespace std;
using namespace cv;
void serialize_label(const char* lmdb_path,const std::string csv_list,std::string ground_truth_csv)
{
	MDB_env *mdb_env;//数据库环境的“不透明结构”，不透明类型是一种灵活的类型，他的大小是未知的
	MDB_dbi mdb_dbi;//在数据库环境中的一个独立的数据句柄
	MDB_val mdb_key, mdb_data;//用于从数据库输入输出的通用结构
	MDB_txn *mdb_txn;//不透明结构的处理句柄，所有的数据库操作都需要处理句柄，处理句柄可指定为只读或读写
	
	LOG(INFO) << "Opening lmdb " << lmdb_path;
	CHECK_EQ(mkdir(lmdb_path, 0744), 0) << "mkdir " << lmdb_path << " failed";
	CHECK_EQ(mdb_env_create(&mdb_env), MDB_SUCCESS) << "mdb_env_create failed";// 创建一个lmdb环境句柄，此函数给mdb_env结构分配内存；
	CHECK_EQ(mdb_env_set_mapsize(mdb_env, 1073741824), MDB_SUCCESS) << "mdb_env_set_mapsize failed";// 设置当前环境的内存映射（内存地图）的尺寸。
	CHECK_EQ(mdb_env_open(mdb_env, lmdb_path, 0, 0664), MDB_SUCCESS) << "mdb_env_open failed";//打开环境句柄
	CHECK_EQ(mdb_txn_begin(mdb_env, NULL, 0, &mdb_txn), MDB_SUCCESS) << "mdb_txn_begin failed";//在环境内创建一个用来使用的“处理”transaction句柄
	CHECK_EQ(mdb_open(mdb_txn, NULL, 0, &mdb_dbi), MDB_SUCCESS) << "mdb_open failed. Does the lmdb already exist? ";
	  
	
	
	ifstream infile; 
	std::string file = csv_list;//CSV文件名
    infile.open(file.data());   //将文件流对象与文件连接起来 
    assert(infile.is_open());   //若失败,则输出错误消息,并终止程序运行 
    std::string filename ;
	CvMLData mlData;//opencv2
	//Ptr<ml::TrainData> train_data;//opencv3
	const int kMaxKeyLength = 10;
	char key_cstr[kMaxKeyLength];
	std::string value;
	int count = 0;
	while(getline(infile,filename))
	{
		filename = ground_truth_csv +filename;//ground_truth 
		printf("%s\n",filename.data());
		//opencv2
		mlData.read_csv(filename.data());//读取csv文件 opencv2
		cv::Mat map = cv::Mat(mlData.get_values(), true);
		
		//opencv3
		//train_data = ml::TrainData::loadFromCSV(filename,0);
		//cv::Mat map_L = train_data->getTrainSamples();
		//cv::Mat map_R = train_data->getTrainResponses();
		//cv::Mat map;
		//hconcat(map_L,map_R,map);
		printf("row = %d,col = %d\n",map.rows,map.cols);

		//map
		caffe::Datum datum;
		datum.set_channels(1); 
		datum.set_encoded(false); 
		datum.set_height(map.rows);
		datum.set_width(map.cols);
		
		float *ptr = map.ptr<float>();
		for (int i = 0; i < map.cols * map.rows; i++)
			datum.add_float_data(ptr[i]);
		
		 // serialize
		datum.SerializeToString(&value);// 感觉是将 datum 中的值序列化成字符串，保存在变量 value 内，通过指针来给 value 赋值
		
		
		// 这里是把 item_id 转换成 8 位长度的十进制整数，然后在变成字符串复制给 key_str, 如：item_id=15000（int）, 则 key_cstr = 00015000（string, \0为字符串结束标志）
		snprintf(key_cstr, kMaxKeyLength, "%08d", count);
		count++;
		std::string keystr(key_cstr);
	
		mdb_data.mv_size = value.size();//获取value的字节长度，类似sizeof（）函数	
		mdb_data.mv_data = reinterpret_cast<void*>(&value[0]);// 把 value 的首个字符地址转换成空类型的指针
		mdb_key.mv_size = keystr.size();
		mdb_key.mv_data = reinterpret_cast<void*>(&keystr[0]);
		
		CHECK_EQ(mdb_put(mdb_txn, mdb_dbi, &mdb_key, &mdb_data, 0), MDB_SUCCESS) << "mdb_put failed";// 通过 mdb_put 函数把 mdb_key 和 mdb_data 所指向的数据, 写入到 mdb_dbi
		CHECK_EQ(mdb_txn_commit(mdb_txn), MDB_SUCCESS) << "mdb_txn_commit failed";//感觉是通过mdb_txn_commit函数把mdb_txn中的数据写入到硬盘
		CHECK_EQ(mdb_txn_begin(mdb_env, NULL, 0, &mdb_txn), MDB_SUCCESS) << "mdb_txn_begin failed";// 重新设置 mdb_txn 的写入位置, 追加（继续）写入
	}
    		   	
	
	
	mdb_close(mdb_env, mdb_dbi);// 关闭 mdb 数据对象变量
	mdb_env_close(mdb_env);// 关闭 mdb 操作环境变量
}
int main(int argc, char *argv[])
{	
	if(argc != 7)
	{
		printf("error usage!\n");
		printf("usage: ./csv2lmdb --lmdb_path <lmdb output path> --csv_list <readPicList generate label.txt> --ground_truth_path <ground_truth_csv path>\n");
		return -1;
	}
	
	char* lmdb_path = argv[2];
	std::string csv_list = argv[4];
	std::string ground_truth_path = argv[6];
	
	printf("lmdb_path :%s,csv_list :%s,ground_truth_path : %s",
	lmdb_path,csv_list,ground_truth_path);
	
	serialize_label(lmdb_path,csv_list,ground_truth_path);
	
	return 0;
}


