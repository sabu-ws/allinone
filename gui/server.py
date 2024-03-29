# -*- coding: utf-8 -*-
# --------------------Import module-------------------------
# module for flask running
from flask import Flask, jsonify, render_template, request, url_for , g , flash, redirect ,session ,send_file
from flask_socketio import SocketIO, emit
from werkzeug.utils import secure_filename
from eventlet import wsgi, wrap_ssl, spawn
import eventlet
import ssl
import socket

# module for good processing
import hashlib
import random
import string
import re
import subprocess
import os
from datetime import datetime
import time
from io import BytesIO
import zipfile
from functools import wraps
from urllib.parse import unquote
import json
import shutil

# master config
app = Flask(__name__)
socketio = SocketIO(app)

# APP Config
ROOT_PATH="/mnt/usb/"
SCRIPT_PATH = "/sabu/scripts"
CONFIG_PATH = "/sabu/config"
LOG_PATH = "/sabu/logs"
app.config['SECRET_KEY'] = ''.join(random.choices(string.ascii_letters + string.digits, k=30))
app.config['UPLOAD_FOLDER'] = ROOT_PATH

# Define variable
hasScan = False
first_con = True
nb_advanced_scan = 2
detectusb_g = False
is_scan=0
during_connection = False
pid = 0

# --------------------Wrapper function-------------------------

def login_required(f):
	@wraps(f)
	def decorated_function(*args, **kwargs):
		if g.log == False:
			return redirect(url_for('admin', next=request.url))
		return f(*args, **kwargs)
	return decorated_function

def detectUSB(f):
	@wraps(f)
	def decorated_function(*args, **kwargs):
		global detectusb_g
		global hasScan
		pattern = re.compile("sd[a-z]")
		dir = "/dev/"
		for filepath in os.listdir(dir):
			if pattern.match(filepath):
				g.detectusb = True
				detectusb_g = True
				return f(*args, **kwargs)
		hasScan = False
		g.detectusb = False
		detectusb_g = False
		return f(*args, **kwargs)
	return decorated_function

def ifscan(f):
	@wraps(f)
	def decorated_function(*args, **kwargs):
		global hasScan
		if hasScan == False:
			return redirect(url_for('scan_page'))
		return f(*args, **kwargs)
	return decorated_function

def first(f):
	@wraps(f)
	def decorated_function(*args, **kwargs):
		file = open("/sabu/gui/static/config.json")
		js = json.load(file)
		if "mdp" in js:
			if js["mdp"] == "":

				return redirect(url_for('first_connection'))
		global first_con
		first_con = False
		return f(*args, **kwargs)
	return decorated_function

# --------------------Minor function-------------------------
def sizeof_fmt(num, suffix="B"):
    for unit in ["", "Ki", "Mi", "Gi", "Ti", "Pi", "Ei", "Zi"]:
        if abs(num) < 1024.0:
            return f"{num:3.1f}{unit}{suffix}"
        num /= 1024.0
    return f"{num:.1f}Yi{suffix}"

# --------------------logging processing-------------------------
def logging(message):
	file = open("/sabu/logs/gui.log","a")
	date_format = datetime.now().strftime("[%Y-%m-%d %H:%M:%S]")
	prefetch = f"{date_format} [GUI] {message}\n"
	file.write(prefetch)
	file.close()



# --------------------Main page section-------------------------
@app.route("/")
@first
def index():
	return render_template("index.html")


# --------------------Scan section-------------------------
@app.route("/scan")
@first
def scan_page():
	return render_template("scan_index.html")

@app.route("/scan/simple")
@first
@detectUSB
def scan_simple():
	return render_template("scan_simple.html")

@socketio.on('simple_scan')
def rec():
	global detectusb_g
	if detectusb_g:
		logging("simple scan start")
		proc = subprocess.run(f"{SCRIPT_PATH}/scan/scan-clamav-detect.sh && sleep 1".split())
		global hasScan
		emit("simple_scan_end")
		hasScan = True
		emit("end")
		logging("simple scan end")

