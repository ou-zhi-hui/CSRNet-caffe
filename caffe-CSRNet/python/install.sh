for req in $(cat requirements.txt); do pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple $req; done 
