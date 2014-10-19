var filename;
var mediainfo;
var script_path = '';

window.onload = function(){
	var  FileUploader = new Uploader("userfile","submit-form");
	FileUploader.set_action(document.getElementById('upload').getAttribute('action'));
	FileUploader.set_prevfile(FileUploader.getFileName());
	
	FileUploader.error_callback = function(){
	    var progress = document.getElementById('progress');
	    progress.innerHTML = 'Error: ' + FileUploader.response.error;
	}

	FileUploader.callback = function(){

		 var response = FileUploader.response;
		 var received;
		 var size;
		 var percentage;
		 var progress = document.getElementById('progress');
		 
		 if(response.state == "uploading"){
			received = response.received;
			size = response.size;
			
			percentage = Math.round(Number(response.received)/(Number(response.size)/100));

			var progress_line = '<div id="prog_c1"><div id="prog_c2" style="width:' + (percentage * 4) + 'px"></div></div>' + percentage + '%';

			progress.innerHTML = progress_line;
		 }
		 
		 if(response.state == "processing"){
		     progress.innerHTML = '<b>File has been uploaded and now is being processed: ' + response.progress + '% done</b>';
		 }
		 
		 if(response.state == "done"){
		 	document.getElementById('userfile').disabled = false;
		 	
		 	if(FileUploader.error_message == '' || typeof(FileUploader.error_message) == 'undefined')
		 	{
			    filename = FileUploader.patch_to_file;
            	mediainfo = FileUploader.patch_to_minfo;
				progress.innerHTML = 'You can take your file here : '+filename+' <br/> And mediainfo file from here : '+mediainfo;
			} else {
				progress.innerHTML = 'An error occurred: '+ FileUploader.error_message;
			}
		 }
	}
}

var Uploader = function (id,id2) {
	this.id = document.getElementById(id);
	this.id2 = document.getElementById(id2);
	var self = this;
	
	self.addEvent(this.id,"onchange",function (e){
		self.filechange();
	});
	self.addEvent(this.id2,"onclick",function (e){
		self.start(e,"");
	});
}