@app.route("/scan/advanced")
@first
@detectUSB
def scan_advanced():
	return render_template("scan_advanced.html")

@socketio.on('advanced_scan_clamav')
def rec():
	global detectusb_g
	if detectusb_g:
		logging("Advanced scan(clamav) start")
		proc = subprocess.run(f"{SCRIPT_PATH}/scan/scan-clamav-detect.sh && sleep 1".split())
		global hasScan
		global nb_advanced_scan
		global is_scan
		emit("advanced_scan_end","clamav")
		hasScan = True
		is_scan+=1
		if is_scan == nb_advanced_scan:
			logging("Advanced scan(clamav) end")
			is_scan = 0
			emit("end")


@socketio.on('advanced_scan_olefile')
def rec():
	global detectusb_g
	if detectusb_g:
		logging("Advanced scan(ole) start")
		proc = subprocess.run(f"{SCRIPT_PATH}/scan/scan-ole.sh && sleep 1".split())
		global is_scan
		global nb_advanced_scan
		emit("advanced_scan_end","olefile")
		is_scan+=1
		if is_scan == nb_advanced_scan:
			emit("end")
			is_scan = 0
			logging("Advanced scan(ole) end")

@app.route("/scan/result",methods=["POST","GET"])
@detectUSB
@ifscan
@first
def resultat():
	if request.method == "GET":
		resultat_scan = {}
		clam_av = [i[0][:-1] for i in [i.split() for i in open("/sabu/logs/scan/clamav/"+open("/sabu/logs/scan/clamav/last-scan.log").read().replace("\n","")).read().split("\n")] if len(i) > 0 if i[-1] == "FOUND" ]
		resultat_scan = {i:[["ClamAV",url_for("static",filename="assets/icons/clamav.ico")]] for i in clam_av}
		ole = []
		if open("/sabu/logs/scan/ole/last-scan.log").read().replace("\n","") != "":
			ole = [i.split()[0] for i in open("/sabu/logs/scan/ole/"+open("/sabu/logs/scan/ole/last-scan.log").read().replace("\n","")).readlines()]
		for i in ole:
			if i in resultat_scan:
				resultat_scan[i].append(["OLE Tools",url_for("static",filename="assets/icons/oletools.ico")])
			else:
				resultat_scan[i]=[["OLE Tools",url_for("static",filename="assets/icons/oletools.ico")]]
		fileResScan = [[i,resultat_scan[i]] for i in resultat_scan if os.path.isfile(i)]
		lenght = len(fileResScan)
		return render_template("result.html",files=fileResScan,lenght=lenght)
	elif request.method == "POST":
		if request.form["validate_res"] == "Delete":
			files = request.form.to_dict()
			del files["validate_res"]
			logging(f"{files}")
			for file in files.keys():
				file = json.loads(file.replace("'",'"'))[0]
				logging(f"{file}")
				if os.path.isfile(file):
					logging(f"[{file}] has been delete")
					os.remove(file)
		return redirect(url_for("resultat"))
	return redirect("/404")

# --------------------Format section-------------------------

@app.route("/format")
@first
def format():
	return render_template("format_index.html")

@app.route("/format/simple")
@first
@detectUSB
def format_simple():
	return render_template("format_simple.html")

@socketio.on('formating')
@detectUSB
def rec():
	global detectusb_g
	if detectusb_g:
		proc = subprocess.Popen(f"{SCRIPT_PATH}/format/format-standard.sh".split(),stdout=subprocess.PIPE)
		logging("standard format start")	
		while 1:
			poll = proc.poll()
			if poll is not None:
				logging("standard format end")	
				emit("end")
				break

@app.route("/format/advanced")
@first
@detectUSB
def format_advanced():
	return render_template("format_advanced.html")


