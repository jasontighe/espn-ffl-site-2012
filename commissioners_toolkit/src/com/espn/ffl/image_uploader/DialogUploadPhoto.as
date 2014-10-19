package com.espn.ffl.image_uploader {
	import leelib.ExtendedEvent;
	import leelib.graphics.GrUtil;
	import leelib.util.Out;
	import leelib.util.TextFieldUtil;

	import com.adobe.images.PNGEncoder;
	import com.espn.ffl.apis.http.HusaniRequestor;
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.InviterModel;
	import com.espn.ffl.model.dto.CopyDTO;
	import com.espn.ffl.util.FflS3Uploader;
	import com.espn.ffl.util.Metrics;
	import com.espn.ffl.views.BubbleButton;
	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;
	import com.jasontighe.containers.DisplayContainer;
	import com.jasontighe.managers.AssetManager;
	import com.jasontighe.utils.Box;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;

	/**
	 * @author jason.tighe
	 */
	public class DialogUploadPhoto 
	extends DisplayContainer 
	{
		//----------------------------------------------------------------------------
		// private static constants
		//----------------------------------------------------------------------------
		private static const WIDTH_LRG						: uint = 570;
		private static const HEIGHT_LRG						: uint = 232;
		private static const ICON_X							: uint = 27;
		private static const ICON_Y							: uint = 29;
		private static const FILENAME_BOX_X					: uint = 27;
		private static const FILENAME_BOX_Y					: uint = 130;
		private static const FILENAME_BOX_WIDTH				: uint = 210;
		private static const MAX_FILE_SIZE					: uint = 2000000;
		//----------------------------------------------------------------------------
		// public static constants
		//----------------------------------------------------------------------------
		public static const CLOSE_CLICKED					: String = "dialogUploadPhoto.closeClicked";		
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _cm										: ContentModel = ContentModel.gi;
//		private var URLrequest								: URLRequest = new URLRequest("./uploader_script.php");
		private var imageTypes								: FileFilter = new FileFilter("Images (*.jpg, *.jpeg, *.gif, *.png)", "*.jpg; *.jpeg; *.gif; *.png");
		private var textTypes								: FileFilter = new FileFilter("Text Files (*.txt, *.rtf)", "*.txt; *.rtf");
		private var allTypes								: Array = new Array(imageTypes, textTypes);
		private var fileReference 							: FileReference = new FileReference();
		private var _filenameAdded							: Boolean = false;
		private var _arrowX									: uint;
		private var _id										: uint = 0;
		private var _type									: String;
		private var _targetImageWidth						: int;
		private var _targetImageHeight						: int;
		private var _dots									: Array = new Array();
		private var _waitingTxtAdded						: Boolean = false;
		private var _waitingCount							: uint = 0;
		private var _imageUploaded							: Boolean = false;
		private var _pngBytes								: ByteArray;
		private var _imageURL								: String;
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var holder									: MovieClip;
		public var icon										: MovieClip;
		public var filenameBox								: MovieClip;
		public var outline									: MovieClip;
		public var gray										: MovieClip;
		public var arrow									: MovieClip;
		public var closeBtn									: MovieClip;
		public var uploadBtn								: BubbleButton;
		public var browseBtn								: BubbleButton;
		public var title									: TextField;
		public var desc										: TextField;
		public var browse									: TextField;
		public var filename									: TextField;
		public var skip										: TextField;
		public var error									: TextField;
		public var footer									: TextField;
		public var waitingTxt								: TextField;
		public var skipBtn									: Box;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function DialogUploadPhoto( type : String, targetImageWidth:int, targetImageHeight:int) 
		{
			trace( "DIALOGUPLOADPHOTO : Constr() : type is "+type, " target image dimensions", targetImageWidth, targetImageHeight );
			_type = type;
			_targetImageWidth = targetImageWidth;
			_targetImageHeight = targetImageHeight;
			
			var asset : MovieClip = MovieClip( AssetManager.gi.getAsset( "UploadDialogAsset", SiteConstants.ASSETS_ID ) );
			addChild( asset );
			
			icon = asset.icon;
			gray = asset.gray;
			closeBtn = asset.closeBtn;
			filenameBox = asset.filenameBox;
			arrow = asset.arrow;
			outline = gray.outline;
			
			_arrowX = arrow.x;
			arrow.visible = false;
			
			holder = new MovieClip();
			addChild( holder );
			
			holder.addChild( gray );
			holder.addChild( filenameBox );
			holder.addChild( icon );
			holder.addChild( arrow );
			holder.addChild( closeBtn );
//			icon.filters = [ FflDropShadow.getDefault() ];

			if( _type == InviterModel.STATE_PREMADE )
			{
				title = TextFieldUtil.makeTextWithCopyDto( _cm.getCopyItemByName("liUploadPremadeTitle") );
				holder.addChild( title );
			}
			else
			{
				title = TextFieldUtil.makeTextWithCopyDto( _cm.getCopyItemByName("liUploadTitle") );
				holder.addChild( title );
			}

			desc = TextFieldUtil.makeTextWithCopyDto( _cm.getCopyItemByName("liUploadDesc") );
			holder.addChild( desc );

			error = TextFieldUtil.makeTextWithCopyDto( _cm.getCopyItemByName("liUploadError") );
			holder.addChild( error );
			error.visible = false;

			footer = TextFieldUtil.makeTextWithCopyDto( _cm.getCopyItemByName("liUploadFooter") );
			holder.addChild( footer );

			
			
			var dto : CopyDTO;
			
			dto = _cm.getCopyItemByName( "liUploadBrowseBtn" );
			browseBtn = new BubbleButton( dto.copy, 131, true );
			browseBtn.x = dto.xPos;
			browseBtn.y = dto.yPos;
			holder.addChild( browseBtn );
			
			dto = _cm.getCopyItemByName( "liUploadBtn" );
			uploadBtn = new BubbleButton( dto.copy, 142 );
			uploadBtn.x = dto.xPos;
			uploadBtn.y = dto.yPos;
			holder.addChild( uploadBtn );
			deactivateUploadButton();
			
			if( _type == InviterModel.STATE_PERSONALIZED )
			{
				skip = TextFieldUtil.makeTextWithCopyDto( _cm.getCopyItemByName("liUploadSkipBtn") );
				holder.addChild( skip );
				
				arrow.visible = true;
			
				var skipW : uint = int( arrow.x - skip.x + arrow.width );
				var skipH : uint = int( skip.textHeight );
				skipBtn = new Box( skipW, skipH );
				skipBtn.alpha = 0;
				skipBtn.x = skip.x;
				skipBtn.y = skip.y + 2;
				holder.addChild( skipBtn );
				
				skipBtn.buttonMode = true;
				skipBtn.mouseEnabled = true;
				skipBtn.mouseChildren = false;
				skipBtn.useHandCursor = true;
				
				skipBtn.addEventListener( MouseEvent.CLICK, onSkipClick );
				skipBtn.addEventListener( MouseEvent.MOUSE_OVER, onSkipOver );
				skipBtn.addEventListener( MouseEvent.MOUSE_OUT, onSkipOut );
			}
			
			_dots = [ "", ".", "..", "..." ];
			
			addHandlers();
			closeBtn.visible = false;
		}

		public function activateCloseButton( ) : void
		{
			closeBtn.visible = true;
			closeBtn.useHandCursor = true;
			closeBtn.buttonEnabled = true;;
			closeBtn.mouseEnabled = closeBtn.mouseChildren = true;
		}
		
		private function addHandlers() : void
		{ 
			browseBtn.addEventListener( MouseEvent.CLICK, onBrowseButtonClick );
			uploadBtn.addEventListener( MouseEvent.CLICK, onUploadButtonClick );
			closeBtn.addEventListener( MouseEvent.CLICK, onCloseButtonClick );
		}
		
		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		
		private function addFileName() : void
		{ 
			if( _filenameAdded )
			{
				holder.removeChild( filename );
				filename = null;
			}
			
			var copy : String = fileReference.name;
			filename = TextFieldUtil.makeText( copy, ".liUploadFilename", FILENAME_BOX_WIDTH );
			TextFieldUtil.ellipsize( filename, FILENAME_BOX_WIDTH );
			holder.addChild( filename );
			filename.x = _cm.getCopyItemByName( "liUploadFilename" ).xPos;
			filename.y = _cm.getCopyItemByName( "liUploadFilename" ).yPos;
			
			_filenameAdded = true;
		}
		
		
		private function dispatchCompleteEvent() : void
		{
			dispatchEvent( new Event( Event.COMPLETE ) ); 
		}

		private function arrowIn( ) : void
		{
			var distance : uint = 5;
			arrow.x = _arrowX - distance;
			arrow.alpha = 0;
			TweenLite.to( arrow, SiteConstants.TIME_OUT, { x: _arrowX, alpha: 1, ease: Quad.easeIn, onComplete: arrowOut } );
		}

		private function arrowOut( ) : void
		{
			var distance : uint = 5;
			TweenLite.to( arrow, SiteConstants.TIME_OUT, { x: _arrowX + distance, alpha: 0, ease: Quad.easeOut, onComplete: resetArrow } );
		}

		private function resetArrow( ) : void
		{
			arrow.x = _arrowX;
			arrow.alpha = 1;
		}

		private function updateError( ) : void
		{
			error.visible = isFileOversize;
		}

		private function showFileSelectedMessage( ) : void
		{
			holder.removeChild( desc );
			desc = null;

			desc = TextFieldUtil.makeTextWithCopyDto( _cm.getCopyItemByName("liUploadSelected") );
			holder.addChild( desc );
		}

		private function activateUploadButton( ) : void
		{
			uploadBtn.isSelected = false;
			uploadBtn.alpha = 1;
			uploadBtn.mouseEnabled = uploadBtn.mouseChildren = true;
		}

		private function deactivateUploadButton( ) : void
		{
			uploadBtn.isSelected = true;
			uploadBtn.alpha = .5;
			uploadBtn.mouseEnabled = uploadBtn.mouseChildren = false;
		}

		private function deactivateAllButtons( ) : void
		{
			deactivateUploadButton()
			browseBtn.isSelected = true;
			browseBtn.alpha = .5;
			
			if( _type == InviterModel.STATE_PERSONALIZED ) 
			{
				skipBtn.buttonMode = false;
				skipBtn.mouseEnabled = false;
				skipBtn.mouseChildren = false;
				skipBtn.useHandCursor = false;
				
				skipBtn.removeEventListener( MouseEvent.CLICK, onSkipClick );
				skipBtn.removeEventListener( MouseEvent.MOUSE_OVER, onSkipOver );
				skipBtn.removeEventListener( MouseEvent.MOUSE_OUT, onSkipOut );
			}
		}

		private function showWaitingToUpload( ) : void
		{
			hideWaitingToUpload();
			
			if( _imageUploaded )	return;
			
			var dot : String = _dots[ _waitingCount ];
			var copy : String = _cm.getCopyItemByName( "liUploadWaiting" ).copy + dot;
			waitingTxt = TextFieldUtil.makeText( copy, ".liUploadWaiting" );
			waitingTxt.x = _cm.getCopyItemByName( "liUploadWaiting" ).xPos;
			waitingTxt.y = _cm.getCopyItemByName( "liUploadWaiting" ).yPos;
			holder.addChild( waitingTxt );
			
			_waitingTxtAdded = true;
			_waitingCount++;
			if( _waitingCount == _dots.length )	_waitingCount = 0;
			
			var to : uint;
			if( !_imageUploaded )
			{
				if( _waitingCount == 0 )
				{
					to = setTimeout( showWaitingToUpload, 1000 );
				}
				else
				{
					to = setTimeout( showWaitingToUpload, 333 );
				}	
			}
		}

		private function hideWaitingToUpload( ) : void
		{
			if( _waitingTxtAdded )
			{
				if( waitingTxt && holder.contains(waitingTxt ))
				{
					holder.removeChild( waitingTxt );
					waitingTxt = null;
				}
			}
		}

		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		private function onBrowseButtonClick( e : MouseEvent ) : void 
		{
			trace( "DIALOGUPLOADPHOTO : onBrowseButtonClick()" );
			error.visible = false;

			fileReference.addEventListener( Event.SELECT, onFileSelected );
			fileReference.browse( [ imageTypes ] );
		}
		
		private function onCloseButtonClick( e : MouseEvent ) : void 
		{
			trace( "DIALOGUPLOADPHOTO : onCloseButtonClick()" );
			dispatchEvent(new ExtendedEvent( CLOSE_CLICKED, e));
		}
		
		// Function that fires off when File is selected from PC and Browse dialogue box closes
		private function onFileSelected( e : Event ) : void 
		{
			trace( "DIALOGUPLOADPHOTO : onFileSelected() : fileReference.size is "+fileReference.size );
			
			updateError();
			addFileName();
			showFileSelectedMessage();

			if (isFileOversize)
			{
				deactivateUploadButton();
				return;
			}
			
			fileReference.addEventListener( Event.COMPLETE, onFileReferenceLoaded );
			fileReference.load();
		}
		
		private function onFileReferenceLoaded( e : Event ) : void 
		{
			trace( "DIALOGUPLOADPHOTO : onFileReferenceLoaded()" );
			
			if (! fileReference.data || fileReference.data.length == 0)
			{
				Out.e("DialogUploadPhoto.uponUploadButtonClick - NO DATA");
				hideWaitingToUpload();
				error.visible = true;
				return;
			}
			
			_pngBytes = fileReference.data;
			
			// load image
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadBytesComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadBytesCompleteError);
			loader.loadBytes(_pngBytes);
		}
		
		private function onLoadBytesCompleteError($e:IOErrorEvent):void
		{
			Out.e("DialogUploadPhoto.onLoadBytesCompleteError()");
			
			var loaderInfo:LoaderInfo = $e.target as LoaderInfo;
			loaderInfo.removeEventListener(Event.COMPLETE, onLoadBytesComplete);
			loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadBytesCompleteError);
			
			_pngBytes.length = 0;
			
			hideWaitingToUpload();
			error.visible = true;
		}
		
		private function onLoadBytesComplete($e:Event):void
		{
			var loaderInfo:LoaderInfo = $e.target as LoaderInfo;
			loaderInfo.removeEventListener(Event.COMPLETE, onLoadBytesComplete);
			loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadBytesCompleteError);
			
			var b:Bitmap = loaderInfo.loader.content as Bitmap;
			if (! b)
			{
				Out.e("DialogUploadPhoto.onLoadBytesComplete() - NO BITMAP");
				
				_pngBytes.length = 0;
				
				hideWaitingToUpload();
				error.visible = true;
				return;
			}
			
			Out.i("DialogUploadPhoto.onLoadBytesComplete()", b.width,b.height);
			
			var scaledBitmapData:BitmapData = GrUtil.makeCroppedFittedBitmapData(b, _targetImageWidth, _targetImageHeight);
			_pngBytes = PNGEncoder.encode(scaledBitmapData);
			
			// TEST CODE:
