package com.espn.ffl.util
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * Does not include embedded fonts, which are declared in Styles.as
	 */
	public class Assets
	{
		// SHARED

		// * This one def should not be externalized
		[Embed(source="./../../../../../embeds/pinwheel.swf")]
		public static const Pinwheel:Class;

		[Embed(source="./../../../../../embeds/fbDefaultThumb.gif")]
		public static const FacebookDefaultThumb:Class;

		[Embed(source="./../../../../../embeds/gradientGreen.png")]
		public static const GradientGreen:Class;
		
		[Embed(source="./../../../../../embeds/gradientGray.png")]
		public static const GradientGray:Class;
		
		[Embed(source="./../../../../../embeds/gradientRed.png")]
		public static const GradientRed:Class;
		
		[Embed(source="./../../../../../embeds/gradientBlue.png")]
		public static const GradientBlue:Class;
		
		[Embed(source="./../../../../../embeds/scrollAreaTrack.png")]
		public static const ScrollAreaTrack:Class;
		
		[Embed(source="./../../../../../embeds/checkbox.png")]
		public static const Checkbox:Class;
		
		[Embed(source="./../../../../../embeds/check.png")]
		public static const Check:Class;
		
		[Embed(source="./../../../../../embeds/redlight_off.png")]
		public static const RedLightOff:Class;
		
		[Embed(source="./../../../../../embeds/redlight_on.png")]
		public static const RedLightOn:Class;

		// DIALOG(S)
		
		[Embed(source="./../../../../../embeds/dialogBg9.png")]
		public static const DialogBg:Class;

		[Embed(source="./../../../../../embeds/dialogBgWithX9.png")]
		public static const DialogBgWithX:Class;

		[Embed(source="./../../../../../embeds/dialogBgRed9.png")]
		public static const DialogBgRed:Class;
		
		[Embed(source="./../../../../../embeds/dialogBgWithXRed9.png")]
		public static const DialogBgWithXRed9:Class;

		[Embed(source="./../../../../../embeds/mapperDialogBgWithCloseOffsetY34.png")]
		public static const MapperDialogBgWithCloseOffsetY34:Class;
		
		[Embed(source="./../../../../../embeds/mapperTeamInputBg.png")]
		public static const MapperTeamInputBg:Class;
		
		[Embed(source="./../../../../../embeds/mapperTeamInputX.png")]
		public static const MapperTeamInputX:Class;
		
		[Embed(source="./../../../../../embeds/enforcerDialogBg.png")]
		public static const EnforcerDialogBg:Class;

		[Embed(source="./../../../../../embeds/enforcerDialogBgRed.png")]
		public static const EnforcerDialogRed:Class;

		// NAV RELATED
		
		[Embed(source="./../../../../../embeds/settingsButton.png")]
		public static const SettingsButton:Class;

		[Embed(source="./../../../../../embeds/settingsButtonOver.png")]
		public static const SettingsButtonOver:Class;

		[Embed(source="./../../../../../embeds/facebookButtonNormal.png")]
		public static const FacebookButtonNormal:Class;
		/*
		[Embed(source="./../../../../../embeds/facebookButton.png")]
		public static const FacebookButton:Class;
		[Embed(source="./../../../../../embeds/facebookButtonOver.png")]
		public static const FacebookButtonOver:Class;
		*/

		[Embed(source="./../../../../../embeds/twitterButtonNormal.png")]
		public static const TwitterButtonNormal:Class;
		/*
		[Embed(source="./../../../../../embeds/twitterButton.png")]
		public static const TwitterButton:Class;
		[Embed(source="./../../../../../embeds/twitterButtonOver.png")]
		public static const TwitterButtonOver:Class;
		*/
		
		// ENFORCER
		
		[Embed(source="./../../../../../embeds/enforcerArrowLeft.png")]
		public static const EnforcerArrowLeft:Class;
		
		[Embed(source="./../../../../../embeds/enforcerArrowLeftOver.png")]
		public static const EnforcerArrowLeftOver:Class;

		[Embed(source="./../../../../../embeds/enforcerThumbPlayIcon.png")]
		public static const EnforcerThumbPlayIcon:Class;

		[Embed(source="./../../../../../embeds/enforcerVideoPlayIcon.png")]
		public static const EnforcerVideoPlayIcon:Class;

		[Embed(source="./../../../../../embeds/enforcerVideoPauseIcon.png")]
		public static const EnforcerVideoPauseIcon:Class;

		// REPORT CARD
		
		[Embed(source="./../../../../../embeds/reportCardRowHelmetOff.png")]
		public static const ReportCardHelmetOff:Class
		
		[Embed(source="./../../../../../embeds/reportCardRowHelmetOver.png")]
		public static const ReportCardHelmetOver:Class
		
		[Embed(source="./../../../../../embeds/reportCardRowTeamCellBg.png")]
		public static const ReportCardRowTeamCellBg:Class;
		
		[Embed(source="./../../../../../embeds/reportCarRowGradeBg.png")]
		public static const ReportCardRowGradeBg:Class;
		
		[Embed(source="./../../../../../embeds/reportCardRowCommentBg.png")]
		public static const ReportCardRowCommentBg:Class;

		[Embed(source="./../../../../../embeds/reportCardRowCommentEditBg.png")]
		public static const ReportCardRowCommentEditBg:Class;
		
		[Embed(source="./../../../../../embeds/reportCardDropdownArrow.png")]
		public static const ReportCardRowDropdownArrow:Class;
		
		[Embed(source="./../../../../../embeds/reportCardDropdownArrowOver.png")]
		public static const ReportCardRowDropdownArrowOver:Class;

		[Embed(source="./../../../../../embeds/reportCardDropdownArrowOpen.png")]
		public static const ReportCardRowDropdownArrowOpen:Class;

		[Embed(source="./../../../../../embeds/reportCardTitling.png")]
		public static const ReportCardTitling:Class;
		
		[Embed(source="./../../../../../embeds/reportCardDetailCaret.png")]
		public static const ReportCardDetailCaret:Class;		

		[Embed(source="./../../../../../embeds/reportCardTooltipBg.png")]
		public static const ReportCardTooltipBg:Class;		
		
		// INVITER
		
		[Embed(source="./../../../../../embeds/inviterScrubberBg.png")]
		public static const InviterScrubberBg:Class;

		[Embed(source="./../../../../../embeds/inviterScrubberLoaded.png")]
		public static const InviterScrubberLoaded:Class;
		
		[Embed(source="./../../../../../embeds/inviterScrubberThumb.png")]
		public static const InviterScrubberThumb:Class;
	}
}
