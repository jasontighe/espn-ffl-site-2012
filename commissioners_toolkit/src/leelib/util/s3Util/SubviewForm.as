package foreverRunway.uploadView
{
	import com.adobe.serialization.json.JSON;
	import com.greensock.TweenLite;
	import com.greensock.easing.Cubic;
	
	import fl.controls.CheckBox;
	
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TextEvent;
	import flash.external.ExternalInterface;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLVariables;
	import flash.system.Capabilities;
	import flash.text.TextField;
	
	import foreverRunway.FormInput;
	import foreverRunway.Global;
	import foreverRunway.YellowButton;
	
	import leelib.ui.Button;
	import leelib.ui.Component;
	import leelib.util.Guid;
	import leelib.util.Service;
	import leelib.util.StringUtil;
	import leelib.util.TextFieldUtil;
	import leelib.util.UploadUtil;
	import leelib.util.s3Util.S3PostOptions;
	import leelib.util.s3Util.S3PostRequest;
	import leelib.util.s3Util.S3Util;
	
	
	public class SubviewForm extends Component
	{
		private var _inpFirst:FormInput;
		private var _inpLast:FormInput;
		private var _inpPhone:FormInput;
		private var _inpEmail:FormInput;
		private var _inpAge:FormInput;
		private var _inpLocation:FormInput;

		private var _btnSubmit:Button;
		private var _btnBack:Button;
		
		private var _ckb:CheckBox;
		private var _tfError:TextField;
		
		//
		
		private var _tfUploadingMessage:TextField;
		private var _bar:ProgressBar;
		
		//
		
		private var _g:Global;
		
		private var _fileReference:FileReference;
		private var _s3Post:S3PostRequest;
		private var _service:Service;
		
		private var _tfMacFlash:TextField;

		
		public function SubviewForm()
		{
			_g = Global.getInstance();
			var tf:TextField;
			var col1:Number = 18;
			var col2:Number = 154;
			var marginR:Number = 334;
			var y:Number = 22;

			//
			
			tf = TextFieldUtil.createText(_g.getString("formHeading2"), ".title");
			tf.x = col1;
			tf.y = y;
			this.addChild(tf);
			
			tf = TextFieldUtil.createText(_g.getString("formHeading2b"), ".upload1FinePrint");
			tf.x = marginR - tf.textWidth;
			tf.y = y + 1;
			this.addChild(tf);
			
			y += 26;

			_inpFirst = new FormInput(124, _g.getString("formFirst"), 50);
			_inpFirst.x = col1;
			_inpFirst.y = y;
			this.addChild(_inpFirst);
			
			_inpLast = new FormInput(181, _g.getString("formLast"), 50);
			_inpLast.x = col2;
			_inpLast.y = y;
			this.addChild(_inpLast);
			
			y += _inpLast.height + 7;
			
			_inpPhone = new FormInput(124, _g.getString("formPhone"), 50);
			_inpPhone.x = col1;
			_inpPhone.y = y;
			this.addChild(_inpPhone);
			
			_inpEmail = new FormInput(181, _g.getString("formEmail"), 100);
			_inpEmail.x = col2;
			_inpEmail.y = y;
			this.addChild(_inpEmail);
			
			y += _inpEmail.height + 7;
			
			_inpAge = new FormInput(124, _g.getString("formAge"), 3);
			_inpAge.x = col1;
			_inpAge.y = y;
			_inpAge.textInput.restrict = "0-9";
			this.addChild(_inpAge);
			
			_inpLocation = new FormInput(181, _g.getString("formLocation"), 75);
			_inpLocation.x = col2;
			_inpLocation.y = y;
			this.addChild(_inpLocation);
			
			y += _inpLocation.height + 8;
			
			_ckb = new CheckBox();
			_ckb.x = col1;
			_ckb.y = y;
			_ckb.label = "";
			this.addChild(_ckb);

			tf = TextFieldUtil.createText(_g.getString("formAgree"), ".upload1Fineprint");
			tf.x = _ckb.x + 25;
			tf.y = y + 3;
			tf.mouseEnabled = true;
			tf.addEventListener(TextEvent.LINK, onAgreeLink);
			this.addChild(tf);
			
			y += 35;
			
			//
			
			tf = TextFieldUtil.createText(_g.getString("formHeading1"), ".title");
			tf.x = col1;
			tf.y = y;
			this.addChild(tf);
			
			y += 20;
			
			_tfUploadingMessage = TextFieldUtil.createText("", ".upload1Fineprint");
			_tfUploadingMessage.x = col1;
			_tfUploadingMessage.y = y;
			this.addChild(_tfUploadingMessage);
			
			y += 23;
			
			_bar = new ProgressBar();
			_bar.x = col1;
			_bar.y = y;
			this.addChild(_bar);
			
			y += 30;
			
			//
			
			_btnSubmit = new YellowButton(_g.getString("formSubmit"), 143);
			_btnSubmit.initialize();
			_btnSubmit.x = 334 - _btnSubmit.width;
			_btnSubmit.y = y;
			_btnSubmit.addEventListener(Event.SELECT, onButtonSubmit);
			this.addChild(_btnSubmit);
			
			_btnBack = new YellowButton(_g.getString("formBack"), 62);
			_btnBack.initialize();
			_btnBack.x = col1;
			_btnBack.y = y;
			_btnBack.addEventListener(Event.SELECT, onButtonBack);
			this.addChild(_btnBack);
			
			_tfError = TextFieldUtil.createHTMLText("", 105,45, ".upload1FineprintRed");
			_tfError.x = _btnSubmit.x - 5 - _tfError.width;
			_tfError.y = y + 5;
			this.addChild(_tfError);
			
			// ***

			if (flash.system.Capabilities.manufacturer.toLowerCase().indexOf("mac") > -1)
			{
				SubviewForm.t("MAC");
				var s:String = Global.getInstance().getString("macWarning");
				_tfMacFlash = TextFieldUtil.createText(s, ".upload1Fineprint");
				_tfMacFlash.x = 332 - _tfMacFlash.textWidth;
				_tfMacFlash.y = y + 42;
				this.addChild(_tfMacFlash);
			}
			
			
		}
		
		public override function show():void
		{
			this.visible = true;
			this.alpha = 0;
			TweenLite.killTweensOf(this);
			TweenLite.to(this, 0.3, { alpha:1, ease:Cubic.easeIn } );

			reset();
			
			this.dispatchEvent(new Event(ForeverRunwayWeb.EVENT_SHOWHEADERNOBUTTON, true));
		}

		public override function hide():void
		{
			this.visible = false;
		}
		
		public function reset():void
		{
			var a:Array = [ _inpFirst, _inpLast, _inpPhone, _inpEmail, _inpAge, _inpLocation ];
			for each (var inp:FormInput in a)
			{
				inp.textInput.text = StringUtil.trim(inp.textInput.text); // (retain text, i guess)
				inp.isError = false;
			}
			_tfError.htmlText = "";
			_ckb.selected = false;
			_tfUploadingMessage.htmlText = "";
			_bar.value = 0;
			

			// DEBUG
			if (Global.DEBUG) {
				_inpFirst.textInput.text = "first1";
				_inpLast.textInput.text = "last1";
				_inpPhone.textInput.text = "phone1";
				_inpEmail.textInput.text = "email1@email.com";
				_inpAge.textInput.text = "99";
				_inpLocation.textInput.text = "location1";
				_ckb.selected = true;
			}
		}
		
		private function validate():Boolean
		{
			var a:Array = [ _inpFirst, _inpLast, _inpPhone, _inpEmail, _inpAge, _inpLocation ];
			for each (var inp:FormInput in a)
			{
				inp.textInput.text = StringUtil.trim(inp.textInput.text);
				inp.isError = false;
			}
			_tfError.htmlText = "";
			
			//
			
			var isValid:Boolean = true;
			
			if (! _ckb.selected) {
				isValid = false;
				_tfError.htmlText = Global.getInstance().getString("formErrorCheckbox");
			}

			if (_inpFirst.textInput.length == 0) {
				_inpFirst.isError = true;
				isValid = false;
			}
			if (_inpLast.textInput.length == 0) {
				_inpLast.isError = true;
				isValid = false;
			}
			if (_inpPhone.textInput.length == 0) {
				_inpPhone.isError = true;
				isValid = false;
			}
			if (! StringUtil.isValidEmail(_inpEmail.textInput.text)) {
				_inpEmail.isError = true;
				isValid = false;
				_tfError.htmlText = Global.getInstance().getString("formErrorEmail");
			}
			if (_inpLocation.textInput.length == 0) {
				_inpLocation.isError = true;
				isValid = false;
			}
			if (_inpAge.textInput.length == 0) {
				_inpAge.isError = true;
				isValid = false;
			}
			
			return isValid;
		}

		private function onButtonBack(e:*):void
		{
			this.dispatchEvent(new Event(UploadView.EVENT_SHOW_SUBVIEW1));
		}
		
		private function onButtonSubmit(e:*):void
		{
			if (! validate()) return;

			var ff:FileFilter = new FileFilter("Video " + "(" + Global.getInstance().getString("validUploadSuffixes") + ")", Global.getInstance().getString("validUploadSuffixes"));
			
			_fileReference = new FileReference(); 
			_fileReference.addEventListener(Event.CANCEL, onFileReferenceCancel);
			_fileReference.addEventListener(Event.SELECT, onFileReferenceSelect);
			_fileReference.browse([ff]);
		}
		
		private function onFileReferenceCancel(e:*):void
		{
			trace('cancel');
			clearReferences();
		}
		
		private function onFileReferenceSelect(e:*):void
		{
			trace('selected');
			
			if (_fileReference.size > 3*1024*1024) 
			{
				_tfUploadingMessage.htmlText = "<span class='upload1FinePrintRed'>" + _g.getString("formErrorTooBig") + "</span>";
				clearReferences();
				return;
			}
			
			//
			
			_tfUploadingMessage.htmlText = "<span class='upload1FinePrint'>" + _g.getString("uploadingYourVideo") + "</span>";
			
			// Prod:
			S3Util.accessKey = "AKIAJ7NHA22KT5OPBBVA";
			S3Util.secretKey = "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";

			// make key
			var keyName:String = new Date().getTime().toString() + "_" + Guid.create(true);
			var s3u:S3Util = new S3Util();
			var o:Object = s3u.generatePolicy(_g.getString("s3BucketName"), keyName);
			var policy:String = o.policy;
			var signature:String = o.signature;

			// rem, these vals must match up with what was used to generate the policy
			var options:S3PostOptions = new S3PostOptions();
			options.secure = false; // (no https)
			options.acl = "public-read";
			options.contentType = "application/octet-stream";
			options.policy = policy;
			options.signature = signature;			
			
			//

			_s3Post = new S3PostRequest(S3Util.accessKey, _g.getString("s3BucketName"), keyName, options);
			_s3Post.addEventListener(IOErrorEvent.IO_ERROR, onS3PostIoError);
			_s3Post.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onS3PostSecurityError);
			_s3Post.addEventListener(Event.OPEN, onS3PostOpen);
			_s3Post.addEventListener(ProgressEvent.PROGRESS, onS3PostProgress);
			_s3Post.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onS3PostUploadCompleteData);

			_s3Post.uploadFileReference(_fileReference);
			
			this.mouseEnabled = this.mouseChildren = false; // *NB*
		}
		
		private function onS3PostIoError($e:IOErrorEvent):void
		{
			trace('ioerror', $e.text); 
			_tfUploadingMessage.htmlText = "<span class='upload1FinePrintRed'>" + _g.getString("formErrorUpload") + " (ID 1)</span>";
			clearReferences();
		}
		
		private function onS3PostSecurityError(event:SecurityErrorEvent):void 
		{
			trace('security error');
			_tfUploadingMessage.htmlText = "<span class='upload1FinePrintRed'>" + _g.getString("formErrorUpload") + "  (ID 2)</span>";
			clearReferences();
		}

		private function onS3PostOpen(e:*):void
		{
			trace('opened');
		}
		
		private function onS3PostProgress($e:ProgressEvent):void
		{
			_bar.value = $e.bytesLoaded/$e.bytesTotal;
		}
		
		private function onS3PostUploadCompleteData($e:DataEvent):void
		{
			var response:String = $e.data;
			trace('uploadcomplete:\r' + response);

			clearReferences();
			
			/*
				Example response:
				<?xml version="1.0" encoding="UTF-8"?>
				<PostResponse>
					<Location>http://leetest.s3.amazonaws.com/1276141208361_099A3C9B_74C7_0FBB_C54C_75399BD37302</Location>
					<Bucket>leetest</Bucket>
					<Key>1276141208361_099A3C9B_74C7_0FBB_C54C_75399BD37302</Key>
					<ETag>"f3250ad898836ae96b5d5aa01916811d"</ETag>
				</PostResponse>
			*/
			
			var xml:XML = new XML(response);
			if (xml.Location[0] && xml.Location[0].toString().length > 0)
			{
				var uploadedS3FileUrl:String = xml.Location[0].toString();
				trace('UPLOAD SUCCESSFUL:', uploadedS3FileUrl);
				
				postToEncodeService(uploadedS3FileUrl);
			}
			else
			{
				trace('ERROR:', response);
				ExternalInterface.call("console.log", "ERROR: " + response);
				var s:String = "<span class='upload1FinePrintRed'>" + _g.getString("formErrorUploadSpecial") + "</span>"
				_tfUploadingMessage.htmlText = s;
				clearReferences();
			}
		}
		
		private function clearReferences():void
		{
			if (_fileReference) {
				_fileReference.removeEventListener(Event.CANCEL, onFileReferenceCancel);
				_fileReference.removeEventListener(Event.SELECT, onFileReferenceSelect);
			}
			
			if (_s3Post) {
				_s3Post.removeEventListener(IOErrorEvent.IO_ERROR, onS3PostIoError);
				_s3Post.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onS3PostSecurityError);
				_s3Post.removeEventListener(Event.OPEN, onS3PostOpen);
				_s3Post.removeEventListener(ProgressEvent.PROGRESS, onS3PostProgress);
				_s3Post.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onS3PostUploadCompleteData);
			}
			
			if (_service) {
				_service.removeEventListener(Event.COMPLETE, onEncodeServiceResponse);
				_service.removeEventListener(IOErrorEvent.IO_ERROR, onEncodeServiceIoError);
			}
			
			this.mouseEnabled = this.mouseChildren = true;
		}
		
		private function postToEncodeService($uploadedS3FileUrl:String):void
		{
			var o:Object = {
				s3pathtosource: $uploadedS3FileUrl,
				first: _inpFirst.textInput.text,
				last: _inpLast.textInput.text,
				age: _inpAge.textInput.text,
				location: _inpLocation.textInput.text,
				phone: _inpPhone.textInput.text,
				email: _inpEmail.textInput.text
			};
			
			_service = new Service();
			_service.addEventListener(Event.COMPLETE, onEncodeServiceResponse);
			_service.addEventListener(IOErrorEvent.IO_ERROR, onEncodeServiceIoError);
			_service.request(_g.getString("encodeServiceUrl"), o, true, true);
		}
		
		private function onEncodeServiceIoError($e:IOErrorEvent):void
		{
			trace('encode service error', $e.text);
			_tfUploadingMessage.htmlText = "<span class='upload1FinePrintRed'>" + _g.getString("formErrorUpload") + "  (ID 4)</span>";
			clearReferences();
		}
		
		private function onEncodeServiceResponse($e:Event):void
		{
			clearReferences();
			
			// xxx need error response sample so i can parse for it, wtf
			
			if (true)
			{
				///_tfUploadingMessage.htmlText = "<span class='upload1FinePrint'>" + _g.getString("formSuccess") + "</span>";
				///_bar.value = 0;
				
				// * Only at this point do we clear the form text
				var a:Array = [ _inpFirst, _inpLast, _inpPhone, _inpEmail, _inpAge, _inpLocation ];
				for each (var inp:FormInput in a) {
					inp.textInput.text = "";
				}
				
				this.dispatchEvent(new Event(UploadView.EVENT_SHOW_THANKS_SUBVIEW));
			}
			else
			{
				_tfUploadingMessage.htmlText = "<span class='upload1FinePrintRed'>" + _g.getString("formErrorUpload") + " (ID 5)</span>";
			}
		}
		
		private function onAgreeLink(e:*):void
		{
			ExternalInterface.call("popup", Global.getInstance().getString("rulesUrl"), 600, 400); 
		}
		
		public static function t($s:String):void
		{
			ExternalInterface.call("console.log", $s);
			trace($s);
		}

	}
}


/*
private function onSubmit_ORIG(e:*):void
{
	if (! validate()) return;
	
	//
	
	_tfUploading.visible = true;
	_bar.visible = true;
	
	var ff:FileFilter = new FileFilter("Video " + "(" + Global.getInstance().getString("validUploadSuffixes") + ")", Global.getInstance().getString("validUploadSuffixes"));
	
	var req:URLRequest = new URLRequest(Global.getInstance().getString("uploadUrl"));
	
	var vars:Object = new Object();
	vars.first = _inpFirst.textInput.text;
	vars.last = _inpLast.textInput.text;
	vars.phone = _inpPhone.textInput.text;
	vars.email = _inpEmail.textInput.text;
	vars.age = _inpAge.textInput.text;
	vars.location = _inpLocation.textInput.text;
	req.data = JSON.encode(vars);
	req.requestHeaders = [ new URLRequestHeader("Content-Type", "application/json"), new URLRequestHeader("charset", "utf-8") ];
	
	
	///			UploadUtil.getInstance().doBrowse(req, [ff], onUploadCancel, onUploadIoError, onUploadProgress, onUploadCompleteData);
}
*/