@socketio.on('formating_advanced')
def rec():
	global detectusb_g
	if detectusb_g:
		proc = subprocess.Popen(f"{SCRIPT_PATH}/format/format-avanced.sh".split(),stdout=subprocess.PIPE)
		logging("standard format start")	
		while 1:
			poll = proc.poll()
			if poll is not None:
				emit("end")
				logging("standard format end")	
				break

# --------------------Browser section-------------------------

# Browser page
@app.route("/browser/<path:MasterListDir>")
@app.route("/browser/")
@app.route("/browser")
@first
def browser(MasterListDir=""):
	joining = os.path.join(ROOT_PATH,MasterListDir)
	logging(f"accessing to {joining}")
	cur_dir = "/"+MasterListDir
	if cur_dir=="/":
		cur_dir=""
	if os.path.isdir(joining):
		new_path = os.listdir(joining)
		list_items = [i for i in os.walk(joining)][0]
		items_dir=[]
		items_file=[]
		for i in list_items[1]:
			j=os.path.join(joining,i)
			creation_date = str(datetime.fromtimestamp(os.lstat(j).st_ctime)).split(".")[0]
			modification_date = str(datetime.fromtimestamp(os.lstat(j).st_mtime)).split(".")[0]
			size = sizeof_fmt(os.lstat(j).st_size)
			# make [nom_fichier,date_de_creation,date_modifer,taille_fichier]
			make = [i,creation_date,modification_date,size]
			items_dir.append(make)
		for i in list_items[2]:
			j=os.path.join(joining,i)
			creation_date = str(datetime.fromtimestamp(os.lstat(j).st_ctime)).split(".")[0]
			modification_date = str(datetime.fromtimestamp(os.lstat(j).st_mtime)).split(".")[0]
			size = sizeof_fmt(os.lstat(j).st_size)
			# make [nom_fichier,date_de_creation,date_modifer,taille_fichier]
			make = [i,creation_date,modification_date,size]
			items_file.append(make)
		return render_template("browser.html",items_file=items_file,items_dir=items_dir,cur_dir=cur_dir)
	return redirect("/browser")

# Donwload file page 
@app.route("/download/<path:MasterListDir>")
@first
@ifscan
@detectUSB
def download(MasterListDir=""):
	if g.detectusb:
		path=ROOT_PATH+"/"+MasterListDir
		master_path="/".join(path.split("/")[:-1])
		last=MasterListDir.split("/")[-1]
		os.chdir(master_path)
		if os.path.exists(path):
			if os.path.isdir(path):
				timestr = time.strftime("%Y%m%d-%H%M%S")
				fileName = f"{last}_{timestr}.zip".format(timestr)
				memory_file = BytesIO()
				with zipfile.ZipFile(memory_file, 'w', zipfile.ZIP_DEFLATED) as zipf:
					for root, dirs, files in os.walk(last):
						for file in files:
							zipf.write(os.path.join(root, file))
				memory_file.seek(0)
				logging(f"downloading folder of [{path}]")
				return send_file(memory_file,as_attachment=True,mimetype="application/zip",download_name=fileName)
			elif os.path.isfile(path): 
				logging(f"downloading file of [{path}]")
				return send_file(path,as_attachment=True)
		else:
			return redirect("/404")

# Delete file 
@app.route("/delete/<path:MasterListDir>")
@first
@detectUSB
def delete(MasterListDir=""):
	if g.detectusb:
		path=os.path.join(ROOT_PATH,MasterListDir)
		master_path="/".join(path.split("/")[:-1])
		last=MasterListDir.split("/")[-1]
		to_return = request.referrer
		os.chdir(master_path)
		if os.path.exists(path):
			if os.path.isdir(path):
				for root, dirs, files in os.walk(last, topdown=False):
					for name in files:
						os.remove(os.path.join(root, name))
					for name in dirs:
						os.rmdir(os.path.join(root, name))
				os.rmdir(last)
				logging(f"deleting folder of [{path}]")
				return redirect(to_return)
			elif os.path.isfile(path):
				os.remove(last) 
				logging(f"deleting file of [{path}]")
				return redirect(to_return)
		else:
			return redirect("/404")
	else:
		return redirect("/")

