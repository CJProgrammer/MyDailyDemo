#bin/bash

git_prefix=".git"

if [ ! -d "$git_prefix" ]; then
	echo "! [Illegal git repository directory]"
	echo "  移动脚本到git仓库根目录"
	exit 1
fi


if [ ! -d ".git/hooks" ]; then
    mkdir ".git/hooks"
	echo "mkdir successfull"
fi

if [ -f ".git/HEAD" ]; then
    head=$(< ".git/HEAD")
    if [[ $head = ref:\ refs/heads/* ]]; then
        git_branch="${head#*/*/}"
    else
        echo "无法获取当前分支"
	    exit 1
    fi

else
    echo "没有git中的HEAD文件"
	exit 1
fi

echo "当前分支为:$git_branch"

git push origin $git_branch
if [ $? -eq 0 ]; then
	exit 0
else
	exit 1
fi
