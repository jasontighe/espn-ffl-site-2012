package leelib.threeD
{
	import away3d.core.base.Face;
	import away3d.core.base.Mesh;
	import away3d.core.base.UV;
	import away3d.core.base.Vertex;
	import away3d.materials.BitmapMaterial;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.papervision3d.core.geom.TriangleMesh3D;
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.core.math.Plane3D;
	import org.papervision3d.core.math.Quaternion;
	
/**
 * 	AWAY3D VERSION -- NOT DONE!
 */	
	public class ShadowCaster
	{
		private static const DEGREE:Number = Math.PI / 180;
		
		private var _shadowBitmapData:BitmapData;
		private var _position:Number3D;

		private var _pitch:Number;
		private var _yaw:Number;
		private var _roll:Number;

		private var _alpha:Number;
		private var _shadowColor:uint;
		private var _rez:Number;
		private var _blur:Number;
		private var _lightFalloff:Boolean;

		private var _dirForward:Number3D;
		private var _dirLeft:Number3D;
		private var _dirUp:Number3D;
		
		private var _dicCasterMeshes:Dictionary;	
		private var _dicReceiverMeshes:Dictionary;
		private var _dicMeshMaterials:Dictionary;
		private var _dicVertPos:Dictionary; 		// dictionary of dictionaries of converted global positions of mesh verts
		private var _dicVertUv:Dictionary; 			// dictionary of dictionaries of calculated uv values for mesh verts
		
		private var _halfFov:Number;
		
		private var _shadowHolder:Sprite;
		private var _shapeShadow:Shape;
		private var _mask:Shape;
		
		private var _sprDebug:Sprite;
		private var _bmpDebug:Bitmap;
		
		
		public function ShadowCaster($fieldOfView:Number=Math.PI/180*80, $shadowAlpha:Number=0.22 )
		{
			_rez = 600;
			_blur = 0;
			
			_shadowColor = 0x000000;
			_alpha = $shadowAlpha;
			
			_halfFov = $fieldOfView / 2;

			_dicCasterMeshes = new Dictionary();
			_dicReceiverMeshes = new Dictionary();			

			_dicMeshMaterials = new Dictionary();
			_dicVertPos = new Dictionary();
			_dicVertUv = new Dictionary();
			
			_position = new Number3D(0,0,-1000);
			_pitch = 0;
			_yaw = 0;
			_roll = 0;
			
			_lightFalloff = true;
			
			_shadowHolder = new Sprite();

				_shapeShadow = new Shape();
				_shadowHolder.addChild(_shapeShadow);

				_mask = new Shape();
				_shadowHolder.addChild(_mask);
	
				_shapeShadow.mask = _mask;

			_sprDebug = new Sprite();
			_bmpDebug = new Bitmap();
			_sprDebug.addChild(_bmpDebug);
			_sprDebug.alpha = 1;
			_sprDebug.x = _sprDebug.y = 150;

			updateSpotlight();

			updateVectors();
		}
		
		public function registerShadowCasterObject($mesh:Mesh):void
		{
			_dicCasterMeshes[$mesh] = $mesh;

			_dicVertPos[$mesh] = new Dictionary();
			_dicVertUv[$mesh] = new Dictionary();
		}
		
		public function registerShadowReceiverObject($mesh:Mesh, $meshBitmapMaterial:BitmapMaterial):void
		{
			_dicReceiverMeshes[$mesh] = $mesh;

			_dicVertPos[$mesh] = new Dictionary();
			_dicVertUv[$mesh] = new Dictionary();
			
			$meshBitmapMaterial
			_dicMeshMaterials[$mesh] = $meshBitmapMaterial;
		}

		/**
		 * Untested 
		 * :P
		 */
		public function unregisterMesh($mesh:Mesh):void
		{
			if (_dicMeshMaterials[$mesh]) _dicMeshMaterials[$mesh] = null;
			if (_dicCasterMeshes[$mesh]) _dicCasterMeshes[$mesh] = null; 
			if (_dicReceiverMeshes[$mesh]) _dicReceiverMeshes[$mesh] = null; 
			
			_dicVertPos[$mesh] = null; // .. lingering references?
			_dicVertUv[$mesh] = null; 
		}

		public function get spotlightPosition():Number3D
		{
			return _position;
		}
		public function set spotlightPosition($n:Number3D):void
		{
			_position = $n;
		}
		
		public function get spotlightPitch():Number
		{
			return _pitch;
		}
		public function set spotlightPitch($n:Number):void
		{
			_pitch = $n;
			updateVectors();
		}
		
		public function get spotlightYaw():Number
		{
			return _yaw;
		}
		public function set spotlightYaw($n:Number):void
		{
			_yaw = $n;
			updateVectors();
		}
		
		/**
		 * Doesn't do anything functionally useful here (used for Projection Manager) 
		 */
		public function get spotlightRoll():Number
		{
			return _roll;
		}
		public function set spotlightRoll($n:Number):void
		{
			_roll= $n;
			updateVectors();
		}

		public function get spotlightFieldOfView():Number
		{
			return _halfFov*2;
		}
		public function set spotlightFieldOfView($n:Number):void
		{
			_halfFov = $n/2;
			updateVectors();
		}
		
		/**
		 * Simulates a softer light intensity around the edges with a radial gradient mask 
		 */
		public function get lightFalloff():Boolean
		{
			return _lightFalloff;
		}
		public function set lightFalloff($b:Boolean):void
		{
			_lightFalloff = $b;
			updateSpotlight();
		}
		
		public function get shadowColor():uint
		{
			return _shadowColor;
		}
		public function set shadowColor($c:uint):void
		{
			_shadowColor = $c;
		}
		
		public function get shadowAlpha():Number
		{
			return _alpha;
		}
		public function set shadowAlpha($n:Number):void
		{
			_alpha = $n;
			updateSpotlight();
		}
		
		public function get spotlightForwardVector():Number3D
		{
			return _dirForward;
		}
		
		/**
		 * Defines the width and height of the shadow texture map.
		 * A greater field-of-view should use a larger value.
		 */
		public function get textureResolution():Number
		{
			return _rez;
		}
		public function set textureResolution($n:Number):void
		{
			_rez = $n;
			updateSpotlight();
		}
		
		/**
		 * Defines the x and y values of the Blur filter used on the texture map.
		 * 0 = no filter 
		 */
		public function get blur():Number
		{
			return _blur;
		}
		public function set blur($n:Number):void
		{
			_blur = $n;
			if (_blur > 0)
				_shadowHolder.filters = [ new BlurFilter(_blur,_blur,2) ];
			else 
				_shadowHolder.filters = null;
		}
		
		public function addDebugSpriteToStage($s:Stage):void
		{
			$s.addChild(_sprDebug);
		}
		
		// ----------------------------------------------------------------
		
		private function updateSpotlight():void
		{
			_shapeShadow.cacheAsBitmap = true;
			_mask.cacheAsBitmap = true;
			
			_shadowBitmapData = new BitmapData(_rez, _rez, true, 0x00);
			
			var m:Matrix = new Matrix();
			
			var sca:Number = _rez/1700; // * magic number  
			m.tx = _rez/2*1/sca;
			m.ty = _rez/2*1/sca;
			m.scale(sca, sca); 
			
			_mask.graphics.clear();

			if (_lightFalloff) {			
				_mask.graphics.beginGradientFill(
					GradientType.RADIAL, [0xffffff,0xffffff,0xff0000], [1*_alpha, 0.5*_alpha, 0], [0,150,255], m);
				_mask.graphics.drawCircle(_rez/2, _rez/2, _rez/2);
			}
			else {
				_mask.graphics.beginFill(0xffffff, _alpha);
				_mask.graphics.drawCircle(_rez/2, _rez/2, _rez/2 - 5); 
				// ... "- 5" is either a minor kludge or clever way to avoid extra edge case logic for UV's  
			}
				
			_mask.graphics.endFill();
		}
		
		
		public function update():void
		{
			var mesh:Mesh
			var b:BitmapData;

			_shapeShadow.graphics.clear();
			_shapeShadow.graphics.beginFill(0x00ff00);
			_shapeShadow.graphics.drawRect(0,0,_shadowBitmapData.width,_shadowBitmapData.height);
			_shapeShadow.graphics.endFill();

			for each (mesh in _dicCasterMeshes)
			{
				updateFrontMesh(mesh);
			} 

			_shadowBitmapData.fillRect( new Rectangle(0,0,_shadowBitmapData.width, _shadowBitmapData.height), 0x000000);
			_shadowBitmapData.draw( _shadowHolder, null, null, BlendMode.NORMAL, new Rectangle(0,0, _rez,_rez) );

			for each (mesh in _dicReceiverMeshes)
			{
				updateBackMesh(mesh);
			} 
			
			if (_sprDebug) { 
				_bmpDebug.bitmapData = _shadowBitmapData;
				_sprDebug.graphics.clear();
				_sprDebug.graphics.lineStyle(1,0x0);
				_sprDebug.graphics.drawRect(0,0,_shadowBitmapData.width,_shadowBitmapData.height);
				_sprDebug.width = _sprDebug.height = 125;
			}
		}

		private function updateFrontMesh($mesh:Mesh):void
		{
			updateMesh($mesh);

			// And then draw shadow

			var i:int;			
			var r:Rectangle = new Rectangle(0,0, _rez, _rez);

			var dicUv:Dictionary = _dicVertUv[$mesh];

			for (i = 0; i < $mesh.geometry.faces.length; i++)
			{
				var f:Face = $mesh.geometry.faces[i]; // was Triangle3D
				
				var uvA:UV = dicUv[ f.vertices[0] ];
				var uvB:UV = dicUv[ f.vertices[1] ];
				var uvC:UV = dicUv[ f.vertices[2] ];
				
				var ax:Number = uvA.u * _rez;
				var ay:Number = (1-uvA.v) * _rez;
				var bx:Number = uvB.u * _rez;
				var by:Number = (1-uvB.v) * _rez;
				var cx:Number = uvC.u * _rez;
				var cy:Number = (1-uvC.v) * _rez;
				
				// hacky clamp action:
				if (ax < -200) ax = -200;
				if (bx < -200) bx = -200;
				if (cx < -200) cx = -200;
				if (ay < -200) ay = -200;
				if (by < -200) by = -200;
				if (cy < -200) cy = -200;
				if (ax > _rez + 200) ax = _rez + 200;
				if (bx > _rez + 200) bx = _rez + 200;
				if (cx > _rez + 200) cx = _rez + 200;
				if (ay > _rez + 200) ay = _rez + 200;
				if (by > _rez + 200) by = _rez + 200;
				if (cy > _rez + 200) cy = _rez + 200;
				
				_shapeShadow.graphics.beginFill(_shadowColor, 1);
				_shapeShadow.graphics.moveTo(ax, ay);
				_shapeShadow.graphics.lineTo(bx, by);
				_shapeShadow.graphics.lineTo(cx, cy);
				_shapeShadow.graphics.lineTo(ax, ay);
				_shapeShadow.graphics.endFill();
			}
		}
		
		private function updateBackMesh($mesh:Mesh):void
		{
			var mat:BitmapMaterial = _dicMeshMaterials[$mesh];
			mat.bitmap = _shadowBitmapData; 

			updateMesh($mesh);
			
			// Copy UV values back into mesh geometry

			var dicUv:Dictionary = _dicVertUv[$mesh];
			
			for (var i:int = 0; i < $mesh.geometry.faces.length; i++)
			{
				var face:Face = $mesh.geometry.faces[i];

				for (var j:int = 0; j < 3; j++)  
				{
					var vert:Vertex = face.vertices[j];
					face.uvs[j].u = dicUv[vert].u;
					face.uvs[j].v = dicUv[vert].v;
					face.visible = false;
				}
			}

			var bitmapMaterial:BitmapMaterial = _dicMeshMaterials[$mesh];
			/// bitmapMaterial.resetUVS();
		}

private var _count:int = 0;
		private function updateMesh($mesh:Mesh):void
		{
			var i:int;
			
			var dicPos:Dictionary = _dicVertPos[$mesh]; 
			var dicUv:Dictionary = _dicVertUv[$mesh];

			var positionPlusDirection:Number3D = Number3D.add(_position, _dirForward);
			var aspectRatio:Number = _rez / _rez; // hah
			
			// Vars recycled within loop below:
///			var m:Matrix3D;
			var plane:Plane3D = new Plane3D();
			var planeV:Plane3D = new Plane3D();
			var planeH:Plane3D = new Plane3D();
			var posPlaneCenter:Number3D;
			var posPlaneLeftBound:Number3D;
			var posPlaneTopBound:Number3D;
			var posVertexNew:Number3D;
			var n:Number3D;
			var posVertex:Number3D;

			// * 	CORE MATH ROUTINE:

			for (i = 0; i < $mesh.geometry.vertices.length; i++)
			{
				// vertex
				var vertex:Vertex = $mesh.geometry.vertices[i];
if ($mesh.name == "chest-node_PIVOT" && i==0) trace('vertex local coords', vertex);				
				
				// vertex world position
				if (! dicPos[vertex]) dicPos[vertex] = new Number3D();
				posVertex = dicPos[vertex];

				var mLocal:Matrix3D = flashtoPvMatrix3D($mesh.transform); ///
				mLocal = Matrix3D.clone(mLocal); // wasteful, but copy() not working out
				mLocal.calculateTranspose(); 
				mLocal.n14 += vertex.x;
				mLocal.n24 += vertex.y;
				mLocal.n34 += vertex.z;
				
				var mWorld:Matrix3D = flashtoPvMatrix3D($mesh.sceneTransform); ///
				mLocal.calculateMultiply(mWorld, mLocal);
				posVertex.x = mLocal.n14;
				posVertex.y = mLocal.n24;
				posVertex.z = mLocal.n34;
if ($mesh.name == "chest-node_PIVOT" && i==0) trace('b', posVertex);				

				// create plane at end point position + forward vector
				plane.setNormalAndPoint(_dirForward, Number3D.add(_position, _dirForward));
				
				// project vertex on that plane
				posVertexNew = plane.getIntersectionLineNumbers(_position, posVertex);
				
				// posPlaneCenter
				posPlaneCenter = plane.getIntersectionLineNumbers(_position, Number3D.add(_position, _dirForward));

				// posPlaneLeftBound - center-left position on projection
				posPlaneLeftBound = plane.getIntersectionLineNumbers(_position, Number3D.add(_position, _dirLeft));

				// posPlaneTopBound - top-center position on projection 
				posPlaneTopBound = plane.getIntersectionLineNumbers(_position, Number3D.add(_position, _dirUp));
				
				// rangeH - distance from center of projection to its horizontal edge
				var rangeH:Number = Number3D.sub(posPlaneLeftBound, posPlaneCenter).modulo;
				
				// planeV - goes vertically (perpendicular to plane) from posPlaneCenter
				n = Number3D.sub(posPlaneLeftBound, posPlaneCenter);
				n.normalize();
				planeV.setNormalAndPoint( n, posPlaneCenter);

				// planeH - goes horizontally (perpendicular to plane) from posPlaneCenter
				n = Number3D.sub(posPlaneTopBound, posPlaneCenter);
				n.normalize();
				planeH.setNormalAndPoint( n, posPlaneCenter);
				
				// distH - distance of vertex from vertical center plane
				var distH:Number = planeV.distance(posVertexNew);

				// distV - distance of vertex from horiz center plane
				var distV:Number = planeH.distance(posVertexNew);

				// uv, finally
				if (! dicUv[vertex]) dicUv[vertex] = new UV();
				dicUv[vertex].u = 0.5 + distH / rangeH;
				dicUv[vertex].v = 0.5 + (distV / rangeH) * aspectRatio;
			} 
		}
		
		
		private function updateVectors():void
		{
			var len:Number = Math.tan(_halfFov);

			_dirForward = new Number3D(0,0,1);

			_dirLeft = new Number3D(len,0,1);
			_dirLeft.normalize();
			
			_dirUp = new Number3D(0,len,1);
			_dirUp.normalize();
			
			
			var q:Quaternion = Quaternion.createFromEuler(0,_roll,0);

			Matrix3D.multiplyVector(q.matrix, _dirForward);
			Matrix3D.multiplyVector(q.matrix, _dirLeft);
			Matrix3D.multiplyVector(q.matrix, _dirUp);

			 
			q = Quaternion.createFromEuler(-_yaw,0,_pitch); // y axis, z axis, x axis 

			Matrix3D.multiplyVector(q.matrix, _dirForward);
			Matrix3D.multiplyVector(q.matrix, _dirLeft);
			Matrix3D.multiplyVector(q.matrix, _dirUp);
		}
		
		private function flashtoPvMatrix3D($fm:flash.geom.Matrix3D):org.papervision3d.core.math.Matrix3D
		{
			var a:Array = [];
			for (var i:int = 0; i < $fm.rawData.length; i++)
			{
				 a[i] = $fm.rawData[i];
			}
			
			var pm:Matrix3D = new Matrix3D(a);
			return pm;
		}
	}
}