# get info of file with exiftool
@app.route("/info/<path:MasterListDir>")
@first
@detectUSB
def info(MasterListDir=""):
	if g.detectusb:
		path=ROOT_PATH+MasterListDir
		path = os.path.join(ROOT_PATH+MasterListDir)
		path = unquote(path)
		sub = subprocess.Popen(["exiftool",path],stdout=subprocess.PIPE).communicate()[0].decode().split("\n")
		logging(f"get info of [{path}]")
		return render_template("sh_file.html",info=sub)
	else:
		return redirect("/")

# Upload file securly on server
@app.route("/upload",methods=['POST'])
@first
@detectUSB
def upload():
	if g.detectusb:
		p = request.form["linkd"]
		logging(f"{p}")
		last = "/".join(request.form["linkd"].split("/")[2:])
		master_path = os.path.join(ROOT_PATH,last)
		master_path = unquote(master_path)
		if os.path.exists(master_path):
			if request.method == "POST" and "up_f" in request.files and request.files['up_d'].filename == "":
				if "up_f" not in request.files:
					flash('No file part')
					return redirect(url_for("browser"))
				file = request.files['up_f']
				if file.filename == '':
					flash('No selected file')
					return redirect(url_for("browser"))
				if file:
					filename = secure_filename(file.filename)
					file.save(os.path.join(master_path, filename))
					logging(f"file [{master_path}] is upload")
					return redirect(url_for("browser"))
			if request.method == "POST" and "up_d" in request.files and request.files['up_f'].filename == "":
				if "up_d" not in request.files:
					return 'No folder part'
				file = request.files['up_d']
				if file.filename == '':
					return 'No selected file'
				if file:
					filename = secure_filename(file.filename)
					path = os.path.join(master_path, filename)
					file.save(path)
					try:
						the_zip_file = zipfile.ZipFile(path)
						ret = the_zip_file.testzip()
						if ret == None:
							the_zip_file.extractall(master_path)
							os.remove(path)
							logging(f"folder [{path}] is upload")
							return redirect(url_for("browser"))
					except:
						flash("Error file")
						os.remove(path)
						return redirect(url_for("browser"))
						
			return ""
		else:
			return redirect(url_for("browser"))
	else:
		return redirect("/")

# --------------------Admin Section-------------------------

# logging admin page
@app.route("/admin",methods=('GET','POST'))
@first
def admin():
	if session.get('loggedin') == True:
		return redirect(url_for("admin_dashbord"))
	if request.method=="POST" and "mdp" in request.form:
		file=open("/sabu/gui/static/config.json","r")
		js = json.load(file)
		mdp=js['mdp']
		req=request.form['mdp']
		encrypt=hashlib.sha512(req.encode()).hexdigest()
		if encrypt == mdp:
			session['loggedin'] = True
			logging("admin has logged")
			return redirect(url_for('admin_dashbord'))
		else:
			flash("Bad password")
			logging(f"someone try admin password : {req}")
			return redirect(url_for('admin'))
	return render_template("login.html")

@app.route("/admin/reboot")
@first
@login_required
def admin_reboot():
	subprocess.run("sudo reboot".split())
	return ""

# download logs page
@app.route("/admin/download_logs")
@first
@login_required
def admin_downloadLogs():
	if session.get("loggedin") == True:
		last = "/sabu/logs/"
		timestr = time.strftime("%Y%m%d-%H%M%S")
		fileName = f"logs_{timestr}.zip"
		memory_file = BytesIO()
		with zipfile.ZipFile(memory_file, 'w', zipfile.ZIP_DEFLATED) as zipf:
			for root, dirs, files in os.walk(last):
				for file in files:
					zipf.write(os.path.join(root, file))
		memory_file.seek(0)
		logging("admin downloading log")
		return send_file(memory_file,as_attachment=True,mimetype="application/zip",download_name=fileName)
	return redirect("/404")

