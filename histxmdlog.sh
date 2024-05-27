#!/bin/bash
#hiscmd 函数功能定义发送日志的格式
function hiscmd()
{
  #定义两个本地变量
  local result=$?
  local result_str=""
  #定义执行shell命令后返回的结果代码来打印不同的值
  if [ $result -eq 0 ];then
    result_str="return code=[0],execute sucess"
  else
    result_str="return code=[$result],execute failed"
  fi
  #将历史命令缓冲区中命令写入历史命令文件
  history -a
  #获取当前登录用户
  local user=$(whoami)
  #获取当前登录用户的ID
  local user_id=$(id -ur $user)
  #打印登录的tty编号和登录IP，如果是远程登录服务器的情况下则会记录登录的IP
  local login=$(who -m | awk '{print $2" "$NF}')
  #从最后一条历史命令中读取命令和编号，其中读取的命令会被HISTTIMEFORMAT变量影响
  local msg=$(history 1 | { read x y; echo "$y"; })
  local num=$(history 1 | { read x y; echo "$x"; })
  #对历史命令进行判断，如果不判断就执行logger命令，不输入命令就按回车，也会记录上一条命令，如果再执行一条相同一命令，还是会被记录的
  if [ "${num}" != "${LastComandNum_for_history}" ] && [ "${LastComandNum_for_history}" != "" -o "${num}" == "1" ];then
    #设置日志级别，与其他日志级别不要冲突，方便通过rsyslog将日志写入新的日志文件中，默认记录在messages文件中
    logger -p local1.debug -t "[${SHELL}]" "[${msg}]" "${result_str}" "by [${user}(uid=$user_id)] from [$login]"
  fi
  LastComandNum_for_history=${num}
}
#hiscmd_readonly函数防止存在只读变量而导致意外情况
function hiscmd_readonly()
{
  local var="$1"
  local val="$2"
  local ret=$(readonly -p | grep -w "${var}" | awk -F "${var}=" '{print $NF}')
  if [ "${ret}" = "\"${val}\"" ]
  then
    return
  else
    export "${var}"="${val}"
    readonly "${var}"
  fi
}
#HISTCONTROL变量控制历史的记录方式，这里直接取消
export HISTCONTROL=''
hiscmd_readonly HISTTIMEFORMAT ""
#使用PROMPT_COMMAND环境变量记录用户操作日志
hiscmd_readonly PROMPT_COMMAND hiscmd
umask 0077
