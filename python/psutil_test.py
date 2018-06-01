https://github.com/giampaolo/psutil
http://psutil.readthedocs.io/en/latest

 git clone https://github.com/giampaolo/psutil.git
 cd psutil
 python setup.py install

import psutil
// 获取CPU完整信息
psutil.cpu_times()
psutil.cpu_times().user
// 显示所有CPU信息
psutil.cpu_times(percpu = True)
// CPU逻辑个数
psutil.cpu_count()
// CPU物理个数
psutil.cpu_count(logical = False)
// 内存完整信息
mem = psutil.virtual_memory()
// 交换内存
psutil.swap_memory()
// 磁盘完整信息
psutil.disk_partitions()
// 分区使用情况
psutil.disk_usage('/')
// 磁盘总IO
psutil.disk_io_counters()
// 获取单个分区IO个数
psutil.disk_io_counters(perdisk = True)
// 获取网络总IO信息
psutil.net_io_counters()
psutil.net_io_counters(pernic = True)
// 当前登录用户信息
psutil.users()
// 开机时间
psutil.boot_time()
datetime.datetime.fromtimestamp(psutil.boot_time()).strftime("%Y-%m-%d %H:%M:%S")
// 列出所有进程PID
psutil.pids()
p = psutil.Process(10)
p.name() //进程名
p.exe() //进程bin名
p.cwd() //工作目录
p.status() //进程状态
p.create_time() //进程创建时间
p.uids() //进程uid信息
p.gids() //进程gid信息
p.cpu_times() //进程CPU时间信息
p.cpu_affinity() //进程CPU亲和度
p.memory_percent() //进程内存利用率
p.memory_info() //进程内存
p.io_counters() //进程IO
p.connections()
p.num_threads()

from subprocess import PIPE
p = psutil.Popen(["/usr/bin/python","-c","print('hello')"], stdout = PIPE)
p.name()
p.username()
p.communicate()
p.cpu_times()

Further process APIs

>>> import psutil
>>> for proc in psutil.process_iter(attrs=['pid', 'name']):
...     print(proc.info)
...
{'pid': 1, 'name': 'systemd'}
{'pid': 2, 'name': 'kthreadd'}
{'pid': 3, 'name': 'ksoftirqd/0'}
...
>>>
>>> psutil.pid_exists(3)
True
>>>
>>> def on_terminate(proc):
...     print("process {} terminated".format(proc))
...
>>> # waits for multiple processes to terminate
>>> gone, alive = psutil.wait_procs(procs_list, timeout=3, callback=on_terminate)
>>>

Windows services

>>> list(psutil.win_service_iter())
[<WindowsService(name='AeLookupSvc', display_name='Application Experience') at 38850096>,
 <WindowsService(name='ALG', display_name='Application Layer Gateway Service') at 38850128>,
 <WindowsService(name='APNMCP', display_name='Ask Update Service') at 38850160>,
 <WindowsService(name='AppIDSvc', display_name='Application Identity') at 38850192>,
 ...]
>>> s = psutil.win_service_get('alg')
>>> s.as_dict()
{'binpath': 'C:\\Windows\\System32\\alg.exe',
 'description': 'Provides support for 3rd party protocol plug-ins for Internet Connection Sharing',
 'display_name': 'Application Layer Gateway Service',
 'name': 'alg',
 'pid': None,
 'start_type': 'manual',
 'status': 'stopped',
 'username': 'NT AUTHORITY\\LocalService'}

