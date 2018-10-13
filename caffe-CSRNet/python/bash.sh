for req in $(cat requirements.txt); do pip install $req -i https://pypi.tuna.tsinghua.edu.cn/simple; done
