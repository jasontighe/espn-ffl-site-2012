package leelib.threeD
{
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Face;
	import away3d.core.base.Mesh;
	import away3d.core.base.Object3D;
	import away3d.materials.ColorMaterial;
	import away3d.materials.Material;
	import away3d.materials.ShadingColorMaterial;
	import away3d.materials.WireframeMaterial;
	
	import leelib.util.Util;
	

	public class UtilA3d
	{
		public function UtilA3d()
		{
		}
		
		public static function printChildren($m:Mesh, $outputPrefix:String=""):String
		{
			var string:String = "";
			
			if ($outputPrefix == "") // header
			{
				string = '___________________________________________________\r';
				string += 'Structure of ' + $m.name + ' (' + numVertsRecursive($m) + ' vertices total)\r';
			}
			
			var s:String = " (" + Util.oneDecimalPlace($m.rotationX) + "/" + Util.oneDecimalPlace($m.rotationY) + "/" + Util.oneDecimalPlace($m.rotationZ) + ")"
			s += " <" + $m.vertices.length.toString() + ">" + "\r";
			
			string += $outputPrefix + " | " + $m.name + s;
			
			if ($m is ObjectContainer3D)
			{
				var oc:ObjectContainer3D = $m as ObjectContainer3D;
				
				for (var i:int = 0; i < oc.children.length; i++)
				{
					string += printChildren( Mesh(oc.children[i]), $outputPrefix + " | " + $m.name);
				}
			}
			
			return string;
		}		
		
		public static function numVertsRecursive($d:Object3D):int
		{
			var num:int = 0;
			
			if ($d is Mesh) 
			{ 
				num += Mesh($d).geometry.vertices.length;
			}
			
			if ($d is ObjectContainer3D) 
			{
				// recurse
				
				var oc:ObjectContainer3D = ObjectContainer3D($d);
				
				for (var i:int = 0; i < oc.children.length; i++)
				{
					var child:Object3D = oc.children[i];
					num += numVertsRecursive(child);
				}
			}
			
			return num;
		} 
		
		public static function applyDebugMaterialTo($o:Object3D, $useGrayColor:Boolean=false):void
		{
			if ($o is Mesh) 
			{
				var me:Mesh = Mesh($o);
				var col:uint = 0x888888;
				col += int(Math.random()*0x888888);
				if ($useGrayColor) col = 0xcccccc;
				
				me.material = new ShadingColorMaterial(col);

				// erase any face-specific materials
				for each (var f:Face in me.faces) {
					if (f.material) f.material = null;
				}
			}
			
			if ($o is ObjectContainer3D)
			{
				var oc:ObjectContainer3D = $o as ObjectContainer3D;
				
				// recurse
				for each (var o:Object3D in oc.children)
				{
					applyDebugMaterialTo(o, $useGrayColor);
				}
			}
		} 
		
		
	}
}