# @socketio.on("dash_up")


@app.route("/admin/dashboard",methods=['GET'])
@first
@login_required
def admin_dashbord():
	if session.get("loggedin") == True:
		info_system = subprocess.Popen(f"{SCRIPT_PATH}/system/system_info.sh".split(),stdout=subprocess.PIPE).communicate()[0].decode().split("\n")
		uptime = info_system[3]
		date_translate = datetime.fromisoformat(uptime)
		date_now = datetime.now()
		hour_minute = date_now - date_translate
		hour_minute = datetime.strptime(str(hour_minute),"%H:%M:%S.%f").strftime("%H hours, %M minutes, %S secondes")
		uptime=f"{hour_minute}"
		info={
			"hostname":info_system[0],
			"systemtime":info_system[1],
			"timezone":info_system[2],
			"uptime":uptime,
			"disk":info_system[4],
		}
		return render_template("admin_dashboard.html",info=info)
	else:
		return redirect(url_for("/admin"))
	return "toto"


# connfig device, network ... page
@app.route("/admin/global",methods=['GET', 'POST'])
@first
@login_required
def admin_global():
	if session.get('loggedin') == True:
		info_system = subprocess.Popen(f"{SCRIPT_PATH}/system/system_info.sh".split(),stdout=subprocess.PIPE).communicate()[0].decode().split("\n")
		get_hostname = subprocess.Popen("hostname".split(),stdout=subprocess.PIPE).communicate()[0].decode()
		if request.method=="POST":
			if "password" in request.form and "hostname" in request.form:
				good_password=""
				good_hostname=""
				if request.form["password"] != "":
					# change password
					# Min 12 char, 1 number, 1 uppercase, 1 lowercase,1 spécial char
					must_match_pwd = r"^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[\*\.!@$%^\&\(\)\{\}\[\]:;<>,\.\?\/~_\+-=\|]).{12,}$"
					if re.search(must_match_pwd, request.form["password"]):
						file_r=open("static/config.json","r")
						js = json.load(file_r)
						file_r.close()
						file_w=open("static/config.json","w")
						mdp=request.form['password']
						encrypt=hashlib.sha512(mdp.encode()).hexdigest()
						js['mdp']=encrypt
						json.dump(js, file_w)
						good_password = "Password was change"
						logging("admin has change password")
					else:
						flash("Bad padding password")
						logging(f"admin try tro change password [{request.form.to_dict()}]")
				if request.form["hostname"] != "":
					# change hostname
					# between 3 and 20 char,min 
					must_match_hostname = r"^[a-zA-Z0-9-]{3,20}$"
					if re.search(must_match_hostname,request.form["hostname"]):
						hostname = request.form["hostname"]
						old_hostname = socket.gethostname()
						subprocess.run(f"sudo hostnamectl set-hostname {hostname}".split())
						subprocess.run(f"/sabu/scripts/network/network-hostname.sh {old_hostname}".split())
						good_hostname = "The hostname will change at next reboot"
						logging(f"admin has change hostname to {str(hostname)}")
					else:
						logging(f"admin try tro change hostname [{request.form.to_dict()}]")
						flash("Bad padding hostname")

				if good_password !="" and good_hostname!="":
					flash("All informations was change")
				elif good_hostname!="" :
					logging(good_hostname)
					flash(good_hostname)
				elif good_password!="":
					flash(good_password)
				else:
					flash("ERROR !!!")

				return redirect(url_for("admin_global"))
			else:
				g.log = 0
				return redirect(url_for("index"))
		elif request.method=="GET":
			hostname = info_system[0]
		else:
			return redirect("/404")
		return render_template("admin_global_settings.html",hostname=hostname)
	else:
		return redirect(url_for('admin_config'))

