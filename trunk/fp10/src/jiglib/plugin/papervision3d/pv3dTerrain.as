﻿/**
* @author Ringo 
* FlashBookmarks (http://www.flashbookmarks.com)
* @version 1.0.0  
*/
package jiglib.plugin.papervision3d {
	import flash.geom.Vector3D;
	import flash.display.BitmapData;
	
	import org.papervision3d.Papervision3D;
	import org.papervision3d.core.geom.*;
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.*
	import org.papervision3d.core.proto.*;	
	
	import jiglib.plugin.ITerrain;

	/**
	* Terrain Class
	*/
	public class pv3dTerrain extends TriangleMesh3D implements ITerrain
	{
		//Min of coordinate horizontally;
		private var _minW:Number;
		
		//Min of coordinate vertically;
		private var _minH:Number;
		
		//Max of coordinate horizontally;
		private var _maxW:Number;
		
		//Max of coordinate vertically;
		private var _maxH:Number;
		
		//The horizontal length of each segment;
		private var _dw:Number;
		
		//The vertical length of each segment;
		private var _dh:Number;
		
		//the heights of all vertices
		private var _heights:Array;
		
		/**
		* Number of segments horizontally. Defaults to 1.
		*/
		public var segmentsW :int;
	
		/**
		* Number of segments vertically. Defaults to 1.
		*/
		public var segmentsH :int;

		/**
		* Default size if not texture is defined.
		*/
		static public var DEFAULT_SIZE :Number = 500;
	
		/**
		* Default size if not texture is defined.
		*/
		static public var DEFAULT_SCALE :int = 1;
	
		/**
		* Default value of gridX if not defined. The default value of gridY is gridX.
		*/
		static public var DEFAULT_SEGMENTS :int = 1;
	
	
		// ___________________________________________________________________________________________________
		//                                                                                               N E W
		// NN  NN EEEEEE WW    WW
		// NNN NN EE     WW WW WW
		// NNNNNN EEEE   WWWWWWWW
		// NN NNN EE     WWW  WWW
		// NN  NN EEEEEE WW    WW
	
		/**
		* Create a new Terrain with a heightmap bitmap or generated by perlin noise
		* <p/>
		* @param	map			BitmpaData for the height of the terrain.
		* <p/>
		* @param	material	A MaterialObject3D object that contains the material properties of the object.
		* <p/>
		* @param	width		[optional] - Desired width or scaling factor if there's bitmap texture in material and no height is supplied.
		* <p/>
		* @param	depth		[optional] - Desired depth
		* <p/>
		* @param	maxHeight	[optional] - Maximum height (white is max, black is 0). 
		* <p/>
		* @param	segmentsW	[optional] - Number of segments horizontally. Defaults to 1.
		* <p/>
		* @param	segmentsH	[optional] - Number of segments vertically. Defaults to segmentsW.
		* <p/>
		*/
		public function pv3dTerrain( terrainHeightMap:BitmapData, material:MaterialObject3D = null, width:Number = 0, depth:Number = 0, maxHeight:Number = 0, segmentsW:int = 0, segmentsH:int = 0 )
		{
			super( material, new Array(), new Array(), null );
	
			this.segmentsW = segmentsW || DEFAULT_SEGMENTS; // Defaults to 1
			this.segmentsH = segmentsH || this.segmentsW;   // Defaults to segmentsW
	
			var scale :Number = DEFAULT_SCALE;
			
			if( ! depth )
			{
				if( width )
					scale = width;
	
				if( material && material.bitmap )
				{
					width  = material.bitmap.width  * scale;
					depth = material.bitmap.height * scale;
				}
				else
				{
					width  = DEFAULT_SIZE * scale;
					depth = DEFAULT_SIZE * scale;
				}
			}
			buildTerrain( width, depth, maxHeight, terrainHeightMap);
		}
	
		private function buildTerrain( width:Number, depth:Number, maxHeight:Number, map:BitmapData ):void
		{
			var gridX    :int = this.segmentsW;
			var gridY    :int = this.segmentsH;
			var gridX1   :int = gridX +1;
			var gridY1   :int = gridY +1;
	
			var vertices :Array  = this.geometry.vertices;
			var faces    :Array  = this.geometry.faces;
	
			var textureX :Number = width /2;
			var textureY :Number = depth /2;
	
			_minW = -textureX;
			_minH = -textureY;
			_maxW = textureX;
			_maxH = textureY;
			_dw = width / gridX;
			_dh = depth / gridY;
	
			_heights = new Array();
			// Vertices
			for( var ix:int = 0; ix < gridX1; ix++ )
			{
				_heights[ix] = new Array();
				for( var iy:int = 0; iy < gridY1; iy++ )
				{
					var x :Number = ix * _dw - textureX;
					var y :Number = iy * _dh - textureY;
					
					_heights[ix][iy] = (map.getPixel((ix / gridX1) * map.width, (iy / gridY1) * map.height) & 0xFF);
					_heights[ix][iy] *= (maxHeight/255);
					//trace(ix + ":", (ix/gridX1) * map.width, " ", iy + ":", (iy/gridY1) *map.height, "   height:", height);
					vertices.push( new Vertex3D( x, _heights[ix][iy], y ) );
				}
			}
	
			// Faces
			var uvA :NumberUV;
			var uvC :NumberUV;
			var uvB :NumberUV;
	
			for(  ix = 0; ix < gridX; ix++ )
			{
				for(  iy= 0; iy < gridY; iy++ )
				{
					// Triangle A
					var a:Vertex3D = vertices[ ix     * gridY1 + iy     ];
					var c:Vertex3D = vertices[ ix     * gridY1 + (iy+1) ];
					var b:Vertex3D = vertices[ (ix+1) * gridY1 + iy     ];
	
					uvA =  new NumberUV( ix     / gridX, iy     / gridY );
					uvC =  new NumberUV( ix     / gridX, (iy+1) / gridY );
					uvB =  new NumberUV( (ix+1) / gridX, iy     / gridY );
	
					faces.push(new Triangle3D(this, [ a, b, c ], null, [ uvA, uvB, uvC ] ) );
	
					// Triangle B
					a = vertices[ (ix+1) * gridY1 + (iy+1) ];
					c = vertices[ (ix+1) * gridY1 + iy     ];
					b = vertices[ ix     * gridY1 + (iy+1) ];
	
					uvA =  new NumberUV( (ix+1) / gridX, (iy+1) / gridY );
					uvC =  new NumberUV( (ix+1) / gridX, iy      / gridY );
					uvB =  new NumberUV( ix      / gridX, (iy+1) / gridY );
	
					faces.push(new Triangle3D(this, [ a, b, c ], null, [ uvA, uvB, uvC ] ) );
				}
			}
	
			this.geometry.ready = true;

			if(Papervision3D.useRIGHTHANDED)
			this.geometry.flipFaces();
		}
		
		public function get minW():Number {
			return _minW;
		}
		public function get minH():Number {
			return _minH;
		}
		public function get maxW():Number {
			return _maxW;
		}
		public function get maxH():Number {
			return _maxH;
		}
		public function get dw():Number {
			return _dw;
		}
		public function get dh():Number {
			return _dh;
		}
		public function get sw():int {
			return this.segmentsW;
		}
		public function get sh():int {
			return this.segmentsH;
		}
		public function get heights():Array {
			return _heights;
		}
	}
}