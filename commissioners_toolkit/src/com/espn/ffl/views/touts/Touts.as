package com.espn.ffl.views.touts {
	import com.espn.ffl.util.Metrics;
	import com.espn.ffl.views.AbstractView;
	import com.jasontighe.containers.events.ContainerEvent;
	
	import flash.events.Event;

	/**
	 * @author jason.tighe
	 */
	public class Touts 
	extends AbstractView 
	{
		//----------------------------------------------------------------------------
		// public static const
		//----------------------------------------------------------------------------
		public static const X_SPACE							: uint = 30;
		public static const Y_SPACE							: uint = 30;
		public static const INVITER_X						: uint = 10;
		public static const INVITER_Y						: uint = 219;
		public static const ENFORCER_X						: uint = 10;
		public static const ENFORCER_Y						: uint = 479;
		public static const REPORT_CARD_X					: uint = 10;
		public static const REPORT_CARD_Y					: uint = 739;
		public static const APPAREL_X						: uint = 647;
		public static const APPAREL_Y						: uint = 739;
		//----------------------------------------------------------------------------
		// protected var
		//----------------------------------------------------------------------------
		protected var _touts							: Array;					
		//----------------------------------------------------------------------------
		// public var
		//----------------------------------------------------------------------------
		public var apparel								: ApparelTout;
		public var enforcer								: EnforcerTout;
		public var inviter								: InviterTout;
		public var reportCard							: ReportCardTout;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function Touts() 
		{
			super();
		}
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public override function init() : void 
		{ 
			trace( "TOUTS : init()" );
			addViews();		
			setIds();
			hide();
		}
		
		public override function transitionIn() : void 
		{ 
		}
		
		public override function transitionOut() : void
		{
		}
		
		//----------------------------------------------------------------------------
		// protected methods
		//----------------------------------------------------------------------------
		protected override function onShowComplete ( e : Event = null ) : void
		{
			dispatchEvent( new ContainerEvent( ContainerEvent.SHOW ) );
			activate();
			
			Metrics.pageView("home");
		}

		protected override function onHideComplete ( e : Event = null ) : void
		{
			visible = false;
			
			dispatchEvent( new ContainerEvent( ContainerEvent.HIDE ) );
		}
		
		protected override function addViews() : void 
		{ 
			trace( "MAIN : addViews()" );
			apparel = new ApparelTout();
			apparel.init();
			addChild( apparel );
			
			enforcer = new EnforcerTout();
			enforcer.init();
			addChild( enforcer );
			
			inviter = new InviterTout();
			inviter.init();
			addChild( inviter );
			
			reportCard = new ReportCardTout();
			reportCard.init();
			addChild( reportCard );
			
			_touts = new Array( inviter,
								enforcer,
								reportCard,
								apparel );
			
			inviter.x = INVITER_X;
			inviter.y = INVITER_Y;
			enforcer.x = ENFORCER_X;
			enforcer.y = ENFORCER_Y;
			reportCard.x = REPORT_CARD_X;
			reportCard.y = REPORT_CARD_Y;
			apparel.x = APPAREL_X;
			apparel.y = APPAREL_Y;
		}
		
		protected function setIds() : void 
		{ 
			var i : uint = 0;
			var I : uint = _touts.length;
			
			for( i; i < I; i++ )
			{
				var tout : AbstractTout = _touts[ i ];
				tout.id = i;
			}
		}
		
		protected function activate() : void 
		{ 
			var i : uint = 0;
			var I : uint = _touts.length;
			
			for( i; i < I; i++ )
			{
				var tout : AbstractTout = _touts[ i ];
//				tout.activate();
			}
		}
	}
}