# network
@app.route("/admin/network",methods=['GET', 'POST'])
@first
@login_required
def admin_network():
	if session.get('loggedin') == True:
		info_ip = subprocess.Popen(f"{SCRIPT_PATH}/network/network-read.sh".split(),stdout=subprocess.PIPE).communicate()[0].decode().split("\n")
		must_match_ip = r"^((25[0-5]|(2[0-4]|1[0-9]|[1-9]|)[0-9])(\.(?!$)|$)){4}$"
		if request.method=="POST":
			must_match_ip = r"^((25[0-5]|(2[0-4]|1[0-9]|[1-9]|)[0-9])(\.(?!$)|$)){4}$"
			if "interface" in request.form and "ip" in request.form and "netmask" in request.form and "gateway" in request.form and "dns1" in request.form:
				if request.form["dns2"] != "":
					dns2 = request.form["dns2"]
				else:
					dns2 = "9.9.9.9"
				if re.search(must_match_ip, request.form["ip"]) and re.search(must_match_ip, request.form["netmask"]) and re.search(must_match_ip, request.form["gateway"]) and re.search(must_match_ip, request.form["dns1"]) and re.search(must_match_ip, dns2):
					interface = request.form["interface"]
					ip = request.form["ip"]
					netmask = request.form["netmask"]
					gateway = request.form["gateway"]
					dns1 = request.form["dns1"]
					dico_network = {"interface": interface, "ip": ip, "netmask": netmask, "gateway": gateway, "dns1": dns1, "dns2": dns2}
					dico_category_network = {"network": dico_network}
					json_config = open(CONFIG_PATH+"/config.json", "w")
					json.dump(dico_category_network, json_config)
					subprocess.Popen(f"{SCRIPT_PATH}/network/network-config.sh".split())
					flash("The network was configure !")
					logging(f"admin has change network config [{dico_network}]")
					return redirect(url_for("admin_network"))
				else:
					logging(f"admin try tro change network [{request.form.to_dict()}]")
					flash("Some informations was incorrect")
					return redirect(url_for("admin_network"))
		elif request.method=="GET":
			info = {"interface":info_ip[0],
					"ip":info_ip[1],
					"netmask":info_ip[2],
					"gateway":info_ip[3],
					"dns1":info_ip[4],
					"dns2":info_ip[5],
					}	
		else:
			return redirect("/404")
		return render_template("admin_network_settings.html",info=info)
	else:
		return redirect(url_for('admin_network'))


# global
@app.route("/admin/certif",methods=["GET","POST"])
@first
@login_required
def admin_certif():
	if session.get('loggedin') == True:
		if request.method == "POST":
			if "filepub" not in request.files or "filepriv" not in request.files:
				flash('No file part')
				return redirect(url_for("admin_certif"))
			file_priv = request.files['filepriv']
			file_pub = request.files['filepub']
			if file_priv.filename == '' or file_pub.filename == '':
				flash('No selected file')
				return redirect(url_for("admin_certif"))
			if file_priv.mimetype == "application/octet-stream" and file_pub.mimetype == "application/x-x509-ca-cert" and file_pub.filename[-4:] == ".crt" and file_priv.filename[-4:] == ".key" :
				shutil.move("/sabu/nginx/certificates/sabu-gui.crt", "/sabu/nginx/certificates/sabu-gui.crt.old")				
				shutil.move("/sabu/nginx/certificates/sabu-gui.key", "/sabu/nginx/certificates/sabu-gui.key.old")
				path = "/sabu/nginx/certificates"
				file_pub.save(os.path.join(path, "sabu-gui.crt"))
				file_priv.save(os.path.join(path, "sabu-gui.key"))
				os.popen("sleep 5 && sudo systemctl restart nginx && sleep 3 && sudo systemctl restart sabu")
				flash("Certificate was change")
				return redirect(url_for("admin_certif"))
			else:
				flash('Bad file')
				return redirect(url_for("admin_certif"))
		return render_template("admin_certificate_settings.html")
	else:
		return redirect(url_for("admin"))
	return redirect("/404")

