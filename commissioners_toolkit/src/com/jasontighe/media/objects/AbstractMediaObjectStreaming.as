package com.jasontighe.media.objects {	public class AbstractMediaObjectStreaming extends AbstractMediaObject implements IMediaObjectStreaming 	{		protected var _server:String;		protected var _media:IMediaObjectStreaming;		protected var _bandwidthThreshold: Number = 0;		public function AbstractMediaObjectStreaming( url:String, server:String )		{			super( url );						_server = server;		}		public function get server( ):String		{			return _server;		}				public function get media( ):IMediaObjectStreaming		{			return _media;		}				public function set bandwidthThreshold(thresh:Number):void		{			_bandwidthThreshold = thresh;		}	}}