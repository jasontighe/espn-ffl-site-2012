package com.espn.ffl.model {
	import com.espn.ffl.apis.http.events.EncodingEvent;
	import com.espn.ffl.model.dto.CopyDTO;
	import com.espn.ffl.model.dto.EncodingDTO;
	import com.espn.ffl.model.dto.SectionDTO;

	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	/**
	 * @author jason.tighe
	 */
	public class ContentModel 
	extends EventDispatcher 
	{
		//----------------------------------------------------------------------------
		// public static constants
		//----------------------------------------------------------------------------
		public static const INTRO 						: String = "intro";
		public static const OUTRO 						: String = "outro";
		public static const QUESTION 					: String = "question";
		public static const REACTION 					: String = "reaction";
		public static const DEFAULT 					: String = "default";
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private static var _instance 					: ContentModel;
		//----------------------------------------------------------------------------
		// protected variables
		//----------------------------------------------------------------------------
		protected var _sections							: Array = new Array();
		protected var _copies							: Array = new Array();
		protected var _interviewVideos					: Array = new Array();
		protected var _premadeVideos					: Array = new Array();
		protected var _webcamVideos						: Array = new Array();
//		protected var _introVideos						: Array = new Array();
//		protected var _outroVideos						: Array = new Array();
		protected var _questionVideos					: Array = new Array();
//		protected var _reactionVideos					: Array = new Array();
//		protected var _videoFormats						: Array = new Array();
//		protected var _signerValues						: Array = new Array();
		protected var _copiesD							: Dictionary;
		protected var _encodingVidsD					: Dictionary;
		protected var _questionVidsD					: Dictionary;
//		protected var _reactionVidsD					: Dictionary;
		protected var _formatsD							: Dictionary;
		protected var _videoCreated						: Boolean = false;
		protected var _enforcerData						: XML;
		protected var _metricsData						: XML;
		protected var _totalInterviewVideos				: uint;
		protected var _totalPremadeVideos				: uint;
		protected var _premadeImageURL					: String;
		protected var _personalizedImageURL				: String;
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		protected var _webcamS3URLCount					: uint = 0;
//		protected var _stichS3URLCount					: uint = 0;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function ContentModel( e : ContentModelEnforcer ) 
		{
			trace( "CONTENTMODEL : Constr" );
		}
		
		public function addData( data : * ) : void
		{
			var xml : XML = XML( data );
			
			var i : uint;
			var I : uint;
			
//			SECTION DTOS
			var sections : XMLList = xml.sections.*;
			var sectionDTO : SectionDTO;
			i = 0;
			I = sections.length();
			for( i; i < I; i++ )
			{
				sectionDTO = new SectionDTO( sections[ i ], i );
				_sections.push( sectionDTO );
			}

//			COPY DTOS
			_copiesD = new Dictionary();
			var copies : XMLList = xml.copies.*;
			var copyDTO : CopyDTO;
			i = 0;
			I = copies.length();
			for( i; i < I; i++ )
			{
				copyDTO = new CopyDTO( copies[ i ] );
				_copies.push( copyDTO );
				_copiesD[ copyDTO.name ] = copyDTO;
			}
			
			// FOR VIDEOS
			var videos : XMLList;
			var encodingDTO : EncodingDTO;

//			INTERVIEW VIDEO DTOS
//			_encodingVidsD = new Dictionary();
			videos = xml.videos.interview.*;
			i = 0;
			I = videos.length();
			_totalInterviewVideos = I;
			for( i; i < I; i++ )
			{
				encodingDTO = new EncodingDTO( videos[ i ], i );
				_interviewVideos.push( encodingDTO );
//				encodingDTO.traceData();
			}

//			PREMADE VIDEO DTOS
			videos = xml.videos.premade.*;
			i = 0;
			I = videos.length();
			_totalPremadeVideos = I;
			for( i; i < I; i++ )
			{
				encodingDTO = new EncodingDTO( videos[ i ], i );
				_premadeVideos.push( encodingDTO );
			}

////			INTRO VIDEO DTOS
//			videos = xml.videos.personalized.intro.videos.*;
//			i = 0;
//			I = videos.length();
//			for( i; i < I; i++ )
//			{
//				encodingDTO = new EncodingDTO( videos[ i ], i );
//				_introVideos.push( encodingDTO );
////				encodingDTO.traceData();
//			}

////			OUTRO VIDEO DTOS
//			videos = xml.videos.personalized.outro.videos.*;
//			i = 0;
//			I = videos.length();
//			for( i; i < I; i++ )
//			{
//				encodingDTO = new EncodingDTO( videos[ i ], i );
//				_outroVideos.push( encodingDTO );
////				encodingDTO.traceData();
//			}

//			QUESTION VIDEO DTOS
			var j : uint;
			var J : uint;
			var questions : XMLList;
			var array : Array;
			_questionVidsD = new Dictionary();
			questions = xml.videos.personalized.questions.*;
			i = 0;
			I = questions.length();
			for( i; i < I; i++ )
			{
//				trace( "\n" );
//				trace( "i is "+i );
				
				videos = questions[ i ].*;
				j = 0;
				J = videos.length();
//				trace( "questions.videos.* is "+questions.videos.* );
//				trace( "videos.length() is "+videos.length() );
				
				for( j; j < J; j++ )
				{
					encodingDTO = new EncodingDTO( videos[ j ], j );
					_questionVidsD[ encodingDTO.name ] = encodingDTO;
//					encodingDTO.traceData();
					array = new Array();
					array.push( encodingDTO );
				}
				// It's an array of arrays since there are multiple videos for each question
				_questionVideos.push( array );
			}

//			REACTION VIDEO DTOS
//			var reactions : XMLList;
//			reactions = xml.videos.personalized.reactions.*;
//			_reactionVidsD = new Dictionary();
//			i = 0;
//			I = reactions.length();
//			for( i; i < I; i++ )
//			{
////				trace( "\n" );
////				trace( "i is "+i );
//				
//				videos = reactions[ i ].*;
//				j = 0;
//				J = videos.length();
////				trace( "reactions.videos.* is "+reactions.videos.* );
////				trace( "videos.length() is "+videos.length() );
//				
//				for( j; j < J; j++ )
//				{
//					encodingDTO = new EncodingDTO( videos[ j ], j );
//					_reactionVidsD[ encodingDTO.name ] = encodingDTO;
////					encodingDTO.traceData();
//					array = new Array();
//					array.push( encodingDTO );
//				}
//				// It's an array of arrays since there are multiple videos for each question
//				_reactionVideos.push( array );
//			}

////			VIDEO FORMATS DTOS
//			var formatDTO : FormatDTO;
//			var formats : XMLList;
//			_formatsD = new Dictionary;
//			formats = xml.encoding.formats.*;
//			i = 0;
//			I = formats.length();
//			for( i; i < I; i++ )
//			{
//				formatDTO = new FormatDTO( formats[ i ], i );
//				_videoFormats.push( formatDTO );
//				_formatsD[ formatDTO.name ] = formatDTO;
////				formatDTO.traceData();
//			}
			
//			ENFORCER 
			_enforcerData = xml.enforcer[0];
			
//			METRICS
			_metricsData = xml.metrics[0];
		}
		 
		//----------------------------------------------------------------------------
		// getter/setters
		//----------------------------------------------------------------------------
		public static function get gi() : ContentModel
		{
			if(!_instance) _instance = new ContentModel(new ContentModelEnforcer());
			return _instance;
		}
		
		public function getSectionItemAt( index : uint ) : SectionDTO 
		{	
			return _sections[ index ];
		}
		
		public function get sections() : Array
		{
			return _sections;
		}
		
		public function getCopyItemAt( index : uint ) : CopyDTO 
		{	
			return _copies[ index ];
		}
		
		public function get copies() : Array
		{
			return _copies;
		}
		
		public function get webcamVideos() : Array
		{
			return _webcamVideos;
		}
		
		public function get premadeVideos() : Array
		{
			return _premadeVideos;
		}
		public function getPremadeVideoItem( n : uint ) : EncodingDTO 
		{	
			return _premadeVideos[ n ];
		}
		
		public function addWebcamVideo( url : String, id : uint ) : void
		{
			trace( "CONTENTMODEL : addWebcamVideo() : id is "+id );
			_webcamVideos.push( url );
			var i : uint = 0;
			var I : uint = _webcamVideos.length;
			for( i; i < I; i++ ) 
			{
				trace( "CONTENTMODEL : addWebcamVideo() : addWebcamVideo[ "+ i +" ] is "+_webcamVideos[ i ] );
			}
		}
		
		public function get premadeImageURL( ) : String 
		{
			return _premadeImageURL;
		}
		public function set premadeImageURL( s : String ) : void
		{
			_premadeImageURL = s;
		}
		
		public function get personalizedImageURL( ) : String 
		{
			return _personalizedImageURL;
		}
		public function set personalizedImageURL( s : String ) : void
		{
			_personalizedImageURL = s;
		}
		
		public function getCopyItemByName( name : String ) : CopyDTO
		{
			return _copiesD[ name ];
		}
		
//		public function getFormatItemByName( name : String ) : FormatDTO
//		{
//			return _formatsD[ name ];
//		}
		
//		public function getIntroVideoItem( ) : EncodingDTO 
//		{	
//			return _introVideos[ 0 ];
//		}
//		
//		public function getOutroVideoItemAt( index : uint ) : EncodingDTO 
//		{	
//			return _outroVideos[ index ];
//		}
//		
//		public function getRandomOutroVideoItem( ) : EncodingDTO 
//		{	
//			var random : int = int( Math.random() * _outroVideos.length );
//			return _outroVideos[ random ];
//		}
		
		public function getInterviewVideoItemAt( index : uint ) : EncodingDTO 
		{	
			return _interviewVideos[ index ];
		}
		
		public function get questionVideos(  ) : Array 
		{	
			return _questionVideos;
		}
		
//		public function getQuestionVideoItemAt( index1 : uint, index2 : uint ) : EncodingDTO 
//		{	
//			return _questionVideos[ index1 ][ index2 ];
//		}
		
//		public function getQuestionVideoByName( name : String ) : EncodingDTO
//		{
//			return _questionVidsD[ name ];
//		}
		
//		public function getRandomQuestionVideoItemAt( index : uint, total : uint ) : EncodingDTO 
//		{	
//			var random : int = int( Math.random() * total );
//			return _questionVideos[ index ][ random ];
//		}
		
//		public function get reactionVideos(  ) : Array 
//		{	
//			return _reactionVideos;
//		}
//		
//		public function getReactionVideoItemAt( index1 : uint, index2 : uint ) : EncodingDTO 
//		{	
//			return _reactionVideos[ index1 ][ index2 ];
//		}
//		
//		public function getRandomReactionVideoItemAt( index : uint, total : uint ) : EncodingDTO 
//		{	
//			var random : int = int( Math.random() * total );
//			return _reactionVideos[ index ][ random ];
//		}
//		
//		public function getReactionVideoByName( name : String ) : EncodingDTO
//		{
//			return _reactionVidsD[ name ];
//		}
		
		public function getEncodingVideoItemByName( name : String ) : EncodingDTO
		{
			return _encodingVidsD[ name ];
		}
		
		public function get videoCreated() : Boolean
		{
			return _videoCreated;
		}
		
		public function set videoCreated( value : Boolean ) : void
		{
			_videoCreated = value;
		}
		
		public function get enforcerData():XML
		{
			return _enforcerData;
		}
		
		public function get metricsData():XML
		{
			return _metricsData;
		}
		
		public function get totalInterviewVideos() : uint
		{
			return _totalInterviewVideos;
		}
		
		public function get totalPremadeVideos() : uint
		{
			return _totalPremadeVideos;
		}
		
		public function get webcamS3URLCount() : uint
		{
			return _webcamS3URLCount;
		}
		public function upWebcamS3URLCount() : void
		{
			_webcamS3URLCount++;
			trace( "\n\n" );
			trace( "***************************************" );
			trace( "CONTENTMODEL : upWebcamS3URLCount() : _webcamS3URLCount is "+_webcamS3URLCount );
			trace( "CONTENTMODEL : upWebcamS3URLCount() : _interviewVideos.length is "+_interviewVideos.length );
			trace( "***************************************" );
			trace( "\n\n" );
			if( _webcamS3URLCount == _interviewVideos.length )
			{
				trace( "\n\n" );
				trace( "CONTENTMODEL : upWebcamS3URLCount() : WEBCAM VIDEOS ARE READY." );
				trace( "\n\n" );
				dispatchEvent( new EncodingEvent( EncodingEvent.WEBCAMS_UPLOADED ) );
			}
		}
		
		public function set webcamS3URLCount( n : uint ) : void
		{
			_webcamS3URLCount = n;
		}
	}
}

class ContentModelEnforcer{}