# setup page
@app.route("/setup",methods=["POST","GET"])
def first_connection():
	global first_con
	if first_con == True:
		info_ip = subprocess.Popen(f"{SCRIPT_PATH}/network/network-read.sh".split(),stdout=subprocess.PIPE).communicate()[0].decode().split("\n")
		if request.method=="GET":
			interface=info_ip[0]

		elif request.method=="POST":
			if ("interface" in request.form and "ip" in request.form and "netmask" in request.form and "gateway" in request.form and "dns1" in request.form and "password" in request.form):
				
				# regex for good ip
				must_match_ip = r"^((25[0-5]|(2[0-4]|1[0-9]|[1-9]|)[0-9])(\.(?!$)|$)){4}$"

				# Min 12 char, 1 number, 1 uppercase, 1 lowercase,1 spécial char
				must_match_pwd = r"^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[\*\.!@$%^\&\(\)\{\}\[\]:;<>,\.\?\/~_\+-=\|]).{12,}$"
 
				if request.form["dns2"] != "":
					dns2 = request.form["dns2"]
				else:
					dns2 = "9.9.9.9"
				if re.search(must_match_ip, request.form["ip"]) and re.search(must_match_ip, request.form["netmask"]) and re.search(must_match_ip, request.form["gateway"]) and re.search(must_match_ip, request.form["dns1"]) and re.search(must_match_ip, dns2) and re.search(must_match_pwd, request.form["password"]):
					interface = request.form["interface"]
					ip = request.form["ip"]
					netmask = request.form["netmask"]
					gateway = request.form["gateway"]
					dns1 = request.form["dns1"]
					mdp=request.form["password"]

					# network
					dico_network = {"interface": interface, "ip": ip, "netmask": netmask, "gateway": gateway, "dns1": dns1, "dns2": dns2}
					dico_category_network = {"network": dico_network}
					json_config = open(CONFIG_PATH+"/config.json", "w")
					json.dump(dico_category_network, json_config)
					subprocess.Popen(f"{SCRIPT_PATH}/network/network-config-setup.sh".split())

					# Password
					file_r = open("static/config.json","r")
					js = json.load(file_r)
					file_r.close()
					file_w=open("static/config.json","w")
					encrypt=hashlib.sha512(mdp.encode()).hexdigest()
					js['mdp']=encrypt
					json.dump(js, file_w)
					file_w.close()
					json_config.close()
					logging(request.form)
					subprocess.run("/sabu/config/install.sh")
					return redirect(url_for("first_connection"))
				else:
					flash("Some informations was incorrect")
					return redirect(url_for("first_connection"))
			else:
				flash("Some informations missing !") 
				return redirect(url_for("first_connection"))
		else:
			return redirect("/404")
		return render_template("setup.html",interface=interface)
	elif first_con == False:
		return redirect("/")
	else:
		return redirect("/404")

	return redirect("/404")

# logout page
@app.route("/logout")
@first
@login_required
def logout():
	session["loggedin"]=False
	logging("admin was log out")
	return redirect(url_for('index'))

# detect before each request if someone is logged
@app.before_request
def load_logged_in_user():
	global hasScan
	user_id = session.get('loggedin')
	if hasScan == False:
		g.hasScan = False
	else:
		g.hasScan = True
	if user_id != True:
		g.log = False
	else:
		g.log = True


# Error when receive 404 error
@app.errorhandler(404)
def page_not_found(error):
	logging(f"someone access {request.url}")
	return render_template("error/404.html")


# Start application with tls
if __name__ == '__main__':
	eventlet.monkey_patch()
	certfile = "/sabu/nginx/certificates/sabu-gui.crt"
	keyfile = "/sabu/nginx/certificates/sabu-gui.key"
	ssl_context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
	ssl_context.load_cert_chain(certfile, keyfile)
	# --------------------Start of sabu-------------------------
	logging("GUI of SABU is start")
	wsgi.server(
		eventlet.wrap_ssl(
			eventlet.listen(('127.0.0.1', 8888)),
				certfile=certfile,
				keyfile=keyfile,
				server_side=True),
	app)