Uploader.prototype = {

	bWork : false,
	filename : "",
	oldfile : "",
	id : false,
	sid : false,
	callback: false,
	error_callback : false,
	response : "",
	logger : false,
	instanse : false,
	Request : false,
	patch_to_file : "",
	patch_to_minfo : "",
	error_message : "",
	patch_to_instance : "",
	patch_to_bucket : "",
	req : "",
	action : "",
	s3uploads : false,
	
	isWork : function () {
		return this.bWork;
	},
	set_instance : function(instance){
	
	 this.patch_to_instance = instance;
	
	},
	set_bucket : function(instance){
	
	 this.patch_to_bucket = instance;
	
	},
	set_prevfile : function(oldfile){
	
	 this.oldfile = oldfile;
	
	},
	set_action : function(action){
	
	 this.action = action;
	
	},
	 addEvent : function(el, evnt, func){
	   if (el.addEventListener) {                  
	        el.addEventListener(evnt.substr(2).toLowerCase(), func, false);
	   } else if (el.attachEvent) {
	      el.attachEvent(evnt.toLowerCase(), func);
	   } else {
	      el[evnt] = func;
	   }
	},

	CreateRequest : function(){
	
		 if (window.XMLHttpRequest){
			this.Request = new XMLHttpRequest();
		 }
		 else if (window.ActiveXObject) {

			 try{
				this.Request = new ActiveXObject("Microsoft.XMLHTTP");
			 } catch (CatchException) {
				this.Request = new ActiveXObject("Msxml2.XMLHTTP");
			 }
		 }
		 
		 if (!this.Request) {
			alert("Can`t create XMLHttpRequest");
		 }
	},
		
	SendRequest : function(r_method, r_path, r_args, r_handler){
		 var self = this;
		 this.CreateRequest();
		 if (!this.Request)
		 {
			return;
		 }
		 Request = this.Request;
			this.Request.onreadystatechange = function()
			{
				var self = this;
				if (Request.readyState == 4)
				{
					r_handler(Request);
				}
			}
		 
		 if (r_method.toLowerCase() == "get" && r_args.length > 0){
			r_path += "?" + r_args;
		 }

		 this.Request.open(r_method, r_path, true);
		 if (r_method.toLowerCase() == "post")
		 {
			this.Request.setRequestHeader("Content-Type","application/x-www-form-urlencoded; charset=utf-8");
			
			this.Request.send(r_args);
		 }
		 else
		 {
			this.Request.send(null);
		 }
	},
	getFileName : function () {
			var value = this.id.value;
			if (value.indexOf(':\\') == 1) {
				value = value.split(":").pop().split("\\").pop();
			}
			return value;
	},
	getLastPoint : function (value) {
		  var point = 0;
		  var slen = 0;
		  point = value.indexOf('.');

			while (value.indexOf('.') != -1) {
				point = value.indexOf('.')
				slen += point+1;
				value = value.substr(point+1); 
				
			}
 
			return slen;
	},	
	
	run : function () {                                                                        
	    var self = this;
	    var act = (self.s3uploads)?'&action=s3uploading&sid=' + self.sid:'';
		 this.SendRequest("GET",script_path + 'progress.php?X-Progress-ID=' + self.sid + act,"",
	        function(resp) { 
				try {
				    
				    if(resp.responseText == "")
				    {
					self.instanse = setTimeout(function(){self.run.call(self)}, 2000);
					return;
				    }
 
					var response = eval("("+resp.responseText+")");
					self.response = response;
					
					if (response.state == "error") {
						throw "Error " + response.error;
					}
					if (response.state == "starting") {
						instanse = setTimeout(function(){self.run.call(self)}, 2000);
					}
					else if(response.state == "done"){
					    
					   if(self.s3uploads)
					   {
						clearTimeout(self.instanse);
						self.finish();					
						self.bWork = false;
					   } else {
					        self.s3uploads = true;
						self.instanse = setTimeout(function(){self.run.call(self)}, 2000);
						self.response.state = "processing";
						self.response.progress = 0;
					   }
					}
					else{
						self.instanse = setTimeout(function(){self.run.call(self)}, 2000);
					}
					
					if (self.callback && (typeof(self.callback) == "function") && response.state != 'done') {
					    self.callback.call();
					}
				}
				catch (e) {
					if (self.error_callback && (typeof(self.error_callback) == "function")) {
					self.error_callback.call();
	          		}
				}
	        }
	   );
	},

	filechange : function () {
		  this.oldfile = this.filename;	
		  this.filename = this.getFileName();
	      this.bWork = true;
	      var self = this;

	      this.SendRequest("GET",script_path + 'signer.php',"", 
				function(resp) {
					resp = eval("("+resp.responseText+")");
					document.getElementById('sid').value = resp.sid;
					document.getElementById('uid').value = resp.uid;
					document.getElementById('timestamp').value = resp.timestamp;
					document.getElementById('signature').value = resp.signature;
					
					var form_action = document.forms.upload;
		  
					self.sid = document.getElementById('sid').value;
					form_action.setAttribute("action", self.action  + "?X-Progress-ID=" + document.getElementById('sid').value);
		  
document.getElementById('submit-form').disabled = false;
					
				}
		  );
	},

	finish : function (){
			var self = this;
			self.SendRequest("GET",script_path + 'progress.php?action=filename&X-Progress-ID=' + self.sid,"",
				function(resp) { 
					var response = eval("("+resp.responseText+")");
					self.patch_to_file = response.filename;
					self.patch_to_minfo =  response.mediainfo;
					self.error_message = response.error;
					self.s3uploads = false;
					if (self.callback && (typeof(self.callback) == "function")) {
	          			self.callback.call();
					}
				}
			);
	},
	
	start : function (callback, error) {
		  var self = this;
		  this.error = error;
		  if(document.forms['upload'].elements['userfile'].value == self.oldfile || document.forms['upload'].elements['userfile'].value == ''){
			return;
		  }
		  
		  document.forms.upload.submit();
		  document.getElementById('submit-form').disabled = true;
		  document.getElementById('userfile').disabled = true;
		  this.SendRequest("GET",script_path + 'progress.php?X-Progress-ID=' + self.sid,"", 
						function(resp) {
							resp = eval("("+resp.responseText+")");
			  				if (resp.state != 'error') { 
				  				self.run();
				  			} else {
								if (self.error_callback && (typeof(self.error_callback) == "function")) {
					
									self.error_callback.call();
								}
				  			}
				   }
		  );
	}
}