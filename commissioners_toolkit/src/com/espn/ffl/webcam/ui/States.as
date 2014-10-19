package com.espn.ffl.webcam.ui {

	/**
	 * @author jason.tighe
	 */
	public class States 
	{
		public static const WAITING_FOR_WEBCAM:String = "webcamWaitingForWebcam";
		public static const WAITING_FOR_RECORD:String = "webcamWaitingForRecord";
		public static const RECORDING:String = "webcamRecording";
		public static const ENCODING:String = "webcamEncoding";
		public static const SAVING:String = "webcamSaving";
		
		// saving to file is synchronous so needs no 'state'
	}
}