//			b.width = 100;
//			b.scaleY = b.scaleX;
//			b.x = 10;
//			b.y = 150;
//			Main.instance.stage.addChild(b);
//			
//			var b2:Bitmap = new Bitmap(scaledBitmapData);
//			b2.width = 100;
//			b2.scaleY = b2.scaleX;
//			b2.x = 120;
//			b2.y = 150
//			Main.instance.stage.addChild(b2);
			
			activateUploadButton();
		}			
		
		private function onUploadButtonClick( e : MouseEvent ) : void 
		{
			trace( "DIALOGUPLOADPHOTO : onUploadButtonClick()" );
			
			error.visible = false;
			showWaitingToUpload();
			deactivateAllButtons();

			Metrics.pageView("inviterCustomizeQuestion3UploadButton");
			
			// now upload image				
			var s3Uploader:FflS3Uploader = new FflS3Uploader();
			s3Uploader.addEventListener(FflS3Uploader.EVENT_ERROR, onUploadError);
			s3Uploader.addEventListener(FflS3Uploader.EVENT_COMPLETE, onUploadComplete);
			s3Uploader.upload(_pngBytes, "png");
		}

		private function onUploadError($e:ExtendedEvent):void
		{
			Out.e("DialogUploadPhoto.onUploadError() -", $e.object);
			
			var s3Uploader:FflS3Uploader = $e.target as FflS3Uploader;;
			s3Uploader.removeEventListener(FflS3Uploader.EVENT_COMPLETE, onUploadComplete);
			s3Uploader.removeEventListener(FflS3Uploader.EVENT_ERROR, onUploadError);
			
			_pngBytes.length = 0;
			
			hideWaitingToUpload();
			error.visible = true;
		}
		private function onUploadComplete($e:ExtendedEvent):void
		{
			var fileName:String = $e.object as String;
			Out.i("DialogUploadPhoto.onUploadComplete() -", fileName);
			
			var s3Uploader:FflS3Uploader = $e.target as FflS3Uploader;;
			s3Uploader.removeEventListener(FflS3Uploader.EVENT_COMPLETE, onUploadComplete);
			s3Uploader.removeEventListener(FflS3Uploader.EVENT_ERROR, onUploadError);
			
			if( _type == "PERSONALIZED" )
				_cm.personalizedImageURL = fileName;
			else
				_cm.premadeImageURL = fileName;
			
			
			var hr : HusaniRequestor = new HusaniRequestor();
			hr.photoUrl = fileName;
			hr.addEventListener( Event.COMPLETE, sendURLToHusaniComplete);
			hr.addEventListener(IOErrorEvent.IO_ERROR, onS3PostIoError);
			hr.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onS3PostSecurityError);
			hr.request( HusaniRequestor.SET_IMAGE_URL );
			
			_imageUploaded = true;
			hideWaitingToUpload();
		}
		
		private function onSkipClick( e : MouseEvent ) : void
		{
			Metrics.pageView("inviterCustomizeQuestion3SkipUploadButton");
			
			dispatchCompleteEvent();
		}
		
		private function onSkipOver( e : MouseEvent ) : void
		{
			TweenLite.killTweensOf( arrow );
			arrowIn();
		}

		private function onSkipOut( e : MouseEvent ) : void
		{
			
		}		
		
		private function sendURLToHusaniComplete( e : Event ) : void
		{
			trace( "DIALOGUPLOADPHOTO : sendURLToHusaniComplete()" ); 
			dispatchCompleteEvent();
		}
		
		private function onS3PostIoError($e:IOErrorEvent):void
		{
			Out.i("DIALOGUPLOADPHOTO : FflS3Uploader.onS3PostIoError()", $e.text);
		}
		
		private function onS3PostSecurityError($e:SecurityErrorEvent):void 
		{
			Out.i("DIALOGUPLOADPHOTO : FflS3Uploader.onS3PostSecurityError()", $e.text);
		}

		//----------------------------------------------------------------------------
		// getters/setters
		//----------------------------------------------------------------------------
		private function get isFileOversize() : Boolean
		{
			trace( "DIALOGUPLOADPHOTO : isFileOversize() : fileReference.size is "+fileReference.size ); 
			fileReference.size;
			return ( fileReference.size > MAX_FILE_SIZE);
		}
		
		public function set id( n : uint ) : void 
		{
		   _id = n;
		}
	}
}
