#/bin/python

import xml.dom.minidom
import subprocess
import os
import string
import sys

if len(sys.argv) > 1:
    initRepos = string.atoi(sys.argv[1])
else:
    initRepos = 0

gitosisConfig = "./gitosis_path"
absPath = "/home1/zhangheting/Qcom_Code/P100/"
defaultXML = "./default.xml"
gitosisPerfix = "@lenx_sdm450_p100f_sw1 = "
gitoSisSubfix = "\n"
remoteTopDirectory = "LENX_SDM450_P100F_SW1/"


doc = xml.dom.minidom.Document()
dom = xml.dom.minidom.parse(defaultXML)
root = dom.documentElement

print root.nodeName
remote = {}
reposString = gitosisPerfix + remoteTopDirectory + "tools/manifest\n"


remoteNode = root.getElementsByTagName("remote")[0]
remote["name"] = remoteNode.getAttribute("name")
remote["fetch"] = remoteNode.getAttribute("fetch")

projects = root.getElementsByTagName("project")
currPath = os.getcwd()

for project in projects:
    name = project.getAttribute("name")
    path = project.getAttribute("path")

    if os.path.exists(absPath + path):
#        print absPath + path
        #get all repositories for gitosis-admin.conf
        reposString += gitosisPerfix + name + gitoSisSubfix

        if initRepos == 1:
            os.chdir(absPath + path)    
            p = subprocess.Popen([currPath + "/test.sh",absPath + path,remote["fetch"] + name + ".git"],stdin = subprocess.PIPE,\
                stdout = subprocess.PIPE, stderr = subprocess.PIPE, shell = False);
            print p.stdout.read()
            print p.stderr.read()
            os.chdir(currPath)
    else:
        print "path:" + absPath + path  +" is not exists!"



outPut = open(gitosisConfig,"w")
outPut.write(reposString)
outPut.close()
