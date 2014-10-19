package leelib.threeD
{
	import org.papervision3d.core.math.Number3D;
	
	/**
	 * Spherical coordinates  
	 * 
	 * Needs more work.
	 */
	public class Spherical3D
	{
		private static const DEGREE:Number = Math.PI / 180;
		private static const HALFPI:Number = Math.PI / 2;
		
		public var radius:Number;
		public var latitude:Number;
		public var longitude:Number;
		
		
		public function Spherical3D($radius:Number=0, $latitude:Number=0, $longitude:Number=0)
		{
			radius = $radius;
			latitude = $latitude;
			longitude = $longitude;
		}
		
		public function toNumber3d():Number3D
		{
		    var x:Number = radius * Math.cos(-latitude+HALFPI)*Math.cos(longitude);
		    var y:Number = radius * Math.sin(-latitude+HALFPI);
		    var z:Number = radius * Math.cos(-latitude+HALFPI)*Math.sin(longitude);

		    return new Number3D(x,y,z);
		}
		
		public static function fromNumber3D($n:Number3D):Spherical3D
		{
		    var r:Number = Math.sqrt($n.x* $n.x + $n.y* $n.y+ $n.z* $n.z); 
		    var lat:Number = -Math.asin($n.y/r) + HALFPI ;
		    var lon:Number = Math.atan2($n.z, $n.x);
		    
		    return new Spherical3D(r,lat,lon);
		}
		
		public function toString():String
		{
			return "[Spherical3D] " + int(radius.toString()) + ", " + int(latitude/DEGREE) + ", " + int(longitude/DEGREE);  
		}

	}
}