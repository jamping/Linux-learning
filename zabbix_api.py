#!/usr/bin/env python
#jjp
#version 1.3
from pyzabbix import ZabbixAPI
import json
import os,sys
import re,time
import logging
rule = json.load(file('./rolerule.json'))    #template 文件
def login():
        zapi= ZabbixAPI("http://192.168.0.119")                                          #登录zabbix
        zapi.login("Admin","zabbix")
        return zapi
def get_hostgroups(group_name):
        return zapi.hostgroup.get(search={"name":group_name },output="extend")        #搜索输入的组别，提取组id
def get_hosts(groupid):
        groupids = [groupid]
        return zapi.host.get(groupids=groupids,output="extend")                       #返回该组id 下的所有host 信息
def get_drules():
        return zapi.drule.get(output="extend")
def get_templates_by_names(template_names):
        return zapi.template.get(filter={"host": template_names})
def create_group(group_name):                                                         #创建组
    if not zapi.hostgroup.exists(name=group_name):
        zapi.hostgroup.create(name=group_name)
def create_host(group_name,host_name,ip):                                             #创建主机并附加指定模板
    groups=get_hostgroups(group_name)
    host_name=host_name.lower()
    ip_tail=ip.split(".")[-1]
    domain = "server-"+ ip_tail +".0." + host_name + ".ustack.in"
    for hostgroup in groups:
        groupid=hostgroup['groupid']
        ip_tail=ip.split(".")[-1]
        role = None
        for ru in rule:
            range = rule[ru]['range']
            if "-" in range:
                head = range.split("-")[0]
                tail = range.split("-")[1]
                if int(ip_tail) <= int(tail) and int(ip_tail) >=int(head):
                    role = ru
            else:
                if ip_tail == range:
                    role = ru
        template_names = rule[role]['templates']
        template_ids = get_templates_by_names(template_names)
        print domain,ip,groupid,template_ids
        zapi.host.create(host=domain,interfaces=[{
            "type":1,
            "main":1,
            "useip":1,
            "ip":ip,
            "dns":"",
            "port":'10050'
        }],groups=[{"groupid":groupid}],templates=template_ids)
        print  "Add Successfull!!!!!"
        #logging.info("%s,%s,%s,%s Add Successfull!!!!!"%(domain,ip,groupid,template_ids))
def create_macro(group_name,traffic,value):                                           #创建macro，不同主机有不同的macro
    groups=get_hostgroups(group_name)
    for group in groups:
        hosts=get_hosts(group['groupid'])
        for host in hosts:
            hostname=host["name"]
            hostid=host["hostid"]
            if not re.search("^server",hostname):continue
            m=re.search("[0-9]+",hostname).group()
            if m == "1":continue
            if m in ['64','65','66','67']:
                zapi.host.update(hostid=hostid,macros=[{"macro":"{$INP}","value":"35000"},
                                                  {"macro":"{$OUP}","value":"35000"},
                                                  {"macro":"{$INT}","value":"%s"%traffic},
                                                  {"macro":"{$OUT}","value":"%s"%traffic},
                                                  {"macro":"{$PDISK}","value":"%s"%value}])
            else:
                zapi.host.update(hostid=hostid,macros=[{"macro":"{$PDISK}","value":"%s"%value}])
            print hostname ,hostid,m,traffic,value
if __name__ == "__main__":
    zapi=login()
    region="qn"
    host_list=["31","32","35","36","39","40","44","45","46","47","48","49","50","53","54","61","62","63","64","65",
               "68","69","70","71","72","73","74","75","76","77","79","80","81","82","83","84","85","86","87","88","89","90","91"]       #添加主机，不建议用discovery
    ip_list=host_list
    if type(ip_list) == str:
        print "%s Must be a list,please checking !!!"%sys.argv[2]
        sys.exit()
    group_name="Region [%s 0]"% region.upper()
    if not zapi.hostgroup.exists(name=group_name):
       create_group(group_name)
    ip={"qn":"10.4.0."}
    if region in ip:
        for num in ip_list:
            value="20"
            traffic="300M"
            ipaddress=ip[region]+str(num)
            print group_name,region,ipaddress
            create_host(group_name,region,ipaddress)                                  #传参至函数
            time.sleep(5)
            create_macro(group_name,traffic,value)
    else:
        print "you input region error,please checking"